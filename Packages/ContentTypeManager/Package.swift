// swift-tools-version: 5.10.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ContentTypeManager",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15)
    ],
    products: [
        .library(name: "ContentTypeManager", targets: ["ContentTypeManager"])
    ],
    targets: [
        .target(name: "ContentTypeManager")

    ]
)
