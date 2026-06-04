// swift-tools-version: 6.0
import PackageDescription

// boring.notch is a SwiftUI macOS app that is built with Xcode via
// boringNotch.xcodeproj. This lightweight SwiftPM package exists only so
// generic Swift CI checks that invoke `swift build` can complete in this
// repository without attempting to compile the macOS app target on Linux.
let package = Package(
    name: "boring-notch-build-support",
    platforms: [.macOS(.v14)],
    targets: [
        .target(name: "BoringNotchBuildSupport")
    ]
)
