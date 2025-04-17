// swift-tools-version: 5.10.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GLatexRender",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GLatexRender",
            targets: ["GLatexRender"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GLatexRender",
            resources: [
                .copy("mathjax/*"),
                .copy("mathjax/MathJax.js"),
                .copy("Assets/MathJaxRenderer.html"),
            ]),
        .testTarget(
            name: "GLatexRenderTests",
            dependencies: ["GLatexRender"]
        ),
    ]
)
