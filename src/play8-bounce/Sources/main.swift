/*
Bounce stems

Example usage:
$ find /path/to/stems -type f | /usr/bin/swift <(cat helpers.swift play8-bounce.swift)

Requires helpers.swift
*/

import AVFoundation
import AppKit
import Foundation
import SwiftHelpers
import SwiftUI
import os.log

var fileArgs: [String] = ["-m"]
var targetDir = ""
var bounceName: String = "BOUNCE.WAV"

var files = readFiles()

if files.count <= 1 {
  log("Not enough files to bounce")
  exit(0)
}

for file in files {
  log("file \(file)")
  let fileUrl = URL(fileURLWithPath: file)
  if fileUrl.isDirectory {
    targetDir = file
    bounceName = fileUrl.lastPathComponent + "-BOUNCE.wav"
    let children = try FileManager.default.contentsOfDirectory(atPath: file)
    for child in children {
      // When bouncing a directory, exclude MASTER.WAV (often the mixdown)
      // and also mp3 files (often derivitives)
      // also excluded files with BOUNCE in the name
      if child != "MASTER.WAV" && child.lowercased().hasSuffix(".wav")
        && !child.lowercased().contains("bounce")
      {
        fileArgs.append(file + "/" + child)
      }
    }
  } else if file.lowercased().hasSuffix(".wav") {
    targetDir = fileUrl.deletingLastPathComponent().path
    fileArgs.append(file)
  }
}

let targetFile = targetDir + "/" + bounceName
fileArgs.append(targetFile)

var dialogMessage = "Bounce already exists"

runIfFileDoesntExist(targetFile) {
  let task = Process()
  task.launchPath = "/usr/local/bin/sox"
  task.arguments = fileArgs
  task.launch()
  task.waitUntilExit()
  log("Bounced to \(targetFile)")
  dialogMessage = "Bounce Complete"
}

let contentView = VStack {}.confirmationDialog(
  dialogMessage, isPresented: .constant(true)
) {
  Button("Reveal in Finder") {
    NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: targetFile)])
    exit(0)
  }
  Button("Close", role: .cancel) {
    NSApplication.shared.stop(nil)
    exit(0)
  }
}
runUI(contentView: contentView)
