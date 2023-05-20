import AppKit
// This was converted from NodeJS to Swift by ChatGPT
import Foundation
import SwiftUI
import os.log

var HelpersConfig: [String: Bool] = [
  "dryRun": false,
  // How to monitor syslog:
  // $ log stream --info --debug --predicate 'eventMessage CONTAINS "SCRIPTS"
  "enableSyslog": true,
  "enablePrint": false,
]

public func name() {
  log("richard")
}

public func log(_ message: String) {
  if HelpersConfig["enablePrint"] ?? false {
    print(message)
  }

  if HelpersConfig["enableSyslog"] ?? false {
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

extension URL {
  var isDirectory: Bool {
    (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
  }
}
