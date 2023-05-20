import AppKit
import Foundation
import SwiftUI

extension NSApplication {
  public func run<V: View>(@ViewBuilder view: () -> V) {
    let appDelegate = AppDelegate(view())
    NSApp.setActivationPolicy(.regular)
    delegate = appDelegate
    run()
  }
}

class AppDelegate<V: View>: NSObject, NSApplicationDelegate, NSWindowDelegate {
  init(_ contentView: V) {
    self.contentView = contentView

  }
  var contentView: V

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.activate(ignoringOtherApps: true)
  }
}

NSApplication.shared.run {
  let contentView = VStack {}.confirmationDialog(
    "Are you sure you want to import this file?", isPresented: .constant(true)
  ) {
    Button(action: {
      print("Confirmed")
      exit(0)

    }) {
      Text("Please confirm")
    }
    Button("Cancel", role: .cancel) {
      print("Canceled")
      exit(1)
    }
  }

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
