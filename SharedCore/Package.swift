// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SharedCore",
    platforms: [.iOS(.v18), .watchOS(.v11), .macOS(.v14)],
    products: [
        .library(name: "SharedCore", targets: ["SharedCore"]),
    ],
    targets: [
        .target(name: "SharedCore"),
        .testTarget(name: "SharedCoreTests", dependencies: ["SharedCore"]),
    ]
)
