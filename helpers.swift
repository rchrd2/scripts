// This was converted from NodeJS to Swift by ChatGPT
import Foundation
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
  log("checkRunning \(processIdentifier)")  // is this needed?
  // weirdly in my testing a/b tested and worked only with log there

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
