// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "hex-swift",
    products: [
        .library(
            name: "Hex",
            targets: ["Hex"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/nixberg/simd-extras-swift",
            branch: "main"),
    ],
    targets: [
        .target(
            name: "Hex",
            dependencies: [
                .product(name: "SIMDExtras", package: "simd-extras-swift"),
            ]),
        .testTarget(
            name: "HexTests",
            dependencies: ["Hex"]),
    ]
)
