// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "AccountSDKIOSWeb",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "AccountSDKIOSWeb",
            targets: ["AccountSDKIOSWeb"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/airsidemobile/JOSESwift.git", from: "3.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.2"),
        .package(url: "https://github.com/Brightify/Cuckoo.git", exact: "2.0.18")
    ],
    targets: [
        .target(
            name: "AccountSDKIOSWeb",
            dependencies: [
                "JOSESwift",
                .product(name: "Logging", package: "swift-log")
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "AccountSDKIOSWebTests",
            dependencies: [
                "AccountSDKIOSWeb",
                "Cuckoo"
            ]
        )
    ]
)
