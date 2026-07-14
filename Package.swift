// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MediaTrackingKiller",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "MediaTrackingKiller", targets: ["MediaTrackingKiller"]),
    ],
    dependencies: [
        .package(path: "../StatusItemKit"),
    ],
    targets: [
        .executableTarget(
            name: "MediaTrackingKiller",
            dependencies: [.product(name: "StatusItemKit", package: "StatusItemKit")]
        ),
    ]
)
