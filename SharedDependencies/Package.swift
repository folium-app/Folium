// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let endpoint: String = "https://github.com/folium-app/SharedDependencies/releases/download"
let `extension`: String = "xcframework.zip"

func url(for libraryName: String, with version: String = "0.0.5") -> String {
    "\(endpoint)/\(version)/\(libraryName).\(`extension`)"
}

let package = Package(
    name: "SharedDependencies",
    platforms: [
        .iOS(.v26),
    ],
    products: [
        .library(name: "SharedDependencies", targets: [
            "SharedDependencies"
        ])
    ],
    dependencies: [
        .package(url: "https://github.com/jarrodnorwell/PLzmaSDK", branch: "master"),
        .package(url: "https://github.com/krzyzanowskim/OpenSSL", branch: "main")
    ],
    targets: [
        .target(name: "SharedDependencies", dependencies: [
            "lib_fmt",
            "cereal",
            "eventbus",
            "glib",
            "libchdr",
            "magic_enum",
            "miniz",
            "stb"
        ]),
        .target(name: "cereal", publicHeadersPath: "include"),
        .target(name: "eventbus", publicHeadersPath: "include"),
        .target(name: "glib",
                publicHeadersPath: "include",
                cSettings: [
                    .unsafeFlags([
                        "-Wno-shorten-64-to-32"
                    ])
                ]),
        .target(name: "libchdr",
                dependencies: [
                    "FLAC",
                    "ogg",
                    .product(name: "PLzmaSDK-Static", package: "PLzmaSDK")
                ], publicHeadersPath: "include",
                cSettings: [
                    .unsafeFlags([
                        "-Wno-shorten-64-to-32"
                    ])
                ]),
        .target(name: "libslirp", dependencies: [
            "glib"
        ], publicHeadersPath: "include", cSettings: [
            .unsafeFlags([
                "-D_NETINET_TCP_VAR_H_",
                "-ffast-math"
            ])
        ]),
        .target(name: "magic_enum", publicHeadersPath: "include"),
        .target(name: "miniz", publicHeadersPath: "include"),
        .target(name: "stb", publicHeadersPath: "include"),
        
        .binaryTarget(name: "lib_fmt",
                      url: url(for: "lib_fmt", with: "1.0.0"),
                      checksum: "f0fc2466368ff0f69c88bb8a7d69496c2063c1198448a8059ff7696e464451d2"),
        
        .binaryTarget(name: "FLAC",
                      url: "https://github.com/sbooth/flac-binary-xcframework/releases/download/0.2.0/FLAC.xcframework.zip",
                      checksum: "87f1b13fb490867790b96d52fcbeb1a23847b8f45f50cece530d533266c2001e"),
        .binaryTarget(name: "ogg",
                      url: "https://github.com/sbooth/ogg-binary-xcframework/releases/download/0.1.3/ogg.xcframework.zip",
                      checksum: "0c06ea645c6ca187e66442717eb856c09e2b969545e880300639b41f7b83ae98")
    ],
    cLanguageStandard: .gnu2x,
    cxxLanguageStandard: .gnucxx2b
)
