// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FUIAlertKit",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15)
    ],
    products: [
        .library(name: "FUIAlertKit", targets: [
            "FUIAlertKit"
        ]),
    ],
    dependencies: [
        .package(url: "https://github.com/juliensagot/uikit-blur-view", branch: "main")
    ],
    targets: [
        .target(name: "FUIAlertKit", dependencies: [
            .product(name: "BlurView", package: "uikit-blur-view")
        ])
    ]
)
