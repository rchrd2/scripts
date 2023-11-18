// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "upload-transit",
  platforms: [
    .macOS(.v14)
  ],
  dependencies: [
    .package(path: "../SwiftHelpers")
  ],
  targets: [
    .executableTarget(
      name: "upload-transit",
      dependencies: ["SwiftHelpers"]
    )
  ]
)
