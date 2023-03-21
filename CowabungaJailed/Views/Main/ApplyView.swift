//
//  ApplyView.swift
//  CowabungaJailed
//
//  Created by Rory Madden on 21/3/2023.
//

import SwiftUI

struct ApplyView: View {
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
            Button("Apply Tweaks") {
                // Erase backup folder
                
                // Copy tweaks across
                for tweak in DataSingleton.shared.allEnabledTweaks() {
                    
                }
                
                // Generate backup
//                guard let script = Bundle.main.url(forResource: "CreateBackup", withExtension: "sh") else {
//                    Logger.shared.logMe("Error locating CreateBackup.sh")
//                    return }
//                do {
//                    try shell(script, arguments: ["Files/Footnote", "Backup"], workingDirectory: documentsDirectory)
//                } catch {
//                    Logger.shared.logMe("Error running CreateBackup.sh")
//                }
//                
//                // Restore file
//                guard let exec = Bundle.main.url(forResource: "idevicebackup2", withExtension: "") else {
//                    Logger.shared.logMe("Error locating idevicebackup2")
//                    return
//                }
//                do {
//                    try execute(exec, arguments:["-s", "Backup", "restore", "--system", "--skip-apps", "."], workingDirectory: documentsDirectory)
//                } catch {
//                    Logger.shared.logMe("Error restoring to device")
//                }
            }
        }
    }
}

struct ApplyView_Previews: PreviewProvider {
    static var previews: some View {
        ApplyView()
    }
}
