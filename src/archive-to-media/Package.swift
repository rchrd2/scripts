// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "archive-to-media",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(path: "../SwiftHelpers")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "archive-to-media",
            dependencies: ["SwiftHelpers"]),
    ]
)
