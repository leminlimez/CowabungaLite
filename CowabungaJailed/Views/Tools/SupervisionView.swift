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
    @State private var supervisionEnabled = false
    @State private var managedCompanyName = ""
    @State private var enableTweak = false
    
    var body: some View {
        List {
            Group {
                HStack {
                    Image(systemName: "gear.badge.xmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                    VStack {
                        HStack {
                            Text("Supervision (+ Skip Setup)")
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
                    Toggle("Supervision Enabled", isOn: $supervisionEnabled).onChange(of: supervisionEnabled, perform: { nv in
                        guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent("SkipSetup/SysSharedContainerDomain-systemgroup.com.apple/Library/ConfigurationProfiles/CloudConfigurationDetails.plist") else {
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
                    })
                    Text("OrganizationName")
                    TextField("Organization Name", text: $managedCompanyName).onChange(of: managedCompanyName, perform: { nv in
                        do {
                            guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent("SkipSetup/SysSharedContainerDomain-systemgroup.com.apple/Library/ConfigurationProfiles/CloudConfigurationDetails.plist") else {
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
                            managedCompanyName = try PlistManager.getPlistValues(path: "SkipSetup/SysSharedContainerDomain-systemgroup.com.apple/Library/ConfigurationProfiles/CloudConfigurationDetails.plist", key: "OrganizationName") as? String ?? ""
                        } catch {
                            Logger.shared.logMe(error.localizedDescription)
                            print(error.localizedDescription)
                            return
                        }
                    })
                }.disabled(!enableTweak)
//                Button("View Backup Directory Tree") {
//                    printDirectoryTree(at: documentsDirectory, level: 0)
//                    getHomeScreenApps()
//                }
            }
        }.disabled(!dataSingleton.deviceAvailable)
    }
}

struct SupervisionView_Previews: PreviewProvider {
    static var previews: some View {
        SupervisionView()
    }
}
