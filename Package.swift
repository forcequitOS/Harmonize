// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Harmonize",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Harmonize",
            targets: ["Harmonize"]),
    ],
    dependencies: [
        .package(url: "https://github.com/httpswift/swifter.git", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "Harmonize",
            dependencies: [
                .product(name: "Swifter", package: "swifter")
            ],
            path: "Sources"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
