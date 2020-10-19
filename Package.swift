// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "AccountSDKIOSWeb",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(
            name: "AccountSDKIOSWeb",
            targets: ["AccountSDKIOSWeb"]),
    ],
    dependencies: [
        .package(url: "https://github.com/airsidemobile/JOSESwift.git", from: "2.2.1"),
        .package(url: "https://github.com/Brightify/Cuckoo.git", from: "1.4.0"),
    ],
    targets: [
        .target(
            name: "AccountSDKIOSWeb",
            dependencies: ["JOSESwift"]),
        .testTarget(
            name: "AccountSDKIOSWebTests",
            dependencies: ["AccountSDKIOSWeb", "Cuckoo"]),
    ]
)
