//
//  MainUtils.swift
//  Cowabunga Lite
//
//  Created by lemin on 5/29/23.
//

import Foundation

class MainUtils {
    enum FileLocation: String {
        // Springboard Options
        case springboard = "SpringboardOptions/ManagedPreferencesDomain/mobile/com.apple.springboard.plist"
        case footnote = "SpringboardOptions/SysSharedContainerDomain-systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/SharedDeviceConfiguration.plist"
        case wifi = "SpringboardOptions/SystemPreferencesDomain/SystemConfiguration/com.apple.wifi.plist"
        case uikit = "SpringboardOptions/HomeDomain/Library/Preferences/com.apple.UIKit.plist"
        case accessibility = "SpringboardOptions/HomeDomain/Library/Preferences/com.apple.Accessibility.plist"
        case wifiDebug = "SpringboardOptions/ManagedPreferencesDomain/mobile/com.apple.MobileWiFi.debug.plist"
        
        // Internal Options
        case globalPreferences = "InternalOptions/ManagedPreferencesDomain/mobile/hiddendotGlobalPreferences.plist"
        case appStore = "InternalOptions/HomeDomain/Library/Preferences/com.apple.AppStore.plist"
        case notes = "InternalOptions/HomeDomain/Library/Preferences/com.apple.mobilenotes.plist"
        case maps = "InternalOptions/AppDomain-com.apple.Maps/Library/Preferences/com.apple.Maps.plist"
        case weather = "InternalOptions/AppDomain-com.apple.weather/Library/Preferences/com.apple.weather.plist"
        
        // Setup Options
        case skipSetup = "SkipSetup/SysSharedContainerDomain-systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/CloudConfigurationDetails.plist"
        case ota = "SkipSetup/ManagedPreferencesDomain/mobile/com.apple.MobileAsset.plist"
    }
    
