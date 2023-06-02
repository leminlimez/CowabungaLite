// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CowabungaLite",
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "CowabungaLite",
            path: "Cowabunga Lite",
            exclude: [
                "Extensions/UtilityViews.swift",
                "Views",
                "StatusManager",
                "API",
                "Controllers/IconTheming",
                "Scripts",
                "Files",
                "Libraries",
                "Preview Content",
                "Assets.xcassets",
                "CowabungaJailed.entitlements",
                "CowabungaLiteApp.swift",
                "ControlCenterPresets",
                "CLI_Only.swift"
            ],
            swiftSettings: [
                .unsafeFlags(["-D", "CLI"])
            ]),
    ]
)
