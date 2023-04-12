//
//  SpringboardOptionsView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/22/23.
//

import Foundation
import SwiftUI

struct SpringboardOptionsView: View {
    @StateObject private var logger = Logger.shared
    @StateObject private var dataSingleton = DataSingleton.shared
    @State private var enableTweak: Bool = false
    @State private var footnoteText = ""
    @State private var otaDisabled = false
    @State private var animSpeed: Double = 1
    
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
    
    @State private var sbOptions: [SBOption] = [
        .init(key: "SBDontLockAfterCrash", name: "Disable Lock After Respring", fileLocation: .springboard),
        .init(key: "SBDontDimOrLockOnAC", name: "Disable Screen Dimming While Charging", fileLocation: .springboard),
        .init(key: "SBHideLowPowerAlerts", name: "Disable Low Battery Alerts", fileLocation: .springboard),
        .init(key: "SBIconVisibility", name: "Mute Module in CC", fileLocation: .mute),
        .init(key: "UIStatusBarShowBuildVersion", name: "Build Version in Status Bar", fileLocation: .globalPreferences),
        .init(key: "AccessoryDeveloperEnabled", name: "Accessory Developer", fileLocation: .globalPreferences),
        .init(key: "kWiFiShowKnownNetworks", name: "Show Known WiFi Networks", fileLocation: .wifi),
//        .init(key: "SBDisableHomeButton", name: "Disable Home Button", imageName: "iphone.homebutton"),
//        .init(key: "SBDontLockEver", name: "Disable Lock Button", imageName: "lock.square"),
        .init(key: "SBDisableNotificationCenterBlur", name: "Disable Notif Center Blur", fileLocation: .springboard),
        .init(key: "SBControlCenterEnabledInLockScreen", name: "CC Enabled on Lock Screen", fileLocation: .springboard),
        .init(key: "SBControlCenterDemo", name: "CC AirPlay Radar", fileLocation: .springboard)
    ]
    
    var body: some View {
        List {
            Group {
                HStack {
                    Image(systemName: "app.badge")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                    VStack {
                        HStack {
                            Text("Springboard Options")
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Toggle("Enable", isOn: $enableTweak).onChange(of: enableTweak, perform: {nv in
                                DataSingleton.shared.setTweakEnabled(.springboardOptions, isEnabled: nv)
                            }).onAppear(perform: {
                                enableTweak = DataSingleton.shared.isTweakEnabled(.springboardOptions)
                            })
                            Spacer()
                        }
                    }
                }
                Divider()
                if dataSingleton.deviceAvailable {
                    Group {
                        ForEach($sbOptions) { option in
                            Toggle(isOn: option.value) {
                                Text(option.name.wrappedValue)
                                    .minimumScaleFactor(0.5)
                            }.onChange(of: option.value.wrappedValue) { new in
                                do {
                                    guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(option.fileLocation.wrappedValue.rawValue) else {
                                        Logger.shared.logMe("Error finding springboard plist \(option.fileLocation.wrappedValue.rawValue)")
                                        return
                                    }
                                    try PlistManager.setPlistValues(url: plistURL, values: [
                                        option.key.wrappedValue: option.value.wrappedValue
                                    ])
                                } catch {
                                    Logger.shared.logMe(error.localizedDescription)
                                    return
                                }
                            }
                            .onAppear {
                                do {
                                    guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(option.fileLocation.wrappedValue.rawValue) else {
                                        Logger.shared.logMe("Error finding springboard plist \(option.fileLocation.wrappedValue.rawValue)")
                                        return
                                    }
                                    option.value.wrappedValue =  try PlistManager.getPlistValues(url: plistURL, key: option.key.wrappedValue) as? Bool ?? false
                                } catch {
                                    Logger.shared.logMe("Error finding springboard plist \(option.fileLocation.wrappedValue.rawValue)")
                                    return
                                }
                            }
                        }
                        Toggle(isOn: $otaDisabled) {
                            Text("Disable OTA Updates")
                                .minimumScaleFactor(0.5)
                                .onChange(of: otaDisabled, perform: { nv in
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
                                })
                                .onAppear {
                                    do {
                                        guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.ota.rawValue) else {
                                            Logger.shared.logMe("Error finding springboard plist")
                                            return
                                        }
                                        guard let data = fm.contents(atPath: plistURL.path) else {
                                            Logger.shared.logMe("Can't read plist")
                                            return
                                        }
                                        let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
                                        if let dictionary = plist as? [String: Any], dictionary.isEmpty {
                                            otaDisabled = false
                                        } else {
                                            otaDisabled = true
                                        }
                                    } catch {
                                        Logger.shared.logMe("Error finding springboard plist")
                                        return
                                    }
                                }
                        }
                        
                        Divider()
                        
                        Text("Animation Speed")
                        TextField("Animation Speed", value: $animSpeed, format: .number).onChange(of: animSpeed, perform: { nv in
                            if animSpeed <= 0 {
                                animSpeed = 1
                            }
                            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.uikit.rawValue) else {
                                Logger.shared.logMe("Error finding uikit plist")
                                return
                            }
                            do {
                                try PlistManager.setPlistValues(url: plistURL, values: [
                                    "UIAnimationDragCoefficient": animSpeed
                                ])
                            } catch {
                                Logger.shared.logMe(error.localizedDescription)
                            }
                        }).onAppear {
                            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.uikit.rawValue) else {
                                Logger.shared.logMe("Error finding uikit plist")
                                return
                            }
                            // Add a getPlistValues func to PlistManager pls
                            guard let plist = NSDictionary(contentsOf: plistURL) as? [String:Any] else {
                                return
                            }
                            animSpeed = plist["UIAnimationDragCoefficient"] as? Double ?? 1
                        }
                        
                        Text("Lock Screen Footnote Text")
                        TextField("Footnote Text", text: $footnoteText).onChange(of: footnoteText, perform: { nv in
                            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.footnote.rawValue) else {
                                Logger.shared.logMe("Error finding footnote plist")
                                return
                            }
                            do {
                                try PlistManager.setPlistValues(url: plistURL, values: [
                                    "LockScreenFootnote": footnoteText
                                ])
                            } catch {
                                Logger.shared.logMe(error.localizedDescription)
                            }
                        }).onAppear(perform: {
                            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.footnote.rawValue) else {
                                Logger.shared.logMe("Error finding footnote plist")
                                return
                            }
                            // Add a getPlistValues func to PlistManager pls
                            guard let plist = NSDictionary(contentsOf: plistURL) as? [String:Any] else {
                                return
                            }
                            footnoteText = plist["LockScreenFootnote"] as! String
                        })
                    }.disabled(!enableTweak)
                }
            }.disabled(!dataSingleton.deviceAvailable)
        }
    }
}

struct SpringboardOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        SpringboardOptionsView()
    }
}
