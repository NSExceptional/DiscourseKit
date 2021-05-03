// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DiscourseKit",
    platforms: [.macOS(.v10_13), .iOS(.v11), .tvOS(.v11)],
    products: [
        .library(name: "DiscourseKit", type: .dynamic, targets: ["DiscourseKit"])
    ],
    targets: [
        .target(
            name: "DiscourseKit",
            dependencies: ["Networking"],
            path: "Sources/DiscourseKit"
        ),
        .target(
            name: "Networking",
            dependencies: ["Extensions"],
            path: "Sources/Networking"
        ),
        .target(name: "Extensions", path: "Sources/Extensions"),
        .testTarget(name: "DiscourseKitTests", dependencies: ["DiscourseKit"])
    ],
    swiftLanguageVersions: [.v5]
)
