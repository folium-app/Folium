// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LayoutManager",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16)
    ],
    products: [
        .library(name: "LayoutManager", targets: [
            "LayoutManager"
        ])
    ],
    targets: [
        .target(name: "LayoutManager")
    ]
)
