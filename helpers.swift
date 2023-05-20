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
    print("richard")
}

public func log(_ message: String) -> Void {
    if HelpersConfig["enablePrint"] ?? false {
      print(message)
    }

    if HelpersConfig["enableSyslog"] ?? false {
      NSLog("SCRIPTS \(message)")
    }
}

public func readFiles() -> Array<String> {
    var filePaths: Array<String> = []

    if isatty(STDIN_FILENO) == 0 {
        print("Reading stdin.")
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