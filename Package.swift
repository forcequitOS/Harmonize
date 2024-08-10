// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Playcuts",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Playcuts",
            targets: ["Playcuts"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/httpswift/swifter.git", from: "1.5.0")
    ],
    targets: [
        .target(
            name: "Playcuts",
            dependencies: ["Swifter"],
            path: "Sources"
        )
    ]
)
