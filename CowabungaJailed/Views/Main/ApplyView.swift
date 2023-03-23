//
//  ApplyView.swift
//  CowabungaJailed
//
//  Created by Rory Madden on 21/3/2023.
//

import SwiftUI

struct ApplyView: View {
    @State private var logger = Logger.shared
    var body: some View {
        List {
            ForEach(Array(DataSingleton.shared.allEnabledTweaks()), id: \.self) { tweak in
                HStack(spacing: 5) {
                    Text("•")
                        .foregroundColor(.secondary)
                    Text(tweak.rawValue)
                        .foregroundColor(.primary)
                }
            }
            Button("Apply Tweak") {
                // Erase backup folder
                let enabledTweaksDirectory = documentsDirectory.appendingPathComponent("EnabledTweaks")
                if fm.fileExists(atPath: enabledTweaksDirectory.path) {
                    do {
                        let fileURLs = try fm.contentsOfDirectory(at: enabledTweaksDirectory, includingPropertiesForKeys: nil)
                        for fileURL in fileURLs {
                            try FileManager.default.removeItem(at: fileURL)
                        }
                    } catch {
                        Logger.shared.logMe("Error removing contents of EnabledTweaks directory")
                        return
                    }
                } else {
                    do {
                        try fm.createDirectory(at: enabledTweaksDirectory, withIntermediateDirectories: false)
                    } catch {
                        Logger.shared.logMe("Error creating EnabledTweaks directory")
                        return
                    }
                }
                
                // Copy tweaks across
                guard let workspaceURL = DataSingleton.shared.getCurrentWorkspace() else {
                    Logger.shared.logMe("Error getting Workspace URL")
                    return
                }

                for tweak in DataSingleton.shared.allEnabledTweaks() {
                    do {
                        let files = try fm.contentsOfDirectory(at: workspaceURL.appendingPathComponent("\(tweak.rawValue)"), includingPropertiesForKeys: nil)
                        for file in files {
                            let newURL = enabledTweaksDirectory.appendingPathComponent(file.lastPathComponent)
                            var shouldMergeDirectory = false
                            var isDirectory: ObjCBool = false
                            if fm.fileExists(atPath: newURL.path, isDirectory: &isDirectory) {
                                if isDirectory.boolValue {
                                    shouldMergeDirectory = true
                                } else {
                                    let newFileAttributes = try fm.attributesOfItem(atPath: newURL.path)
                                    let oldFileAttributes = try fm.attributesOfItem(atPath: file.path)
                                    if let newModifiedTime = newFileAttributes[.modificationDate] as? Date,
                                       let oldModifiedTime = oldFileAttributes[.modificationDate] as? Date,
                                       newModifiedTime.compare(oldModifiedTime) != .orderedAscending {
                                        continue // skip copying the file since the new file is older
                                    }
                                }
                            }
                            if shouldMergeDirectory {
                                try fm.mergeDirectory(at: file, to: newURL)
                            } else {
                                try fm.copyItem(at: file, to: newURL)
                            }
                        }
                    } catch {
                        Logger.shared.logMe(error.localizedDescription)
                        return
                    }
                }

                
                let backupDirectory = documentsDirectory.appendingPathComponent("Backup")
                if fm.fileExists(atPath: backupDirectory.path) {
                    do {
                        let fileURLs = try fm.contentsOfDirectory(at: backupDirectory, includingPropertiesForKeys: nil)
                        for fileURL in fileURLs {
                            try FileManager.default.removeItem(at: fileURL)
                        }
                    } catch {
                        Logger.shared.logMe("Error removing contents of Backup directory")
                        return
                    }
                } else {
                    do {
                        try fm.createDirectory(at: backupDirectory, withIntermediateDirectories: false)
                    } catch {
                        Logger.shared.logMe("Error creating Backup directory")
                        return
                    }
                }
                
                // Generate backup
                guard let script = Bundle.main.url(forResource: "CreateBackup", withExtension: "sh") else {
                    Logger.shared.logMe("Error locating CreateBackup.sh")
                    return }
                do {
                    try shell(script, arguments: ["EnabledTweaks", "Backup"], workingDirectory: documentsDirectory)
                } catch {
                    Logger.shared.logMe("Error running CreateBackup.sh")
                }
                
                // Restore files
                guard let exec = Bundle.main.url(forResource: "idevicebackup2", withExtension: "") else {
                    Logger.shared.logMe("Error locating idevicebackup2")
                    return
                }
                guard let currentUUID = DataSingleton.shared.getCurrentUUID() else {
                    Logger.shared.logMe("Error getting current UUID")
                    return
                }
                do {
                    try execute(exec, arguments:["-u", currentUUID, "-s", "Backup", "restore", "--system", "--skip-apps", "."], workingDirectory: documentsDirectory)
                } catch {
                    Logger.shared.logMe("Error restoring to device")
                }
            }
            TextEditor(text: $logger.logText).font(Font.system(.body, design: .monospaced)).frame(height: 250).disabled(true)
        }
    }
}

struct ApplyView_Previews: PreviewProvider {
    static var previews: some View {
        ApplyView()
    }
}
