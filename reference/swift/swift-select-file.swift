// select.swift
// https://www.objc.io/blog/2018/10/02/using-appkit-from-the-command-line/
// Note this is buggy. It closes as soon as i click anything.
// However it does work using the more verbose NSApplication code
import AppKit

func selectFile() -> URL? {
  let dialog = NSOpenPanel()
  // dialog.allowedFileTypes = ["jpg", "png"]
  guard dialog.runModal() == .OK else { return nil }
  return dialog.url
}

print(selectFile()?.absoluteString ?? "")
