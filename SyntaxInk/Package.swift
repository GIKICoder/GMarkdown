// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SyntaxInk",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(name: "SwiftSyntaxInk", targets: ["SwiftSyntaxInk"]),
        .library(name: "SyntaxInk", targets: ["SyntaxInk"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.0"),
    ],
    targets: [
        .target(
            name: "SwiftSyntaxInk",
            dependencies: [
                "SyntaxInk",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax")
            ]
        ),
        .target(name: "SyntaxInk"),
        .testTarget(name: "SyntaxInkTests", dependencies: ["SyntaxInk"]),
    ]
)
