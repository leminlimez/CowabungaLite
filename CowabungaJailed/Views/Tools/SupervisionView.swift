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
    
    let fileLocation = "SkipSetup/SysSharedContainerDomain-systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/CloudConfigurationDetails.plist"
    
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
                    Toggle("Supervision Enabled", isOn: $supervisionEnabled).onChange(of: supervisionEnabled, perform: { nv in
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
