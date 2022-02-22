// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "AccountSDKIOSWeb",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "AccountSDKIOSWeb",
            targets: ["AccountSDKIOSWeb"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/airsidemobile/JOSESwift.git", from: "2.3.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
        .package(url: "https://github.schibsted.io/spt-dataanalytics/pulse-tracker-ios", from: "7.0.9") //internal github. API key for read access is needed
    ],
    targets: [
        .target(
            name: "AccountSDKIOSWeb",
            dependencies: ["JOSESwift", .product(name: "Logging", package: "swift-log"), .product(name: "SchibstedTracking", package: "pulse-tracker-ios")],
            resources: [.process("Resources")],
            swiftSettings: [.define("SPM")]
        )
    ]
)
