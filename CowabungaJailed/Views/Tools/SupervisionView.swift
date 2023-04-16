//
//  SupervisionView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/27/23.
//

import SwiftUI

struct SupervisionView: View {
    @StateObject private var logger = Logger.shared
    @StateObject private var dataSingleton = DataSingleton.shared
    @State private var skipSetup = false
    @State private var supervisionEnabled = false
    @State private var managedCompanyName = ""
    @State private var enableTweak = false
    @State private var otaDisabled = false
    
    let fileLocation = "SkipSetup/SysSharedContainerDomain-systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/CloudConfigurationDetails.plist"
    let otaFileLocation = "SpringboardOptions/ManagedPreferencesDomain/mobile/com.apple.MobileAsset.plist"
    
    var body: some View {
        List {
            Group {
                HStack {
                    Image(systemName: "gear")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                    VStack {
                        HStack {
                            Text("Setup Options")
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Toggle("Enable", isOn: $enableTweak).onChange(of: enableTweak, perform: {nv in
                                DataSingleton.shared.setTweakEnabled(.skipSetup, isEnabled: nv)
                            }).onAppear(perform: {
                                enableTweak = DataSingleton.shared.isTweakEnabled(.skipSetup)
                            })
                            Spacer()
                        }
                    }
                }
                Divider()
            }
            if dataSingleton.deviceAvailable {
                Group {
                    // MARK: Skipping Setup
                    Toggle("Skip Setup (recommended)", isOn: $skipSetup).onChange(of: skipSetup, perform: { nv in
                        guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(fileLocation) else {
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
                    }).onAppear(perform: {
                        do {
                            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(fileLocation) else {
                                Logger.shared.logMe("Error finding cloud configuration details plist")
                                return
                            }
                            skipSetup = try PlistManager.getPlistValues(url: plistURL, key: "CloudConfigurationUIComplete") as? Bool ?? false
                        } catch {
                            Logger.shared.logMe(error.localizedDescription)
                            return
                        }
                    })
                    
                    // MARK: OTA Killer
                    Toggle(isOn: $otaDisabled) {
                        Text("Disable OTA Updates")
                            .minimumScaleFactor(0.5)
                            .onChange(of: otaDisabled, perform: { nv in
                                if nv {
                                    do {
                                        guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(otaFileLocation) else {
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
                                        guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(otaFileLocation) else {
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
                                    guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(otaFileLocation) else {
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
                    
                    // MARK: Supervision
                    Toggle("Enable Supervision", isOn: $supervisionEnabled).onChange(of: supervisionEnabled, perform: { nv in
                        guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(fileLocation) else {
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
                    }).onAppear(perform: {
                        do {
                            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(fileLocation) else {
                                Logger.shared.logMe("Error finding cloud configuration details plist")
                                return
                            }
                            supervisionEnabled = try PlistManager.getPlistValues(url: plistURL, key: "IsSupervised") as? Bool ?? false
                        } catch {
                            Logger.shared.logMe(error.localizedDescription)
                            return
                        }
                    })
                    TextField("Organization Name", text: $managedCompanyName).onChange(of: managedCompanyName, perform: { nv in
                        do {
                            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(fileLocation) else {
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
                    }).onAppear(perform: {
                        do {
                            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(fileLocation) else {
                                Logger.shared.logMe("Error finding cloud configuration details plist")
                                return
                            }
                            managedCompanyName = try PlistManager.getPlistValues(url: plistURL, key: "OrganizationName") as? String ?? ""
                        } catch {
                            Logger.shared.logMe(error.localizedDescription)
                            return
                        }
                    })
                }.disabled(!enableTweak)
            }
        }.disabled(!dataSingleton.deviceAvailable)
    }
}

struct SupervisionView_Previews: PreviewProvider {
    static var previews: some View {
        SupervisionView()
    }
}
