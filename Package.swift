// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftMockGenerator",
    platforms: [
        .macOS(.v12),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-syntax", from: "509.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "SwiftMockGenerator",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "SwiftMockGeneratorTests",
            dependencies: ["SwiftMockGenerator"]
        ),
    ]
)
