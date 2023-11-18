// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// https://developer.apple.com/documentation/packagedescription/package

import PackageDescription

let package = Package(
  name: "import-audio",
  platforms: [
    .macOS(.v14)
  ],
  dependencies: [
    .package(path: "../SwiftHelpers")
  ],
  targets: [
    .executableTarget(
      name: "import-audio",
      dependencies: ["SwiftHelpers"]
    )
  ]
)
