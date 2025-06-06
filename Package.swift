// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TrackpadGesturePoC",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "TrackpadGesturePoC",
            targets: ["TrackpadGesturePoC"]),
    ],
    dependencies: [
    ],
    targets: [
        .executableTarget(
            name: "TrackpadGesturePoC",
            dependencies: []),
        .testTarget(
            name: "TrackpadGesturePoCTests",
            dependencies: ["TrackpadGesturePoC"]),
    ]
)