/*
Uploads a file to my web server and presents a dialog with the public url
*/

// Requires helpers.swift

import Foundation

// exitWhenParentProcessExits()

let uploadUrl = "rcaceres@dev.rchrd.net:sites/net.rchrd.dev/web/transit/uploads"
let publicUrlBase: String = "https://dev.rchrd.net/audio/?file=%2Fuploads%2F"

let allowedExtensions = [
  ".wav", ".mp3", ".png", ".dat",
]

func uploadFile(_ file: URL) {
  log("Uploading \(file.path())")
  let task = Process()
  task.launchPath = "/usr/bin/scp"
  task.arguments = [file.path(), uploadUrl]
  task.launch()
  task.waitUntilExit()
}

func processFile(_ file: URL) {
  // TODO
  // check if file is allowed
  var allowed = false
  for ext in allowedExtensions {
    if file.path().lowercased().hasSuffix(ext) {
      allowed = true
      break
    }
  }
  if !allowed {
    log("Skipping \(file)")
    return
  }

  // if it ends with mp3, also upload the .dat file for convenience
  if file.path().lowercased().hasSuffix(".mp3") {
    let datFile = file.path() + ".dat"
    if !FileManager.default.fileExists(atPath: datFile) {
      // call prepare-audio-for-upload.js {datFile}
      // TODO make this work..
      // log("Preparing the audio for upload")
      // let task = Process()
      // task.launchPath = "/usr/local/bin/node"
      // task.arguments = [
      //   "/Users/richard/Desktop/msc/scripts/prepare-audio-for-upload.js",
      //   datFile,
      // ]
      // task.launch()
      // task.waitUntilExit()

    }
    uploadFile(URL(fileURLWithPath: datFile))
  }

  uploadFile(file)

  log("Uploaded \(file)")
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

var files: [String] = readFiles()

for file in files {
  processFile(URL(fileURLWithPath: file))
}
