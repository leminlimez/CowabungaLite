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
                "Libraries",
                "Preview Content",
                "Assets.xcassets",
                "CowabungaJailed.entitlements",
                "CowabungaLiteApp.swift",
                "ControlCenterPresets",
                "CLI_Only.swift",
                "Extensions/NSImage++.swift"
            ],
            resources: [
                .copy("Files"),

                .process("Windows_Scripts/WINidevice_id.exe"),
                .process("Windows_Scripts/WINidevicebackup2.exe"),
                .process("Windows_Scripts/WINideviceinfo.exe"),
                .process("Windows_Scripts/WINidevicename.exe"),

                .process("Windows_Scripts/libimobiledevice-1.0.dll"),
                .process("Windows_Scripts/libcrypto-3-x64.dll"),
                .process("Windows_Scripts/libimobiledevice-glue-1.0.dll"),
                .process("Windows_Scripts/libplist-2.0.dll"),
                .process("Windows_Scripts/libssl-3-x64.dll"),
                .process("Windows_Scripts/libusbmuxd-2.0.dll"),
            ],
            swiftSettings: [
                .unsafeFlags(["-D", "CLI"])
            ]),
    ]
)
