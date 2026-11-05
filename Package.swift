// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "s2j-package-dashboard",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "S2JPackageDashboardCore", targets: ["S2JPackageDashboardCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "S2JPackageDashboardCore",
            path: "Sources/S2JPackageDashboardCore"
        ),
        .testTarget(
            name: "S2JPackageDashboardCoreTests",
            dependencies: ["S2JPackageDashboardCore"],
            path: "Tests/S2JPackageDashboardCoreTests"
        ),
    ]
)
