// Run any SwiftUI view as a Mac app.
// Based on https://gist.github.com/chriseidhof/26768f0b63fa3cdf8b46821e099df5ff
// https://gist.github.com/xenodium/150cc7cf4010627e8e4d28796fa3e8b9

import Cocoa
import SwiftUI

NSApplication.shared.run {
  VStack(spacing: 0) {
    Rectangle().fill(Color.green)
    Rectangle().fill(Color.yellow)
    Rectangle().fill(Color.red)
  }
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

extension NSApplication {
  var customMenu: NSMenu {
    let appMenu = NSMenuItem()
    appMenu.submenu = NSMenu()

    let quitItem = NSMenuItem(
      title: "Quit \(ProcessInfo.processInfo.processName)",
      action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    quitItem.keyEquivalentModifierMask = []
    appMenu.submenu?.addItem(quitItem)

    let mainMenu = NSMenu(title: "Main Menu")
    mainMenu.addItem(appMenu)
    return mainMenu
  }
}

class AppDelegate<V: View>: NSObject, NSApplicationDelegate, NSWindowDelegate {
  var window = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: 414 * 0.8, height: 896 * 0.8),
    styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
    backing: .buffered, defer: false)

  var contentView: V

  init(_ contentView: V) {
    self.contentView = contentView
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    window.delegate = self
    window.center()
    // window.setFrameAutosaveName("Main Window") // Remember frame.
    window.contentView = NSHostingView(rootView: contentView)
    window.makeKeyAndOrderFront(nil)

    NSApp.activate(ignoringOtherApps: true)
  }
}
