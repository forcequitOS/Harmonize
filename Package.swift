// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Playcuts",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Playcuts",
            targets: ["Playcuts"]),
    ],
    dependencies: [
        .package(url: "https://github.com/httpswift/swifter.git", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "Playcuts",
            dependencies: [
                .product(name: "Swifter", package: "swifter")
            ],
            path: "Sources"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
