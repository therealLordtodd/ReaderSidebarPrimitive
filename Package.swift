// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ReaderSidebarPrimitive",
    platforms: [
        .macOS(.v13),
        .iOS(.v15),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "ReaderSidebarPrimitive",
            targets: ["ReaderSidebarPrimitive"]
        ),
    ],
    dependencies: [
        .package(path: "../ReaderChromeThemePrimitive"),
    ],
    targets: [
        .target(
            name: "ReaderSidebarPrimitive",
            dependencies: [
                .product(name: "ReaderChromeThemePrimitive", package: "ReaderChromeThemePrimitive"),
            ]
        ),
        .testTarget(
            name: "ReaderSidebarPrimitiveTests",
            dependencies: ["ReaderSidebarPrimitive"]
        ),
    ]
)
