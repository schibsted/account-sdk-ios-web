// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SchibstedAccount",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "SchibstedAccount",
            targets: ["SchibstedAccount"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.2"),
        .package(url: "https://github.com/airsidemobile/JOSESwift.git", from: "3.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.4")
    ],
    targets: [
        .target(
            name: "SchibstedAccount",
            dependencies: [
                .product(name: "JOSESwift", package: "JOSESwift"),
                .product(name: "Logging", package: "swift-log")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SchibstedAccountTests",
            dependencies: [
                "SchibstedAccount",
                .product(name: "JOSESwift", package: "JOSESwift"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        )
    ]
)
