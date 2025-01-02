// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Cherry",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16)
    ],
    products: [
        .library(name: "Cherry", targets: [
            "Cherry"
        ]),
        .library(name: "CherryCXX", targets: [
            "CherryCXX"
        ]),
        .library(name: "CherryObjC", targets: [
            "CherryObjC"
        ])
    ],
    targets: [
        .target(name: "Cherry", dependencies: [
            "CherryObjC"
        ]),
        .target(name: "CherryCXX", sources: [
            "common",
            "core",
            "core/bus",
            "core/ee/cpu",
            "core/ee/dmac",
            "core/ee/gif",
            "core/ee/ipu",
            "core/ee/pgif",
            "core/ee/timer",
            "core/ee/vif",
            "core/ee/vu",
            "core/gs",
            "core/iop",
            "core/iop/cdrom",
            "core/iop/cdvd",
            "core/iop/dmac",
            "core/iop/sio2",
            "core/iop/spu2",
            "core/iop/timer"
        ], publicHeadersPath: "include"),
        .target(name: "CherryObjC", dependencies: [
            "CherryCXX"
        ], publicHeadersPath: "include")
    ],
    cLanguageStandard: .c2x,
    cxxLanguageStandard: .cxx2b
)
