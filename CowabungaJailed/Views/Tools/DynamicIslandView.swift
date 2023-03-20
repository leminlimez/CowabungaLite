//
//  DynamicIslandView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/20/23.
//

import SwiftUI

struct DynamicIslandView: View {
    @StateObject private var logger = Logger.shared
    
    var body: some View {
        VStack {
            HStack {
                Button("Apply") {
                    // set up backup directory
                    guard copyFolderFromBundleToDocuments() else { return }
                    
                    // edit plist
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//                    let plistURL = documentsDirectory.appendingPathComponent("/Files/Footnote/SysSharedContainerDomain-systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/SharedDeviceConfiguration.plist")
//                    guard var plist = NSDictionary(contentsOf: plistURL) as? [String:String] else {
//                        Logger.shared.logMe("Error parsing plist")
//                        return
//                    }
//                    (plist as NSDictionary).write(to: plistURL, atomically: true)
                    
                    // generate backup
                    guard let script = Bundle.main.url(forResource: "CreateBackup", withExtension: "sh") else {
                        Logger.shared.logMe("Error locating CreateBackup.sh")
                        return }
                    do {
                        try shell(script, arguments: ["com.apple.mobilegestalt.plist", "Backup/SysSharedContainerDomain-systemgroup.com.apple.mobilegestaltcache/Library/Caches"], workingDirectory: documentsDirectory)
                    } catch {
                        Logger.shared.logMe("Error running CreateBackup.sh")
                    }
                    
                    // restore to device
                    guard let exec = Bundle.main.url(forResource: "idevicebackup2", withExtension: "") else {
                        Logger.shared.logMe("Error locating idevicebackup2")
                        return
                    }
                    do {
                        try execute(exec, arguments:["-s", "Backup", "restore", "--system", "--skip-apps", "."], workingDirectory: documentsDirectory)
                    } catch {
                        Logger.shared.logMe("Error restoring to device")
                    }
                }
            }
//            Button("Set Up Backup Directory") {
//                copyFolderFromBundleToDocuments()
//                Logger.shared.logMe("done")
//            }
//            Button("View Backup Directory Tree") {
//                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//                printDirectoryTree(at: documentsDirectory, level: 0)
//            }
//            Button("Generate Backup") {
//                guard let script = Bundle.main.url(forResource: "CreateBackup", withExtension: "sh") else { return }
//                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//                do {
//                    try shell(script, arguments: ["Files/Footnote", "Backup"], workingDirectory: documentsDirectory)
//                } catch {
//
//                }
//            }
//            Button("Restore to Device") {
//                guard let exec = Bundle.main.url(forResource: "idevicebackup2", withExtension: "") else { return }
//                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//                do {
//                    try execute(exec, arguments:["-s", "Backup", "restore", "--system", "--skip-apps", "."], workingDirectory: documentsDirectory)
//                } catch {
//                }
//            }
//            Button("Devices") {
//                let devices = getDevices()
//                for d in devices {
//                    Logger.shared.logMe(d.uuid)
//                    Logger.shared.logMe(d.name)
//                }
//            }
            TextEditor(text: $logger.logText).font(Font.system(.body, design: .monospaced))
        }
    }
}

struct DynamicIslandView_Previews: PreviewProvider {
    static var previews: some View {
        DynamicIslandView()
    }
}
