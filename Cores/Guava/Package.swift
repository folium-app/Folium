// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Guava",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15)
    ],
    products: [
        .library(name: "Guava", targets: ["Guava"]),
        .library(name: "GuavaCXX", targets: ["GuavaCXX"]),
        .library(name: "GuavaObjC", targets: ["GuavaObjC"])
    ],
    targets: [
        .binaryTarget(name: "fmt", path: "../../Dependencies/XCFrameworks/libfmt.xcframework"),
        .target(name: "Guava", dependencies: [
            "GuavaObjC"
        ]),
        .target(name: "GuavaCXX", dependencies: [
            "fmt"
        ], publicHeadersPath: "include", cxxSettings: [
            .unsafeFlags([
                "-Wall",
                "-Wextra",
                "-Wshadow"
            ])
        ]),
        .target(name: "GuavaObjC", dependencies: [
            "GuavaCXX"
        ], publicHeadersPath: "include")
    ],
    cLanguageStandard: .c2x,
    cxxLanguageStandard: .cxx2b
)
