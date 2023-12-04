// swift-tools-version:5.7.1

import PackageDescription

let package = Package(
    name: "mymusic-git",
    products: [
        .library(
            name: "mymusic-git",
            targets: ["mymusic-git"]),
    ],
    targets: [
        .target(
            name: "mymusic-git"),
        .testTarget(
            name: "mymusic-gitTests",
            dependencies: ["mymusic-git"]),
    ]
)
