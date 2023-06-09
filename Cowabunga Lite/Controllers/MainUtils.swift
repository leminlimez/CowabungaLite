//
//  MainUtils.swift
//  Cowabunga Lite
//
//  Created by lemin on 5/29/23.
//

import Foundation

class MainUtils {
    enum FileLocation: String {
        // Control Center
        case mute = "ControlCenter/ManagedPreferencesDomain/mobile/com.apple.control-center.MuteModule.plist"
        case focus = "ControlCenter/ManagedPreferencesDomain/mobile/com.apple.FocusUIModule.plist"
        case spoken = "ControlCenter/ManagedPreferencesDomain/mobile/com.apple.siri.SpokenNotificationsModule.plist"
        case moduleConfig = "ControlCenter/HomeDomain/Library/ControlCenter/ModuleConfiguration.plist"
        
        // Springboard Options
        case springboard = "SpringboardOptions/ManagedPreferencesDomain/mobile/com.apple.springboard.plist"
        case footnote = "SpringboardOptions/ConfigProfileDomain/Library/ConfigurationProfiles/SharedDeviceConfiguration.plist"
        case wifi = "SpringboardOptions/SystemPreferencesDomain/SystemConfiguration/com.apple.wifi.plist"
        case uikit = "SpringboardOptions/HomeDomain/Library/Preferences/com.apple.UIKit.plist"
        case accessibility = "SpringboardOptions/HomeDomain/Library/Preferences/com.apple.Accessibility.plist"
        case wifiDebug = "SpringboardOptions/ManagedPreferencesDomain/mobile/com.apple.MobileWiFi.debug.plist"
        case airdrop = "SpringboardOptions/ManagedPreferencesDomain/mobile/com.apple.sharingd.plist"
        
        // Internal Options
        case globalPreferences = "InternalOptions/ManagedPreferencesDomain/mobile/hiddendotGlobalPreferences.plist"
        case appStore = "InternalOptions/HomeDomain/Library/Preferences/com.apple.AppStore.plist"
        case notes = "InternalOptions/HomeDomain/Library/Preferences/com.apple.mobilenotes.plist"
        case maps = "InternalOptions/AppDomain-com.apple.Maps/Library/Preferences/com.apple.Maps.plist"
        case weather = "InternalOptions/AppDomain-com.apple.weather/Library/Preferences/com.apple.weather.plist"
        
        // Setup Options
        case skipSetup = "SkipSetup/ConfigProfileDomain/Library/ConfigurationProfiles/CloudConfigurationDetails.plist"
        case ota = "SkipSetup/ManagedPreferencesDomain/mobile/com.apple.MobileAsset.plist"
    }
    
    struct ToggleOption: Identifiable {
        var id = UUID()
        var key: String
        var name: String
        var fileLocation: FileLocation
        var value: Bool = false
        var dividerBelow: Bool = false
    }
    
    struct ConfigPreset: Identifiable {
        var id = UUID()
        var title: String
        var identification: String
        var fileLocation: URL?
        var modulesToEnable: [Int] // based on module ID
        var author: String?
    }
    
    public static func loadToggles(from array: [ToggleOption], workspace: URL) -> [ToggleOption] {
        var newArray: [ToggleOption] = array
        for (i, opt) in array.enumerated() {
            let plistURL = workspace.appendingPathComponent(opt.fileLocation.rawValue)
            do {
                if opt.key == "WiFiManagerLoggingEnabled" {
                    newArray[i].value = (try PlistManager.getPlistValues(url: plistURL, key: opt.key) as? String ?? "false" == "true")
                } else if opt.key == "DiscoverableMode" {
                    newArray[i].value = (try PlistManager.getPlistValues(url: plistURL, key: opt.key) as? String ?? "" == "Everyone")
                } else {
                    newArray[i].value = try PlistManager.getPlistValues(url: plistURL, key: opt.key) as? Bool ?? false
                }
            } catch {
                
            }
        }
        return newArray
    }
    
