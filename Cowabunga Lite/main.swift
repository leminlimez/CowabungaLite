//
//  main.swift
//  CowabungaCLI
//
//  Created by Mineek on 16/04/2023.
//

import Foundation

print("=== Cowabunga Lite CLI ===")
#if CLI
print("Correctly compiled for CLI")
#endif
let args = CommandLine.arguments
if args.count < 3 {
    print("usage: CowabungaLite <uuid> <tweak1>=<tweak1data> <tweak2>=<tweak2data> ...")
    exit(1)
}
let dataSingleton = DataSingleton.shared
let tweaks = args[2...].map { $0.split(separator: "=") }.map { (key: String($0[0]), value: String($0[1])) }
print("Enabled tweaks: \(tweaks.map { $0.key }.joined(separator: ", "))")
print("With values: \(tweaks.map { $0.value }.joined(separator: ", "))")
dataSingleton.setTweakEnabled(.springboardOptions, isEnabled: true)
print("Configuring tweaks...")
enum FileLocation: String {
    case springboard = "SpringboardOptions/ManagedPreferencesDomain/mobile/com.apple.springboard.plist"
    case footnote = "SpringboardOptions/SysSharedContainerDomain-systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/SharedDeviceConfiguration.plist"
    case ota = "SpringboardOptions/ManagedPreferencesDomain/mobile/com.apple.MobileAsset.plist"
    case mute = "SpringboardOptions/ManagedPreferencesDomain/mobile/com.apple.control-center.MuteModule.plist"
    case globalPreferences = "SpringboardOptions/ManagedPreferencesDomain/mobile/hiddendotGlobalPreferences.plist"
    case wifi = "SpringboardOptions/SystemPreferencesDomain/SystemConfiguration/com.apple.wifi.plist"
    case uikit = "SpringboardOptions/HomeDomain/Library/Preferences/com.apple.UIKit.plist"
}
struct SBOption: Identifiable {
    var id = UUID()
    var key: String
    var name: String
    var fileLocation: FileLocation
    var value: Bool = false
}
struct NormalTweak: Identifiable {
    var id = UUID()
    var name: String
    var value: String
    var enabled: Bool = false
}
private var sbOptions: [SBOption] = [
    .init(key: "SBDontLockAfterCrash", name: "Disable Lock After Respring", fileLocation: .springboard),
    .init(key: "SBDontDimOrLockOnAC", name: "Disable Screen Dimming While Charging", fileLocation: .springboard),
    .init(key: "SBHideLowPowerAlerts", name: "Disable Low Battery Alerts", fileLocation: .springboard),
    .init(key: "SBIconVisibility", name: "Mute Module in CC", fileLocation: .mute),
    .init(key: "UIStatusBarShowBuildVersion", name: "Build Version in Status Bar", fileLocation: .globalPreferences),
    .init(key: "AccessoryDeveloperEnabled", name: "Accessory Developer", fileLocation: .globalPreferences),
    .init(key: "kWiFiShowKnownNetworks", name: "Show Known WiFi Networks", fileLocation: .wifi),
    .init(key: "SBDisableNotificationCenterBlur", name: "Disable Notif Center Blur", fileLocation: .springboard),
    .init(key: "SBControlCenterEnabledInLockScreen", name: "CC Enabled on Lock Screen", fileLocation: .springboard),
    .init(key: "SBControlCenterDemo", name: "CC AirPlay Radar", fileLocation: .springboard)
]
private var normalTweaks: [NormalTweak] = [
    .init(name: "LockScreenFootnote", value: "string", enabled: false),
    .init(name: "AnimationSpeed", value: "double", enabled: false),
    .init(name: "DisableOTAUpdates", value: "bool", enabled: false),
    .init(name: "SkipSetup", value: "bool", enabled: false),
]
print("Available tweaks: \(sbOptions.map { $0.key }.joined(separator: ", ")), \(normalTweaks.map { $0.name }.joined(separator: ", "))")
setupWorkspaceForUUID(args[1])
for tweak in tweaks {
    if !sbOptions.contains(where: { $0.key == tweak.key }) {
        if !normalTweaks.contains(where: { $0.name == tweak.key }) {
            print("Invalid tweak: \(tweak.key)")
            exit(1)
        }
    }
}
for tweak in tweaks {
    if var sbTweak = sbOptions.first(where: { $0.key == tweak.key }) {
        sbTweak.value = true
        sbOptions[sbOptions.firstIndex(where: { $0.key == tweak.key })!] = sbTweak
    }
    if var normalTweak = normalTweaks.first(where: { $0.name == tweak.key }) {
        normalTweak.enabled = true
        normalTweak.value = tweak.value
        normalTweaks[normalTweaks.firstIndex(where: { $0.name == tweak.key })!] = normalTweak
    }
}
// check if the values are the correct type
for tweak in tweaks {
    if let sbOption = sbOptions.first(where: { $0.key == tweak.key }) {
        if sbOption.value {
            if tweak.value != "true" && tweak.value != "false" {
                print("Invalid value for tweak: \(tweak.key)")
                exit(1)
            }
        }
    }
    if let normalTweak = normalTweaks.first(where: { $0.name == tweak.key }) {
        if normalTweak.enabled {
            if normalTweak.value == "string" {
                if tweak.value.first != "\"" || tweak.value.last != "\"" {
                    print("Invalid value for tweak: \(tweak.key)")
                    exit(1)
                }
            } else if normalTweak.value == "double" {
                if Double(tweak.value) == nil {
                    print("Invalid value for tweak: \(tweak.key)")
                    exit(1)
                }
            } else if normalTweak.value == "bool" {
                if tweak.value != "true" && tweak.value != "false" {
                    print("Invalid value for tweak: \(tweak.key)")
                    exit(1)
                }
            }
        }
    }
}
for sbTweak in sbOptions {
    if sbTweak.value {
        guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(sbTweak.fileLocation.rawValue) else {
            print("Error finding \(sbTweak.fileLocation.rawValue)")
            exit(1)
        }
        do {
            try PlistManager.setPlistValues(url: plistURL, values: [
                sbTweak.key: sbTweak.value
            ])
        } catch {
            print(error.localizedDescription)
            exit(1)
        }
    }
}
for normalTweak in normalTweaks {
    if normalTweak.enabled {
        switch normalTweak.name {
        case "SkipSetup":
            dataSingleton.setTweakEnabled(.skipSetup, isEnabled: true)
            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent("SkipSetup/SysSharedContainerDomain-systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/CloudConfigurationDetails.plist") else {
                print("Error finding cloud configuration details plist")
                exit(1)
            }
            do {
                try PlistManager.setPlistValues(url: plistURL, values: [
                    "CloudConfigurationUIComplete": true,
                    "SkipSetup": [
                        "Diagnostics",
                        "WiFi",
                        "AppleID",
                        "Siri",
                        "Restore",
                        "SoftwareUpdate",
                        "Welcome",
                        "Appearance",
                        "Privacy",
                        "SIMSetup",
                        "OnBoarding",
                        "Zoom",
                        "Biometric",
                        "ScreenTime",
                        "Payment",
                        "Passcode",
                        "Display",
                    ]
                ])
            } catch {
                print(error.localizedDescription)
                exit(1)
            }
        case "DisableOTAUpdates":
            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.ota.rawValue) else {
                print("Error finding MobileAsset plist")
                exit(1)
            }
            do {
                try PlistManager.setPlistValues(url: plistURL, values: [
                    "MobileAssetServerURL-com.apple.MobileAsset.MobileSoftwareUpdate.UpdateBrain": "https://mesu.apple.com/assets/tvOS16DeveloperSeed",
                    "MobileAssetSUAllowOSVersionChange": false,
                    "MobileAssetSUAllowSameVersionFullReplacement": false,
                    "MobileAssetServerURL-com.apple.MobileAsset.RecoveryOSUpdate": "https://mesu.apple.com/assets/tvOS16DeveloperSeed",
                    "MobileAssetServerURL-com.apple.MobileAsset.RecoveryOSUpdateBrain": "https://mesu.apple.com/assets/tvOS16DeveloperSeed",
                    "MobileAssetServerURL-com.apple.MobileAsset.SoftwareUpdate": "https://mesu.apple.com/assets/tvOS16DeveloperSeed",
                    "MobileAssetAssetAudience": "65254ac3-f331-4c19-8559-cbe22f5bc1a6"
                ])
            } catch {
                print(error.localizedDescription)
                exit(1)
            }
        case "LockScreenFootnote":
            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.footnote.rawValue) else {
                print("Error finding footnote plist")
                exit(1)
            }
            do {
                try PlistManager.setPlistValues(url: plistURL, values: [
                    "LockScreenFootnote": normalTweak.value
                ])
            } catch {
                print(error.localizedDescription)
                exit(1)
            }
        case "AnimationSpeed":
            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.uikit.rawValue) else {
                print("Error finding UIKit plist")
                exit(1)
            }
            do {
                try PlistManager.setPlistValues(url: plistURL, values: [
                    "UIAnimationDragCoefficient": Double(normalTweak.value) ?? 1
                ])
            } catch {
                print(error.localizedDescription)
                exit(1)
            }
        default:
            print("Invalid tweak: \(normalTweak.name)")
            exit(1)
        }
    }
}
print("Configuring tweaks... Done")
print("Enabled tweaks: \(sbOptions.filter { $0.value }.map { $0.name }.joined(separator: ", ")), \(normalTweaks.filter { $0.enabled }.map { $0.name }.joined(separator: ", "))")
applyTweaks()
print("Applying tweaks... Done")
print("Done")
print("Restore using: idevicebackup2.exe -u \(args[1]) -s Backup restore --system --skip-apps \(documentsDirectory.path)")
exit(0)
