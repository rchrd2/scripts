// https://gist.github.com/wakewakame/d1346d67ee2a8f81bc23cc837d0c1c48

import SwiftUI

NSApplication.shared.run {
  VStack {
    Text("Hello, World")
      .padding()
      .background(Capsule().fill(Color.blue))
      .padding()
  }
  .frame(maxWidth: .infinity, maxHeight: .infinity)
}

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
