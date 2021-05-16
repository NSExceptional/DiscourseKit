// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DiscourseKit",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13)],
    products: [
        .library(name: "DiscourseKit", type: .static, targets: ["DiscourseKit"])
    ],
//    dependencies: [
//        .package(path: "/Users/tanner/Repos/Jsum"),
//        .package(url: "https://github.com/groue/CombineExpectations", from: "0.7.0")
//    ],
    dependencies: [
        .package(url: "https://github.com/NSExceptional/Jsum", .branch("master")),
        .package(url: "https://github.com/groue/CombineExpectations", from: "0.7.0")
    ],
    targets: [
        .target(
            name: "DiscourseKit",
            dependencies: ["Networking", "Jsum"],
            path: "Sources/DiscourseKit"
        ),
        .target(
            name: "Networking",
            dependencies: ["Extensions"],
            path: "Sources/Networking"
        ),
        .target(name: "Extensions", path: "Sources/Extensions"),
        .testTarget(
            name: "DiscourseKitTests",
            dependencies: ["DiscourseKit", "CombineExpectations"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
