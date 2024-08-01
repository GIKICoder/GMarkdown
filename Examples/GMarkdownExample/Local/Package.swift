// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Local",
  platforms: [.iOS(.v13)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "Local",
      targets: ["Local"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-markdown.git", from: "0.4.0"),
    .package(url: "https://github.com/mgriebling/SwiftMath.git", from: "1.4.0"),
    .package(url: "https://github.com/meitu/MPITextKit.git", from: "0.1.13"),
    .package(url: "https://github.com/raspu/Highlightr.git", from: "2.2.1"),
    
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Local",
      dependencies: [
        .product(name: "Markdown", package: "swift-markdown"),
        .product(name: "MPITextKit", package: "MPITextKit"),
        .product(name: "SwiftMath", package: "SwiftMath"),
        .product(name: "Highlightr", package: "Highlightr"),
      ]
    ),
    .testTarget(
      name: "LocalTests",
      dependencies: ["Local"]),
  ]
)
