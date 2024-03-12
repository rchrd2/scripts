import AppKit
import Foundation
import SwiftUI
import os.log

public struct HelpersConfig {
  public var dryRun: Bool
  public var enableSyslog: Bool
  public var enablePrint: Bool
  public var mediaPathUrl: URL
}

// read an ENV variable called MEDIA_DIR
// if it exists, use that as the mediaPathUrl
// otherwise use the default
public let mediaDir = ProcessInfo.processInfo.environment["MEDIA_DIR"]

public var helpersConfig = HelpersConfig(
  dryRun: false,
  // How to monitor syslog:
  // $ log stream --info --debug --predicate 'eventMessage CONTAINS "SCRIPTS"'
  enableSyslog: true,
  enablePrint: false,
  mediaPathUrl: URL(fileURLWithPath: mediaDir ?? "/Users/richard/msc/media")
)

public func name() {
  log("richard")
}

public func name2() {
  log("richard2")
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
public func runIfFileDoesntExist(_ filePath: String, _ function: () -> Void) {
  if !FileManager.default.fileExists(atPath: filePath) {
    function()
  }
}

public func runIfFileUrlDoesntExist(_ url: URL, _ function: () -> Void) {
  if !FileManager.default.fileExists(atPath: url.path) {
    function()
  } else {
    log("File already exists at \(url.path())")
  }
}

public func runIfFileSizeIsDifferent(
  _ sourceURL: URL,
  _ destURL: URL,
  onNotExists: () -> Void,
  onSizeDifferent: () -> Void,
  onSame: () -> Void,
  finally: () -> Void = {}
) {
  // only run the function if the the destURL doesn't exist or the file size is different
  if !FileManager.default.fileExists(atPath: destURL.path) {
    // log("Running because dest file doesn't exist")
    onNotExists()
  } else {
    let sourceFileSize = sourceURL.fileSize()
    let destFileSize = destURL.fileSize()
    if sourceFileSize != destFileSize {
      // log("File size is different so running: \(sourceFileSize) != \(destFileSize)")
      onSizeDifferent()
    } else {
      // log("File size is the same for \(sourceURL.path) and \(destURL.path)")
      onSame()
    }
  }
  finally()
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

public func getMountedVolumes() -> [URL] {
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

public func umountVolume(at url: URL) {
  do {
    try NSWorkspace.shared.unmountAndEjectDevice(at: url)
  } catch {
    print("error unmounting \(url)")
  }
}

public func addSpotlightFinderTag(to fileURL: URL, with tag: String) {
  // shell out to $ tag --add tagname file
  // TODO figure out how to do this in swift
  // Maybe https://developer.apple.com/documentation/findersync/fifindersynccontroller/2889862-settagdata

  let tags = tag.components(separatedBy: ",")
  for tagSingle in tags {
    if checkIfSpotlightFinderTagExists(to: fileURL, with: tagSingle) {
      continue
    }
    log("Adding tag \(tagSingle) to \(fileURL.path)")

    let task = Process()
    task.launchPath = "/usr/local/bin/tag"
    task.arguments = ["--add", tagSingle, fileURL.path(percentEncoded: false)]
    task.launch()

    // let pipe = Pipe()
    // task.standardOutput = pipe
    // task.launch()
    // task.waitUntilExit()
    // let data = pipe.fileHandleForReading.readDataToEndOfFile()
    // let output = String(data: data, encoding: .utf8)

    task.waitUntilExit()
  }
}

public func removeSpotlightFinderTag(to fileURL: URL, with tag: String) {
  // shell out to
  // tag --remove tagname file
  // TODO figure out how to do this in swift
  let task = Process()
  task.launchPath = "/usr/local/bin/tag"
  task.arguments = ["--remove", tag, fileURL.path(percentEncoded: false)]
  task.launch()
  task.waitUntilExit()
}

public func getSpotlightFinderTags(to fileURL: URL) -> [String] {
  let task = Process()
  task.launchPath = "/usr/local/bin/tag"
  task.arguments = ["--no-name", "--list", "--garrulous", fileURL.path(percentEncoded: false)]
  let pipe = Pipe()
  task.standardOutput = pipe
  task.launch()
  task.waitUntilExit()
  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  let output = String(data: data, encoding: .utf8)
  var outputArray = output?.components(separatedBy: "\n")
  outputArray?.removeLast()

  return outputArray ?? []
}

public func checkIfSpotlightFinderTagExists(to fileURL: URL, with tag: String) -> Bool {
  let outputArray = getSpotlightFinderTags(to: fileURL)
  // log("outputArray: \(outputArray)")
  return outputArray.contains(tag)
}

public func ensureSshAddHasBeenRun() {
  log("ensureSshAddHasBeenRun")
  let checkKeysCommand = Process()
  checkKeysCommand.launchPath = "/usr/bin/ssh-add"
  checkKeysCommand.arguments = ["-l"]

  let outputPipe = Pipe()
  checkKeysCommand.standardOutput = outputPipe

  do {
    try checkKeysCommand.run()
    checkKeysCommand.waitUntilExit()
  } catch {
    // Error handling
    alertUI("Error checking for SSH keys", onConfirm: { exit(1) })
  }

  let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
  let outputString = String(data: outputData, encoding: .utf8) ?? ""
  log(outputString)

  if outputString.contains("The agent has no identities.") {
    log("show confirm")
    alertUI(
      "Please add your SSH key to the agent with `ssh-add `.", onConfirm: { exit(1) })
  }

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

public class AppDelegate<V: View>: NSObject, NSApplicationDelegate, NSWindowDelegate {
  var contentView: V

  init(_ contentView: V) {
    self.contentView = contentView
  }

  public func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.activate(ignoringOtherApps: true)
  }
}

public func runUI<V: View>(contentView: V) {
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

public func confirmUI(
  _ prompt: String, onConfirm: @escaping () -> Void, onCancel: @escaping () -> Void = {}
) {
  let contentView = VStack {}.confirmationDialog(
    prompt, isPresented: .constant(true)
  ) {
    Button(
      "Yes",
      action: {
        log("Confirmed")
        NSApplication.shared.stop(nil)
        onConfirm()
      })
    Button("No", role: .cancel) {
      log("Canceled")
      NSApplication.shared.stop(nil)
      onCancel()
    }
  }
  runUI(contentView: contentView)
}

public func alertUI(
  _ prompt: String, onConfirm: @escaping () -> Void
) {
  let contentView = VStack {}.confirmationDialog(
    prompt, isPresented: .constant(true)
  ) {
    Button(
      "Close",
      role: .cancel,
      action: {
        NSApplication.shared.stop(nil)
        onConfirm()
      })
  }
  runUI(contentView: contentView)
}

// **** Extensions ****
extension URL {
  public var isDirectory: Bool {
    (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
  }
}
extension URL {
  public func fileSize() -> Double {
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
  public func subString(_ startIndex: Int, _ endIndex: Int) -> String {
    let end = (endIndex - self.count) + 1
    let indexStartOfText = self.index(self.startIndex, offsetBy: startIndex)
    let indexEndOfText = self.index(self.endIndex, offsetBy: end)
    let substring = self[indexStartOfText..<indexEndOfText]
    return String(substring)
  }
}

extension String: Error {}
