// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SharedCore",
    defaultLocalization: "en",
    platforms: [.iOS(.v18), .watchOS(.v11), .macOS(.v14)],
    products: [
        .library(name: "SharedCore", targets: ["SharedCore"]),
    ],
    targets: [
        .target(
            name: "SharedCore",
            resources: [.process("Localizable.xcstrings")]
        ),
        .testTarget(name: "SharedCoreTests", dependencies: ["SharedCore"]),
    ]
)
