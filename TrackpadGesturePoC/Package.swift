// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "TrackpadGesturePoC",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "TrackpadGesturePoC", targets: ["TrackpadGesturePoC"])
    ],
    targets: [
        .executableTarget(
            name: "TrackpadGesturePoC",
            path: "TrackpadGesturePoC/Sources"
        ),
        .testTarget(
            name: "TrackpadGesturePoCTests",
            dependencies: ["TrackpadGesturePoC"],
            path: "TrackpadGesturePoCTests"
        )
    ]
)