// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DEToolkit",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "DEToolkit",
            targets: ["DEToolkit"]
        ),
    ],
    targets: [
        .target(name: "DEToolkit"),
        .testTarget(
            name: "DEToolkitTests",
            dependencies: ["DEToolkit"]
        ),
    ]
)
