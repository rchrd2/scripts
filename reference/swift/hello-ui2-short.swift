// Run any SwiftUI view as a Mac app.
// https://gist.githubusercontent.com/chriseidhof/26768f0b63fa3cdf8b46821e099df5ff/raw/5daf56c40b57ec3a1426c76bf343bd68a095f892/boilerplate.swift

import Cocoa
import Foundation
import SwiftUI

extension CommandLine {
  static let input: String = { AnyIterator { readLine() }.joined() }()
}

NSApplication.shared.run {
  VStack {
    Text("Hello, UI!")
    Button("Print \"Foo\"") { print("Foo") }
    Button("Echo Input") { print(CommandLine.input) }
    Button("Done") { exit(0) }
  }
  .padding(100)
  .frame(maxWidth: .infinity, maxHeight: .infinity)
}

extension NSApplication {
  public func run<V: View>(@ViewBuilder view: () -> V) {
    let appDelegate = AppDelegate(view())
    NSApp.setActivationPolicy(.regular)
    mainMenu = customMenu
    delegate = appDelegate
    run()
  }
}

// Inspired by https://www.cocoawithlove.com/2010/09/minimalist-cocoa-programming.html

extension NSApplication {
  var customMenu: NSMenu {
    let appMenu = NSMenuItem()
    appMenu.submenu = NSMenu()
    let appName = ProcessInfo.processInfo.processName
    appMenu.submenu?.addItem(
      NSMenuItem(
        title: "Quit \(appName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"
      ))
    let mainMenu = NSMenu(title: "Main Menu")
    mainMenu.addItem(appMenu)
    return mainMenu
  }
}

class AppDelegate<V: View>: NSObject, NSApplicationDelegate, NSWindowDelegate {
  init(_ contentView: V) {
    self.contentView = contentView

  }
  var window: NSWindow!
  var hostingView: NSView?
  var contentView: V

  func applicationDidFinishLaunching(_ notification: Notification) {
    window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
      styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
      backing: .buffered, defer: false)
    window.center()
    window.setFrameAutosaveName("Main Window")
    hostingView = NSHostingView(rootView: contentView)
    window.contentView = hostingView
    window.makeKeyAndOrderFront(nil)
    window.delegate = self
    NSApp.activate(ignoringOtherApps: true)
  }
}