    // Load the preferences
    #if CLI
    public static func loadPreferences() {
        if let workspace = DataSingleton.shared.getCurrentWorkspace() {
            // Icon Theming
            IconThemingPage.loadPreferences()
            
            // Control Center
            for (i, module) in moduleTypes.enumerated() {
                do {
                    guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(module.fileLocation.rawValue) else { continue }
                    moduleTypes[i].value =  try PlistManager.getPlistValues(url: plistURL, key: "SBIconVisibility") as? Bool ?? false
                } catch {
                    
                }
            }
            do {
                if let filePath = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.moduleConfig.rawValue) {
                    if FileManager.default.fileExists(atPath: filePath.path) {
                        let plistData = try Data(contentsOf: filePath)
                        let plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
                        if let pIdentifier = plist["preset-identifiers"] as? [String: Any], let pID = pIdentifier["identification"] as? String {
                            selectedCCPreset = pID
                        } else {
                            selectedCCPreset = "None"
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
                selectedCCPreset = "None"
            }
            
            // Springboard Options
            sbOptions = loadToggles(from: sbOptions, workspace: workspace)
            do {
                sbAnimationSpeed = try PlistManager.getPlistValues(url: workspace.appendingPathComponent(FileLocation.uikit.rawValue), key: "UIAnimationDragCoefficient") as? Double ?? 1
            } catch {

            }
            do {
                sbLockScreenFootnote = try PlistManager.getPlistValues(url: workspace.appendingPathComponent(FileLocation.footnote.rawValue), key: "LockScreenFootnote") as? String ?? ""
            } catch {

            }
            
            // Internal Options
            internalOptions = loadToggles(from: internalOptions, workspace: workspace)

            // Setup Options
            for (i, opt) in skipSetupOptions.enumerated() {
                if opt.key == "Skip" {
                    skipSetupOptions[i].value = getSkipSetupEnabled()
                } else if opt.key == "OTA" {
                    skipSetupOptions[i].value = getOTABlocked()
                } else if opt.key == "Supervision" {
                    skipSetupOptions[i].value = getSupervisionEnabled()
                }
            }
            skipSetupOrganizationName = getOrganizationName()
        }
    }
    #endif
    
    // Apply a toggle
    public static func applyToggle(index: Int, value: Bool, tweak: Tweak) {
        var key: String = ""
        var fileLocation: FileLocation = .springboard
        if tweak == .springboardOptions {
            if index < sbOptions.count {
                sbOptions[index].value = value
                key = sbOptions[index].key
                fileLocation = sbOptions[index].fileLocation
            }
        } else if tweak == .internalOptions {
            if index < internalOptions.count {
                internalOptions[index].value = value
                key = internalOptions[index].key
                fileLocation = internalOptions[index].fileLocation
            }
        }
        if key != "", let workspace = DataSingleton.shared.getCurrentWorkspace() {
            let plistURL = workspace.appendingPathComponent(fileLocation.rawValue)
            do {
                if key == "WiFiManagerLoggingEnabled" {
                    try PlistManager.setPlistValues(url: plistURL, values: [
                        key: value ? "true" : "false"
                    ])
                } else if key == "DiscoverableMode" {
                    if value == true {
                        try PropertyListSerialization.data(fromPropertyList: ["DiscoverableMode": "Everyone"], format: .xml, options: 0).write(to: plistURL)
                    } else {
                        try PropertyListSerialization.data(fromPropertyList: [:], format: .xml, options: 0).write(to: plistURL)
                    }
                } else {
                    try PlistManager.setPlistValues(url: plistURL, values: [
                        key: value
                    ])
                }
            } catch {
                
            }
        }
    }
    
    
    // MARK: Control Center
    public static var moduleTypes: [ToggleOption] = [
        .init(key: "1", name: "Mute Module", fileLocation: .mute),
        .init(key: "2", name: "Focus UI Module", fileLocation: .focus),
        .init(key: "3", name: "Siri Spoken Notifications Module", fileLocation: .spoken)
    ]
    public static var selectedCCPreset: String = "None"
    #if CLI
    public static let ccPresets: [ConfigPreset] = [
        .init(title: "Revert to Original", identification: "RevertCC", fileLocation: Bundle.module.url(forResource: "RevertCC", withExtension: ".plist"), modulesToEnable: []),
        .init(title: "Default", identification: "DefaultCC", fileLocation: Bundle.module.url(forResource: "DefaultCC", withExtension: ".plist"), modulesToEnable: [2])
    ]
    #endif
    
    public static func setModuleVisibility(key: Int, _ nv: Bool) {
        for (i, module) in moduleTypes.enumerated() {
            if Int(module.key) ?? i+1 == key {
                do {
                    guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(module.fileLocation.rawValue) else {
                        Logger.shared.logMe("Error finding springboard plist \(module.fileLocation.rawValue)")
                        return
                    }
                    try PlistManager.setPlistValues(url: plistURL, values: [
                        "SBIconVisibility": nv
                    ])
                    moduleTypes[i].value = nv
                    return
                } catch {
                    Logger.shared.logMe(error.localizedDescription)
                    return
                }
            }
        }
    }
    
    public static func setCCPreset(_ nv: ConfigPreset) {
        guard let filePath = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.moduleConfig.rawValue) else { return }
        if selectedCCPreset == nv.identification {
            if FileManager.default.fileExists(atPath: filePath.path) {
                try? FileManager.default.removeItem(at: filePath)
            }
            selectedCCPreset = "None"
        } else {
            do {
                if let ccPlist = nv.fileLocation {
                    try FileManager.default.copyItem(at: ccPlist, to: filePath)
                    // enable the modules associated with it
                    // kinda slow but it works
                    for module in nv.modulesToEnable {
                        for (i, mod) in moduleTypes.enumerated() {
                            if Int(mod.key) ?? i+1 == module {
                                setModuleVisibility(key: module, true)
                            }
                        }
                    }
                    selectedCCPreset = nv.identification
                } else {
                    throw "No url for preset \(nv.identification) found!"
                }
            } catch {
                selectedCCPreset = "None"
                print(error.localizedDescription)
            }
        }
    }
    
    
    // MARK: Springboard Options
    public static var sbOptions: [ToggleOption] = [
        .init(key: "SBDontLockAfterCrash", name: "Disable Lock After Respring", fileLocation: .springboard),
        .init(key: "SBDontDimOrLockOnAC", name: "Disable Screen Dimming While Charging", fileLocation: .springboard),
        .init(key: "SBHideLowPowerAlerts", name: "Disable Low Battery Alerts", fileLocation: .springboard),
        .init(key: "SBControlCenterEnabledInLockScreen", name: "CC Enabled on Lock Screen", fileLocation: .springboard),
        .init(key: "StartupSoundEnabled", name: "Shutdown Sound", fileLocation: .accessibility),
        .init(key: "WiFiManagerLoggingEnabled", name: "Show WiFi Debugger", fileLocation: .wifiDebug),
        .init(key: "DiscoverableMode", name: "Set Airdrop to Everyone", fileLocation: .airdrop)
    ]
    public static var sbAnimationSpeed: Double = 1
    public static var sbLockScreenFootnote: String = ""

    public static func setLockScreenFootnote(_ nv: String) {
        guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.footnote.rawValue) else {
            Logger.shared.logMe("Error finding footnote plist")
            return
        }
        do {
            try PlistManager.setPlistValues(url: plistURL, values: [
                "LockScreenFootnote": nv
            ])
            sbLockScreenFootnote = nv
        } catch {
            Logger.shared.logMe(error.localizedDescription)
            return
        }
    }
    
