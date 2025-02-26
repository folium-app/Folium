// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Peach",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15)
    ],
    products: [
        .library(name: "Peach", targets: ["Peach"]),
        .library(name: "PeachCXX", targets: ["PeachCXX"]),
        .library(name: "PeachObjC", targets: ["PeachObjC"])
    ],
    targets: [
        .target(name: "Peach", dependencies: ["PeachObjC"]),
        .target(name: "PeachCXX", sources: ["", "mappers"], publicHeadersPath: "include"),
        .target(name: "PeachObjC", dependencies: ["PeachCXX"])
    ],
    cLanguageStandard: .c2x,
    cxxLanguageStandard: .cxx2b
)
