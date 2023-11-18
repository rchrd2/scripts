// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftHelpers",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .library(
      name: "SwiftHelpers",
      targets: ["SwiftHelpers"])
  ],
  targets: [
    .target(
      name: "SwiftHelpers")
  ]
)