    public static func setAnimationSpeed(_ nv: Double) {
        guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.uikit.rawValue) else {
            Logger.shared.logMe("Error finding uikit plist")
            return
        }
        do {
            try PlistManager.setPlistValues(url: plistURL, values: [
                "UIAnimationDragCoefficient": nv
            ])
            sbAnimationSpeed = nv
        } catch {
            Logger.shared.logMe(error.localizedDescription)
            return
        }
    }
    
    
    // MARK: Internal Options
    public static var internalOptions: [ToggleOption] = [
        .init(key: "UIStatusBarShowBuildVersion", name: "Build Version in Status Bar", fileLocation: .globalPreferences),
        .init(key: "NSForceRightToLeftWritingDirection", name: "Force Right to Left", fileLocation: .globalPreferences, dividerBelow: true),
        .init(key: "MetalForceHudEnabled", name: "Force Metal HUD Debug", fileLocation: .globalPreferences),
        .init(key: "AccessoryDeveloperEnabled", name: "Accessory Diagnostics", fileLocation: .globalPreferences),
        .init(key: "iMessageDiagnosticsEnabled", name: "iMessage Diagnostics", fileLocation: .globalPreferences),
        .init(key: "IDSDiagnosticsEnabled", name: "IDS Diagnostics", fileLocation: .globalPreferences),
        .init(key: "VCDiagnosticsEnabled", name: "VC Diagnostics", fileLocation: .globalPreferences, dividerBelow: true),
        .init(key: "debugGestureEnabled", name: "App Store Debug Gesture", fileLocation: .appStore),
        .init(key: "DebugModeEnabled", name: "Notes App Debug Mode", fileLocation: .notes)
    ]
    
    
    // MARK: Setup Option Configuration
    public static var skipSetupOptions: [ToggleOption] = [
        .init(key: "Skip", name: "Skip Setup (recommended)", fileLocation: .skipSetup),
        .init(key: "OTA", name: "Disable OTA Updates", fileLocation: .ota),
        .init(key: "Supervision", name: "Enable Supervision", fileLocation: .skipSetup)
    ]
    public static var skipSetupOrganizationName: String = ""

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
    public static func setSkipSetup(_ nv: Bool) {
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
    public static func setOTABlocked(_ nv: Bool) {
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
    public static func setSupervision(_ nv: Bool) {
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
    public static func setOrganizationName(_ nv: String) {
        do {
            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.skipSetup.rawValue) else {
                Logger.shared.logMe("Error finding cloud configuration details plist")
                return
            }
            skipSetupOrganizationName = nv
            try PlistManager.setPlistValues(url: plistURL, values: [
                "OrganizationName": nv
            ])
        } catch {
            Logger.shared.logMe(error.localizedDescription)
            return
        }
    }
}
