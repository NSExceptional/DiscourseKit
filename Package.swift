// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DiscourseKit",
    platforms: [.macOS(.v10_13), .iOS(.v11), .tvOS(.v11)],
    products: [
        .library(name: "DiscourseKit", targets: ["DiscourseKit"])
    ],
    targets: [
        .target(
            name: "DiscourseKit",
            dependencies: ["Networking"],
            sources: ["DiscourseKit.swift"]
        ),
        .target(
            name: "Networking",
            dependencies: ["Extensions", "Model"],
            path: "Sources/DiscourseKit/Networking"
        ),
        .target(name: "Model", path: "Sources/DiscourseKit/Model"),
        .target(name: "Extensions", path: "Sources/DiscourseKit/Extensions"),
        .testTarget(name: "DiscourseKitTests", dependencies: ["DiscourseKit"])
    ],
    swiftLanguageVersions: [.v5]
)
