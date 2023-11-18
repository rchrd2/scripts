// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "play8-bounce",
  platforms: [
    .macOS(.v14)
  ],
  dependencies: [
    .package(path: "../SwiftHelpers")
  ],
  targets: [
    .executableTarget(
      name: "play8-bounce",
      dependencies: ["SwiftHelpers"]
    )
  ]
)
