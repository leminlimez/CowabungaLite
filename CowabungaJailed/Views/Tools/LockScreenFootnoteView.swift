//
//  LockScreenFootnoteView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/20/23.
//

import SwiftUI

struct LockScreenFootnoteView: View {
    @StateObject private var logger = Logger.shared
    @State private var footnoteText = ""
    @State private var enableTweak = false
    
    var body: some View {
        List {
            HStack {
                Image(systemName: "iphone")
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
            HStack {
                TextField("Footnote Text", text: $footnoteText).onChange(of: footnoteText, perform: { nv in
                    guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent("Files/Footnote/SysSharedContainerDomain-systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/SharedDeviceConfiguration.plist") else { return }
                    do {
                        try PlistManager.setPlistValues(url: plistURL, values: [
                            "LockScreenFootnote": footnoteText
                        ])
                    } catch {
                        Logger.shared.logMe(error.localizedDescription)
                    }
                })
//                Button("Apply") {
//                    // generate backup
//                    guard let script = Bundle.main.url(forResource: "CreateBackup", withExtension: "sh") else {
//                        Logger.shared.logMe("Error locating CreateBackup.sh")
//                        return }
//                    do {
//                        try shell(script, arguments: ["Files/Footnote", "Backup"], workingDirectory: documentsDirectory)
//                    } catch {
//                        Logger.shared.logMe("Error running CreateBackup.sh")
//                    }
//
//                    // restore to device
//                    guard let exec = Bundle.main.url(forResource: "idevicebackup2", withExtension: "") else {
//                        Logger.shared.logMe("Error locating idevicebackup2")
//                        return
//                    }
//                    do {
//                        try execute(exec, arguments:["-s", "Backup", "restore", "--system", "--skip-apps", "."], workingDirectory: documentsDirectory)
//                    } catch {
//                        Logger.shared.logMe("Error restoring to device")
//                    }
//                }
            }.disabled(!enableTweak)
//            Button("Set Up Backup Directory") {
//                copyFolderFromBundleToDocuments()
//                Logger.shared.logMe("done")
//            }
            Button("View Backup Directory Tree") {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                printDirectoryTree(at: documentsDirectory, level: 0)
            }
            TextEditor(text: $logger.logText).font(Font.system(.body, design: .monospaced)).frame(height: 250)
        }
    }
}

struct LockScreenFootnoteView_Previews: PreviewProvider {
    static var previews: some View {
        LockScreenFootnoteView()
    }
}
