// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Syntect",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "Syntect",
            targets: ["Syntect"]
        ),
    ],
    targets: [
        .target(
            name: "Syntect",
            dependencies: ["SyntectCore"],
            path: "Sources/Syntect"
        ),
        .binaryTarget(
            name: "SyntectCore",
            path: "Binaries/ios/SyntectCore.xcframework"
        ),
        .testTarget(
            name: "SyntectTests",
            dependencies: ["Syntect"],
            path: "Tests/SyntectTests"
        ),
    ]
)