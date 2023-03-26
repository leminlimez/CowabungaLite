//
//  LockScreenFootnoteView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/20/23.
//

import SwiftUI

struct LockScreenFootnoteView: View {
    @StateObject private var logger = Logger.shared
    @StateObject private var dataSingleton = DataSingleton.shared
    @State private var footnoteText = ""
    @State private var enableTweak = false
    
    var body: some View {
        List {
            Group {
                HStack {
                    Image(systemName: "platter.filled.bottom.iphone")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                    VStack {
                        HStack {
                            Text("Lock Screen Footnote")
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Toggle("Enable", isOn: $enableTweak).onChange(of: enableTweak, perform: {nv in
                                DataSingleton.shared.setTweakEnabled(.footnote, isEnabled: nv)
                            }).onAppear(perform: {
                                enableTweak = DataSingleton.shared.isTweakEnabled(.footnote)
                            })
                            Spacer()
                        }
                    }
                }
                Divider()
            }
            if dataSingleton.deviceAvailable {
                Group {
                    Text("Footnote Text")
                    TextField("Footnote Text", text: $footnoteText).onChange(of: footnoteText, perform: { nv in
                        guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent("Footnote/SysSharedContainerDomain-systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/SharedDeviceConfiguration.plist") else {
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
                        guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent("Footnote/SysSharedContainerDomain-systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/SharedDeviceConfiguration.plist") else {
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
//                Button("View Backup Directory Tree") {
//                    printDirectoryTree(at: documentsDirectory, level: 0)
//                    getHomeScreenApps()
//                }
            }
        }.disabled(!dataSingleton.deviceAvailable)
    }
}

struct LockScreenFootnoteView_Previews: PreviewProvider {
    static var previews: some View {
        LockScreenFootnoteView()
    }
}
