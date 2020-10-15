// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "AccountSDKIOSWeb",
    products: [
        .library(
            name: "AccountSDKIOSWeb",
            targets: ["AccountSDKIOSWeb"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AccountSDKIOSWeb",
            dependencies: []),
        .testTarget(
            name: "AccountSDKIOSWebTests",
            dependencies: ["AccountSDKIOSWeb"]),
    ]
)
