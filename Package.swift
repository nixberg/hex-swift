// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Hex",
    products: [
        .library(
            name: "Hex",
            targets: ["Hex"]),
    ],
    targets: [
        .target(
            name: "Hex"),
        .testTarget(
            name: "HexTests",
            dependencies: ["Hex"]),
    ]
)
