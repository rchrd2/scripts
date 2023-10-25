import AppKit
import Foundation
import SwiftUI
import os.log

struct HelpersConfig {
  var dryRun: Bool
  var enableSyslog: Bool
  var enablePrint: Bool
  var mediaPathUrl: URL
}

var helpersConfig = HelpersConfig(
  dryRun: false,
  // How to monitor syslog:
  // $ log stream --info --debug --predicate 'eventMessage CONTAINS "SCRIPTS"
  enableSyslog: true,
  enablePrint: false,
  mediaPathUrl: URL(fileURLWithPath: "/Users/richard/msc/media")
)

public func name() {
  log("richard")
}

public func log(_ message: String) {
  if helpersConfig.enablePrint {
    print(message)
  }

  if helpersConfig.enableSyslog {
    NSLog("SCRIPTS \(message)")
  }
}

public func readFiles() -> [String] {
  var filePaths: [String] = []

  if isatty(STDIN_FILENO) == 0 {
    log("Reading stdin")
    while let line = readLine(strippingNewline: true) {
      filePaths.append(line)
    }
  }

  // Also read argv and append to files
  for arg in CommandLine.arguments[1...] {
    filePaths.append(arg)
  }

  return filePaths
}

// a function that runs a function if the file path doesn't exist
func runIfFileDoesntExist(_ filePath: String, _ function: () -> Void) {
  if !FileManager.default.fileExists(atPath: filePath) {
    function()
  }
}

func runIfFileUrlDoesntExist(_ url: URL, _ function: () -> Void) {
  if !FileManager.default.fileExists(atPath: url.path) {
    function()
  } else {
    log("File already exists at \(url.path())")
  }
}

func runIfFileSizeIsDifferent(
  _ sourceURL: URL, _ destURL: URL, onNotExists: () -> Void, onSizeDifferent: () -> Void,
  onSame:
    () -> Void
) {
  // only run the function if the the destURL doesn't exist or the file size is different
  if !FileManager.default.fileExists(atPath: destURL.path) {
    log("Running because dest file doesn't exist")
    onNotExists()
  } else {
    let sourceFileSize = sourceURL.fileSize()
    let destFileSize = destURL.fileSize()
    if sourceFileSize != destFileSize {
      log("File size is different so running: \(sourceFileSize) != \(destFileSize)")
      onSizeDifferent()
    } else {
      log("File size is the same for \(sourceURL.path) and \(destURL.path)")
      onSame()
    }
  }
}

// This was converted from NodeJS to Swift by ChatGPT
public func exitWhenParentProcessExits() {
  var check: (() -> Void)?
  check = {
    if !checkRunning(ProcessInfo.processInfo.processIdentifier) {
      exit(0)
    } else {
      Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
        check?()
      }
    }
  }
  Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
    check?()
  }
  check?()
}

// This was converted from NodeJS to Swift by ChatGPT
public func checkRunning(_ processIdentifier: Int32) -> Bool {
  // weirdly in my testing a/b tested and worked only with log there
  log("checkRunning \(processIdentifier)")

  let process = Process()
  process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
  process.arguments = ["ps", "-p", "\(processIdentifier)"]
  let pipe = Pipe()
  process.standardOutput = pipe
  do {
    try process.run()
    process.waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    return output?.contains("\(processIdentifier)") ?? false
  } catch {
    return false
  }
}

func getMountedVolumes() -> [URL] {
  let keys: [URLResourceKey] = [.volumeNameKey, .volumeIsRemovableKey, .volumeIsEjectableKey]
  let paths = FileManager().mountedVolumeURLs(includingResourceValuesForKeys: keys, options: [])
  var result = [URL]()
  if let urls = paths {
    for url in urls {
      let components = url.pathComponents
      if components.count > 1
        && components[1] == "Volumes"
      {
        result.append(url)
      }
    }
  }
  return result
}

func umountVolume(at url: URL) {
  do {
    try NSWorkspace.shared.unmountAndEjectDevice(at: url)
  } catch {
    print("error unmounting \(url)")
  }
}

func addSpotlightFinderTag(to fileURL: URL, with tag: String) {
  // shell out to
  // tag --add tagname file
  // TODO figure out how to do this in swift
  // TODO add function to check for presence of tag
  // Maybe https://developer.apple.com/documentation/findersync/fifindersynccontroller/2889862-settagdata
  let task = Process()
  task.launchPath = "/usr/local/bin/tag"
  task.arguments = ["--add", tag, fileURL.path]
  task.launch()
  task.waitUntilExit()
}

func removeSpotlightFinderTag(to fileURL: URL, with tag: String) {
  // shell out to
  // tag --remove tagname file
  // TODO figure out how to do this in swift
  // TODO add function to check for presence of tag
  let task = Process()
  task.launchPath = "/usr/local/bin/tag"
  task.arguments = ["--remove", tag, fileURL.path]
  task.launch()
  task.waitUntilExit()
}

// **** UI Helpers ****

extension NSApplication {
  public func run<V: View>(@ViewBuilder view: () -> V) {
    let appDelegate = AppDelegate(view())
    NSApp.setActivationPolicy(.regular)
    delegate = appDelegate
    run()
  }
}

class AppDelegate<V: View>: NSObject, NSApplicationDelegate, NSWindowDelegate {
  var contentView: V

  init(_ contentView: V) {
    self.contentView = contentView
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.activate(ignoringOtherApps: true)
  }
}

func runUI<V: View>(contentView: V) {
  NSApplication.shared.run {
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 200, height: 200),
      styleMask: [.titled, .closable, .resizable],
      backing: .buffered,
      defer: false
    )
    window.contentView = NSHostingView(rootView: contentView)
    window.makeKeyAndOrderFront(nil)
    window.center()
    return contentView
  }
}

func confirmUI(prompt: String, onConfirm: @escaping () -> Void) {
  let contentView = VStack {}.confirmationDialog(
    prompt, isPresented: .constant(true)
  ) {
    Button(
      "Yes",
      action: {
        log("Confirmed")
        onConfirm()
        NSApplication.shared.stop(nil)
      })
    Button("No", role: .cancel) {
      log("Canceled")
      NSApplication.shared.stop(nil)
    }
  }
  runUI(contentView: contentView)
}

// **** Extensions ****
extension URL {
  var isDirectory: Bool {
    (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
  }
}
extension URL {
  func fileSize() -> Double {
    var fileSize: Double = 0.0
    var fileSizeValue = 0.0
    try? fileSizeValue =
      (self.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).allValues.first?.value as! Double?)!
    if fileSizeValue > 0.0 {
      fileSize = (Double(fileSizeValue) / (1024 * 1024))
    }
    return fileSize
  }
}

extension String {
  /* Note, the endIndex is inclusive */
  func subString(_ startIndex: Int, _ endIndex: Int) -> String {
    let end = (endIndex - self.count) + 1
    let indexStartOfText = self.index(self.startIndex, offsetBy: startIndex)
    let indexEndOfText = self.index(self.endIndex, offsetBy: end)
    let substring = self[indexStartOfText..<indexEndOfText]
    return String(substring)
  }
}

extension String: Error {}
