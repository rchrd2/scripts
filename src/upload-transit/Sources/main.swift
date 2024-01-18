/*
Uploads a file to my web server and presents a dialog with the public url
*/

import AppKit
import Foundation
import SwiftHelpers
import SwiftUI
import os.log

exitWhenParentProcessExits()

let uploadUrl = "rcaceres@dev.rchrd.net:sites/net.rchrd.dev/web/transit/"
let publicUrlBase: String = "https://dev.rchrd.net/transit/"

let allowedExtensions = [
  ".aif",
  ".dat",
  ".jpeg",
  ".jpg",
  ".mov",
  ".mp3",
  ".mp4",
  ".nef",
  ".pdf",
  ".png",
  ".swift",
  ".tif",
  ".wav",
  ".zip",
]

func main() {
  ensureSshAddHasBeenRun()

  let files: [String] = readFiles()

  log("Uploading \(files.count) files")

  for file in files {
    // check if file is allowed
    var allowed = false
    for ext in allowedExtensions {
      if file.lowercased().hasSuffix(ext) {
        allowed = true
        break
      }
    }
    if !allowed {
      log("Skipping \(file)")
      alertUI(
        "File extension not allowed: \(file)",
        onConfirm: {}
      )
      continue
    }

    let task = Process()
    task.launchPath = "/usr/bin/rsync"
    task.arguments = ["-vv", "--checksum", file, uploadUrl]
    task.launch()
    task.waitUntilExit()

    // URL is the file publicUrl + basename url-encoded
    log("Uploaded \(file)")
    let basename = URL(fileURLWithPath: file).lastPathComponent
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
      }
      Button("Close", role: .cancel) {
        NSApplication.shared.stop(nil)
      }
    }
    runUI(contentView: contentView)
  }
}

main()