    struct ToggleOption: Identifiable {
        var id = UUID()
        var key: String
        var name: String
        var fileLocation: FileLocation
        var value: Bool = false
    }
    
    
    // MARK: Springboard Options
    public static var sbOptions: [ToggleOption] = [
        .init(key: "SBDontLockAfterCrash", name: "Disable Lock After Respring", fileLocation: .springboard),
        .init(key: "SBDontDimOrLockOnAC", name: "Disable Screen Dimming While Charging", fileLocation: .springboard),
        .init(key: "SBHideLowPowerAlerts", name: "Disable Low Battery Alerts", fileLocation: .springboard),
        .init(key: "SBControlCenterEnabledInLockScreen", name: "CC Enabled on Lock Screen", fileLocation: .springboard),
        .init(key: "StartupSoundEnabled", name: "Shutdown Sound", fileLocation: .accessibility)
    ]
    
    
    // MARK: Internal Options
    public static var internalOptions: [ToggleOption] = [
        .init(key: "UIStatusBarShowBuildVersion", name: "Build Version in Status Bar", fileLocation: .globalPreferences),
        .init(key: "NSForceRightToLeftWritingDirection", name: "Force Right to Left", fileLocation: .globalPreferences),
        .init(key: "MetalForceHudEnabled", name: "Force Metal HUD Debug", fileLocation: .globalPreferences),
        .init(key: "AccessoryDeveloperEnabled", name: "Accessory Diagnostics", fileLocation: .globalPreferences),
        .init(key: "iMessageDiagnosticsEnabled", name: "iMessage Diagnostics", fileLocation: .globalPreferences),
        .init(key: "IDSDiagnosticsEnabled", name: "IDS Diagnostics", fileLocation: .globalPreferences),
        .init(key: "VCDiagnosticsEnabled", name: "VC Diagnostics", fileLocation: .globalPreferences),
        .init(key: "debugGestureEnabled", name: "App Store Debug Gesture", fileLocation: .appStore),
        .init(key: "DebugModeEnabled", name: "Notes App Debug Mode", fileLocation: .notes)
    ]
    
    
    // MARK: Setup Option Configuration
    // Skip Setup Getter/Setter
    public static func getSkipSetupEnabled() -> Bool {
        do {
            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.skipSetup.rawValue) else {
                Logger.shared.logMe("Error finding cloud configuration details plist")
                return false
            }
            return try PlistManager.getPlistValues(url: plistURL, key: "CloudConfigurationUIComplete") as? Bool ?? false
        } catch {
            Logger.shared.logMe(error.localizedDescription)
            return false
        }
    }
    public static func setSkipSetup(nv: Bool) {
        guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.skipSetup.rawValue) else {
            Logger.shared.logMe("Error finding cloud configuration details plist")
            return
        }
        if nv {
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
                Logger.shared.logMe(error.localizedDescription)
                return
            }
        } else {
            do {
                try PlistManager.setPlistValues(url: plistURL, values: [
                    "CloudConfigurationUIComplete": false,
                    "SkipSetup": []
                ])
            } catch {
                Logger.shared.logMe(error.localizedDescription)
                return
            }
        }
    }
    
    // OTA Blocker Getter/Setter
    public static func getOTABlocked() -> Bool {
        do {
            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.ota.rawValue) else {
                Logger.shared.logMe("Error finding springboard plist")
                return false
            }
            guard let data = fm.contents(atPath: plistURL.path) else {
                Logger.shared.logMe("Can't read plist")
                return false
            }
            let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            if let dictionary = plist as? [String: Any], dictionary.isEmpty {
                return false
            } else {
                return true
            }
        } catch {
            Logger.shared.logMe("Error finding springboard plist")
            return false
        }
    }
    public static func setOTABlocked(nv: Bool) {
        if nv {
            do {
                guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.ota.rawValue) else {
                    Logger.shared.logMe("Error finding MobileAsset plist")
                    return
                }
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
                Logger.shared.logMe("Error disabling ota preferences: \(error.localizedDescription)")
                return
            }
        } else {
            do {
                guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.ota.rawValue) else {
                    Logger.shared.logMe("Error finding MobileAsset plist")
                    return
                }
                let newData = try PropertyListSerialization.data(fromPropertyList: [:], format: .xml, options: 0)
                try newData.write(to: plistURL)
            } catch {
                Logger.shared.logMe("Error enabling ota preferences: \(error.localizedDescription)")
                return
            }
        }
    }
    
    // Supervision Getter/Setter
    public static func getSupervisionEnabled() -> Bool {
        do {
            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.skipSetup.rawValue) else {
                Logger.shared.logMe("Error finding cloud configuration details plist")
                return false
            }
            return try PlistManager.getPlistValues(url: plistURL, key: "IsSupervised") as? Bool ?? false
        } catch {
            Logger.shared.logMe(error.localizedDescription)
            return false
        }
    }
    public static func setSupervision(nv: Bool) {
        guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.skipSetup.rawValue) else {
            Logger.shared.logMe("Error finding cloud configuration details plist")
            return
        }
        do {
            try PlistManager.setPlistValues(url: plistURL, values: [
                "IsSupervised": nv
            ])
        } catch {
            Logger.shared.logMe(error.localizedDescription)
            return
        }
    }
    
    // Organization Name Getter/Setter
    public static func getOrganizationName() -> String {
        do {
            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.skipSetup.rawValue) else {
                Logger.shared.logMe("Error finding cloud configuration details plist")
                return ""
            }
            return try PlistManager.getPlistValues(url: plistURL, key: "OrganizationName") as? String ?? ""
        } catch {
            Logger.shared.logMe(error.localizedDescription)
            return ""
        }
    }
    public static func setOrganizationName(nv: String) {
        do {
            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.skipSetup.rawValue) else {
                Logger.shared.logMe("Error finding cloud configuration details plist")
                return
            }
            try PlistManager.setPlistValues(url: plistURL, values: [
                "OrganizationName": nv
            ])
        } catch {
            Logger.shared.logMe(error.localizedDescription)
            return
        }
    }
}
