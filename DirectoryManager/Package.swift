// swift-tools-version: 5.10.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DirectoryManager",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15)
    ],
    products: [
        .library(name: "DirectoryManager", targets: [
            "DirectoryManager"
        ])
    ],
    targets: [
        .target(name: "DirectoryManager")
    ]
)
