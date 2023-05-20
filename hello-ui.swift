// https://forums.swift.org/t/write-swiftui-command-line-scripts/38305
// https://gist.github.com/GeorgeLyon/bbd443dcabef5ca5ae71ae83db6524ef

// Displays UI in an NSWindow which can interact with the commandline
// Usage: `echo "Bar" | ./hello-ui.swift`

import Foundation
import SwiftUI

extension CommandLine {
  static let input: String = { AnyIterator { readLine() }.joined() }()
}

struct App: SwiftUI.App {
  var body: some Scene {
    WindowGroup {
      VStack {
        Text("Hello, UI!")
        Button("Print \"Foo\"") { print("Foo") }
        Button("Echo Input") { print(CommandLine.input) }
        Button("Done") { exit(0) }
      }
      .padding(100)
    }
    .windowStyle(HiddenTitleBarWindowStyle())
  }
}
App.main()
