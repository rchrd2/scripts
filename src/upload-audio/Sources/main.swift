/*
Uploads a file to my web server and presents a dialog with the public url
*/

// Requires helpers.swift

import AppKit
import Foundation
import SwiftHelpers
import SwiftUI
import os.log

exitWhenParentProcessExits()

helpersConfig.enablePrint = true
helpersConfig.enableSyslog = true

let forceMp3  = true

let uploadUrl = "rcaceres@dev.rchrd.net:sites/net.rchrd.dev/web/transit/uploads"
let publicUrlBase: String = "https://dev.rchrd.net/audio/?file=%2Fuploads%2F"

let allowedExtensions = [
  ".wav", ".mp3", ".png", ".dat", ".m4a",
]

func uploadFile(_ file: URL) {
  log("Uploading \(file.path(percentEncoded: false))")

  let task = Process()
  task.launchPath = "/usr/bin/scp"
  task.arguments = ["-q", file.path(percentEncoded: false), uploadUrl]

  // Prints output (turns out not useful with SCP)
  // let pipe = Pipe()
  // pipe.fileHandleForReading.readabilityHandler = { fileHandle in
  //   if let output = String(data: fileHandle.availableData, encoding: .utf8) {
  //     print(output)
  //   }
  // }
  // task.standardOutput = pipe

  task.launch()
  task.waitUntilExit()
}

func processFile(_ file: URL, _ isRecursive: Bool = false) {
  log("processing '\(file)'")

  var allowed = false
  for ext in allowedExtensions {
    if file.path().lowercased().hasSuffix(ext) {
      allowed = true
      break
    }
  }
  if !allowed {
    log("Skipping '\(file)'")
    return
  }

  // if it's not a mp3 or a wav, convert it to mp3
  if !file.path().lowercased().hasSuffix(".mp3")
    && forceMp3
    && !isRecursive
  {
    let mp3File = file.deletingPathExtension().appendingPathExtension("mp3")
    if !FileManager.default.fileExists(atPath: mp3File.path) {
      log(
        "Converting \(file.path(percentEncoded: false)) to \(mp3File.path(percentEncoded: false))")
      let task = Process()
      task.launchPath = "/usr/local/bin/ffmpeg"
      // ffmpeg -i '${originalF}' -ab "320k" '${f}'
      // eg
      // $ ffmpeg -i '2023-11-24 - yamaha ambient improv.m4a' -ab 320k '2023-11-24 - yamaha ambient improv.m4a.mp3'

      task.arguments = [
        //https://forums.swift.org/t/having-some-issues-running-ffmpeg-via-process/20575/5
        "-nostdin",
        "-i",
        file.path(percentEncoded: false),
        "-ab",
        "320k",
        mp3File.path(percentEncoded: false),
      ]
      task.launch()
      task.waitUntilExit()
      log("Done converting to \(mp3File.path(percentEncoded: false))")

    }
    processFile(mp3File, true)
    return
  }

  // also create the .dat file for convenience
  let datFilePath = file.path(percentEncoded: false) + ".dat"

  if !FileManager.default.fileExists(atPath: datFilePath) {
    // call cFile(`audiowaveform -i '${f}' -o '${f}.dat' -z 256 -b 8`, `${f}.dat`);
    log("Creating the waveform \(datFilePath)")
    let task = Process()
    task.launchPath = "/usr/local/bin/audiowaveform"
    task.arguments = [
      "-i",
      file.path(percentEncoded: false),
      "-o",
      datFilePath,
      "-z",
      "256",
      "-b",
      "8",
    ]
    task.launch()
    task.waitUntilExit()
    log("Done creating the waveform \(datFilePath)")
  }

  uploadFile(file)
  log("Uploaded \(file.path(percentEncoded: false))")

  // Upload the .dat file if it exists
  if FileManager.default.fileExists(atPath: datFilePath) {
    uploadFile(URL(fileURLWithPath: datFilePath))
    log("Uploaded \(datFilePath)")
  }

  let basename = file.lastPathComponent
  let publicUrl =
    publicUrlBase + basename.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
  log("Public URL: \(publicUrl)")

  let contentView = VStack {}.confirmationDialog(
    "Upload Complete: \(basename)", isPresented: .constant(true)
  ) {
    Button("Open URL") {
      log("Opened URL: \(publicUrl)")
      NSWorkspace.shared.open(URL(string: publicUrl)!)
      NSApplication.shared.stop(nil)
    }
    Button("Copy URL") {
      NSPasteboard.general.clearContents()
      NSPasteboard.general.setString(publicUrl, forType: .string)
      log("Copied URL: \(publicUrl)")
      NSApplication.shared.stop(nil)
      // TODO use share dialog instead
      // https://stackoverflow.com/questions/60952334/swiftui-using-nssharingservicepicker-in-macos
    }
    Button("Close", role: .cancel) {
      NSApplication.shared.stop(nil)
    }
  }

  // if file doesnt end in .dat
  if !file.path().lowercased().hasSuffix(".dat") {
    runUI(contentView: contentView)
  }
}

func main() {
  ensureSshAddHasBeenRun()

  let files: [String] = readFiles()

  for file in files {
    log("upload audio debug: '\(file)'")
    processFile(URL(fileURLWithPath: file))
  }
}
main()
