// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Adyen3DS2_Swift",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "Adyen3DS2_Swift",
            targets: ["Adyen3DS2_Swift"]
        )
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "Adyen3DS2_Swift",
            path: "XCFramework/Dynamic/Adyen3DS2_Swift.xcframework"
        )
    ]
)
