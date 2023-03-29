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
    
    struct SBOption: Identifiable {
        var id = UUID()
        var key: String
        var name: String
        var imageName: String
        var value: Bool = false
    }
    
    @State private var sbOptions: [SBOption] = [
        .init(key: "SBDontLockAfterCrash", name: "Disable Lock After Respring", imageName: "lock.open"),
        .init(key: "SBDontDimOrLockOnAC", name: "Disable Screen Dimming While Charging", imageName: "battery.100.bolt"),
        .init(key: "SBHideLowPowerAlerts", name: "Disable Low Battery Alerts", imageName: "battery.25"),
//        .init(key: "SBDisableHomeButton", name: "Disable Home Button", imageName: "iphone.homebutton"),
//        .init(key: "SBDontLockEver", name: "Disable Lock Button", imageName: "lock.square"),
//        .init(key: "SBDisableNotificationCenterBlur", name: "Disable Notif Center Blur", imageName: "app.badge"),
//        .init(key: "SBControlCenterEnabledInLockScreen", name: "Lock Screen CC", imageName: "square.grid.2x2"),
//        .init(key: "SBControlCenterDemo", name: "CC AirPlay Radar", imageName: "wifi.circle")
    ]
    
    let fileLocationSprinboard = "SpringboardOptions/ManagedPreferencesDomain/mobile/com.apple.springboard.plist"
    let fileLocationFootnote = "SpringboardOptions/SysSharedContainerDomain-systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/SharedDeviceConfiguration.plist"
    let fileLocationOTA = "SpringboardOptions/ManagedPreferencesDomain/mobile/com.apple.MobileAsset.plist"
    
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
                                    guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(fileLocationSprinboard) else {
                                        Logger.shared.logMe("Error finding springboard plist")
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
                                    guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(fileLocationSprinboard) else {
                                        Logger.shared.logMe("Error finding springboard plist")
                                        return
                                    }
                                    option.value.wrappedValue =  try PlistManager.getPlistValues(url: plistURL, key: option.key.wrappedValue) as? Bool ?? false
                                } catch {
                                    Logger.shared.logMe("Error finding springboard plist")
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
                                            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(fileLocationOTA) else {
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
                                            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(fileLocationOTA) else {
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
                        }
                        Text("Lock Screen Footnote Text")
                        TextField("Footnote Text", text: $footnoteText).onChange(of: footnoteText, perform: { nv in
                            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(fileLocationFootnote) else {
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
                            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(fileLocationFootnote) else {
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
