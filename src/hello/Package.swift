// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "hello",
  platforms: [
    .macOS(.v14)
  ],
  dependencies: [
    .package(path: "../SwiftHelpers")
  ],
  targets: [
    .executableTarget(
      name: "hello",
      dependencies: ["SwiftHelpers"]
    )
  ]
)
