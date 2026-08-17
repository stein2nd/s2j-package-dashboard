// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "s2j-package-dashboard",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "s2j-package-dashboard", targets: ["s2j-package-dashboard"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ]
)