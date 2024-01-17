//
//  Utilities.swift
//  CowabungaJailed
//
//  Created by Rory Madden on 20/3/2023.
//

import Foundation

func updateWorkspace(_ url: URL) -> Bool {
    let FilesVersion: Int = 2
    
    if FileManager.default.fileExists(atPath: url.appendingPathComponent("FileVersion.plist").path) {
        do {
            let data = try Data(contentsOf: url.appendingPathComponent("FileVersion.plist"))
            let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: Any]
            if let devVer = plist["DeviceVersion"] as? String, devVer == DataSingleton.shared.getCurrentVersion() {
                if let ver = plist["Version"] as? Int, ver == FilesVersion {
                    return false
                }
            }
        } catch {
            Logger.shared.logMe("Error with opening FileVersion.plist: \(error.localizedDescription)")
        }
    }
    
    do {
        for p in try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) {
            if p.deletingLastPathComponent().lastPathComponent == "IconThemingPreferences" || p.deletingLastPathComponent().lastPathComponent == "AltIconThemingPreferences" {
                continue
            } else {
                try? FileManager.default.removeItem(at: p)
            }
        }
        // create the new version plist
        let newPlist: [String: Any] = [
            "Version": FilesVersion,
            "DeviceVersion": DataSingleton.shared.getCurrentVersion() ?? "0"
        ]
        let newData = try PropertyListSerialization.data(fromPropertyList: newPlist, format: .xml, options: 0)
        try newData.write(to: url.appendingPathComponent("FileVersion.plist"))
    } catch {
        Logger.shared.logMe(error.localizedDescription)
        return true
    }
    return true
}

func setupWorkspaceForUUID(_ UUID: String) {
    let workspaceDirectory = documentsDirectory.appendingPathComponent("Workspace")
    if !fm.fileExists(atPath: documentsDirectory.path) {
        do {
            try fm.createDirectory(atPath: documentsDirectory.path, withIntermediateDirectories: false, attributes: nil)
            Logger.shared.logMe("Documents folder created")
        } catch {
            Logger.shared.logMe("Error creating Documents folder: \(error.localizedDescription)")
            return
        }
    }
    if !fm.fileExists(atPath: workspaceDirectory.path) {
        do {
            try fm.createDirectory(atPath: workspaceDirectory.path, withIntermediateDirectories: false, attributes: nil)
            Logger.shared.logMe("Workspace folder created")
        } catch {
            Logger.shared.logMe("Error creating Workspace folder: \(error.localizedDescription)")
            return
        }
    }
    let UUIDDirectory = workspaceDirectory.appendingPathComponent(UUID)
    if !fm.fileExists(atPath: UUIDDirectory.path) {
        do {
            try fm.createDirectory(atPath: UUIDDirectory.path, withIntermediateDirectories: false, attributes: nil)
            Logger.shared.logMe("UUID folder created")
        } catch {
            Logger.shared.logMe("Error creating UUID folder: \(error.localizedDescription)")
            return
        }
    }
    DataSingleton.shared.setCurrentWorkspace(UUIDDirectory)
    let needsUpdate = updateWorkspace(UUIDDirectory)
    guard let docsFolderURL = Bundle.main.url(forResource: "Files", withExtension: nil) else {
        Logger.shared.logMe("Can't find Bundle URL?")
        return
    }
    if !needsUpdate {
        return
    }
    do {
        let files = try fm.contentsOfDirectory(at: docsFolderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        for file in files {
            let newURL = UUIDDirectory.appendingPathComponent(file.lastPathComponent)
            var shouldMergeDirectory = false
            var isDirectory: ObjCBool = false
            if fm.fileExists(atPath: newURL.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    shouldMergeDirectory = true
                } else {
                    Logger.shared.logMe(newURL.path)
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
    if !FileManager.default.fileExists(atPath: UUIDDirectory.appendingPathComponent("AppliedTheme").path) {
        var newURL = UUIDDirectory.appendingPathComponent("AppliedTheme")
        do {
            try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: false)
            newURL = newURL.appendingPathComponent("HomeDomain")
            try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: false)
            newURL = newURL.appendingPathComponent("Library")
            try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: false)
            newURL = newURL.appendingPathComponent("WebClips")
            try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: false)
        } catch {

        }
    }
    if !FileManager.default.fileExists(atPath: UUIDDirectory.appendingPathComponent("AppliedOperations").path) {
        let newURL = UUIDDirectory.appendingPathComponent("AppliedOperations")
        do {
            try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: false)
        } catch {

        }
    }
    // reset the location manager
    LocationManager.shared.resetValues()
}

func generateBackup() {
    guard let script = Bundle.main.url(forResource: "CreateBackup", withExtension: "sh") else {
            Logger.shared.logMe("Error locating CreateBackup.sh")
            return }
        do {
            try shell(script, arguments: ["EnabledTweaks", "Backup"], workingDirectory: documentsDirectory)
        } catch {
            Logger.shared.logMe("Error running CreateBackup.sh")
        }
}

// MARK: Apply Tweaks
func applyTweaks() {
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
    
    // Create the webclip icons
     if DataSingleton.shared.allEnabledTweaks().contains(.themes) {
         ThemingManager.shared.applyTheme()
     }
    
    // Create the custom operations
    if DataSingleton.shared.allEnabledTweaks().contains(.operations) {
        do {
            try CustomOperationsManager.shared.applyOperations()
        } catch {
            Logger.shared.logMe("Error applying Custom Operations: " + error.localizedDescription)
            return
        }
    }
    for tweak in DataSingleton.shared.allEnabledTweaks() {
        do {
            let files = try fm.contentsOfDirectory(at: workspaceURL.appendingPathComponent("\(tweak.rawValue)"), includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
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
    Logger.shared.logMe("Generating backup...")
    generateBackup()
    
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

// MARK: Remove Tweaks
func removeTweaks(deepClean: Bool) {
    Logger.shared.logMe("Copying restore files...")
    
    // Set the source directory path (assuming it's located in the binary directory)
    guard let sourceDir = Bundle.main.url(forResource: "restore\(deepClean ? "-deepclean" : "")", withExtension: nil) else {
        Logger.shared.logMe("Error finding resource \"restore\(deepClean ? "-deepclean" : "")\"")
        return
    }
    
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
    
    // Add files to the enabled tweaks directory
    do {
        let files = try fm.contentsOfDirectory(at: sourceDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        for file in files {
            let newURL = enabledTweaksDirectory.appendingPathComponent(file.lastPathComponent)
            if !FileManager.default.fileExists(atPath: newURL.path) {
                try FileManager.default.copyItem(at: file, to: newURL)
            } else {
                Logger.shared.logMe("WARNING: File exists at path \"\(newURL.path)\", skipping")
                continue
            }
        }
    } catch {
        Logger.shared.logMe("Error adding files to EnabledTweaks directory: \(error.localizedDescription)")
        return
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
    Logger.shared.logMe("Generating backup...")
    generateBackup()
    
    // Restore files
    Logger.shared.logMe("Restoring backup to device...")
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

// MARK: Bootloop
func bootloopDevice() {
    Logger.shared.logMe("Copying bootloop files...")
    
    // Set the source directory path (assuming it's located in the binary directory)
    guard let sourceDir = Bundle.main.url(forResource: "bootloop", withExtension: nil) else {
        Logger.shared.logMe("Error finding resource \"bootloop\"")
        return
    }
    
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
    
    // Add files to the enabled tweaks directory
    do {
        let files = try fm.contentsOfDirectory(at: sourceDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        for file in files {
            let newURL = enabledTweaksDirectory.appendingPathComponent(file.lastPathComponent)
            if !FileManager.default.fileExists(atPath: newURL.path) {
                try FileManager.default.copyItem(at: file, to: newURL)
            } else {
                Logger.shared.logMe("WARNING: File exists at path \"\(newURL.path)\", skipping")
                continue
            }
        }
    } catch {
        Logger.shared.logMe("Error adding files to EnabledTweaks directory: \(error.localizedDescription)")
        return
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
    Logger.shared.logMe("Generating backup...")
    generateBackup()
    
    // Restore files
    Logger.shared.logMe("Restoring backup to device...")
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

func fixStringBug(_ str: String) -> String {
    if str.contains("SwiftNativeNSObject") {
        print("had to fix")
        return str.components(separatedBy: "undefined.")[1]
    } else {
        return str
    }
}

func getDevices() -> [Device] {
    if !fm.fileExists(atPath: documentsDirectory.path) {
        do {
            try fm.createDirectory(atPath: documentsDirectory.path, withIntermediateDirectories: false, attributes: nil)
            Logger.shared.logMe("Documents folder created")
        } catch {
            Logger.shared.logMe("Error creating Documents folder: \(error.localizedDescription)")
            return []
        }
    }
    guard let exec = Bundle.main.url(forResource: "idevice_id", withExtension: "") else { return [] }
    do {
        let devices = try executeWIN(exec, arguments:["-l"], workingDirectory: documentsDirectory) // array of UUIDs
        if devices.contains("ERROR") {
            Logger.shared.logMe("idevice_id: \(devices)")
            return []
        }
        let devicesArr = devices.split(separator: "\n", omittingEmptySubsequences: true)
        
        var deviceStructs: [Device] = []
        for d in devicesArr {
            guard let exec2 = Bundle.main.url(forResource: "idevicename", withExtension: "") else { continue }
            let deviceName = try execute2(exec2, arguments:["-u", String(d)], workingDirectory: documentsDirectory).replacingOccurrences(of: "\n", with: "")
            if deviceName.contains("ERROR") {
                Logger.shared.logMe("idevicename: \(deviceName)")
                continue
            }
            guard let exec3 = Bundle.main.url(forResource: "ideviceinfo", withExtension: "") else { continue }
            let deviceVersion = try execute2(exec3, arguments:["-u", String(d), "-k", "ProductVersion"], workingDirectory: documentsDirectory).replacingOccurrences(of: "\n", with: "")
            if deviceVersion.contains("ERROR") {
                Logger.shared.logMe("ideviceinfo: \(deviceVersion)")
                continue
            }
            let deviceType = try execute2(exec3, arguments:["-u", String(d), "-k", "ProductType"], workingDirectory: documentsDirectory).replacingOccurrences(of: "\n", with: "")
            Logger.shared.logMe("> Connected to \(deviceType) on iOS \(deviceVersion).")
            let ipad: Bool = !(try execute2(exec3, arguments:["-u", String(d), "-k", "ProductName"], workingDirectory: documentsDirectory).replacingOccurrences(of: "\n", with: "").contains("iPhone OS"))
            let device = Device(uuid: String(d), name: fixStringBug(deviceName), version: deviceVersion, ipad: ipad)
            if let _ = Int(device.version.split(separator: ".")[0]) {
                deviceStructs.append(device)
            } else if device.version.contains("SwiftNativeNSObject") {
                let newVersion: String = device.version.components(separatedBy: "undefined.")[1]
                if newVersion != "" {
                    let newDevice = Device(uuid: String(d), name: fixStringBug(deviceName), version: newVersion, ipad: ipad)
                    deviceStructs.append(newDevice)
                }
            }
        }
        return deviceStructs
    } catch {
        print(error.localizedDescription)
        return []
    }
}

func getHomeScreenAppsNew() -> [AppInfo] {
    #if CLI
    guard let exec = Bundle.module.url(forResource: "homeScreenApps", withExtension: "exe") else {
        Logger.shared.logMe("Error locating homeScreenAppsNew")
        return []
    }
    #else
    guard let exec = Bundle.main.url(forResource: "homeScreenAppsNew", withExtension: "") else {
        Logger.shared.logMe("Error locating homeScreenAppsNew")
        return []
    }
    #endif
    guard let currentUUID = DataSingleton.shared.getCurrentUUID() else {
        Logger.shared.logMe("Error getting current UUID")
        return []
    }
    guard let appsPlist = try? execute2(exec, arguments:["-u", currentUUID], workingDirectory: documentsDirectory) else {
        Logger.shared.logMe("Error running homeScreenAppsNew")
        return []
    }
    guard let plistData = fixStringBug(appsPlist).data(using: .utf8) else {
        Logger.shared.logMe("Error converting apps text to data")
        return []
    }
    guard let plistDict = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: [String: Any]] else {
        Logger.shared.logMe("Error reading apps data to dict")
        return []
    }

    var appInfos = [AppInfo]()

    for (bundleId, appDict) in plistDict {
        guard let name = appDict["name"] as? String,
              let oldWebclipExists = appDict["old_webclip_exists"] as? Bool else {
                  Logger.shared.logMe("Error reading old_webclip_exists for bundle id \(bundleId)")
                  continue
        }

        let iconData = appDict["icon"] as? Data
        let themedIconData = appDict["themed_icon"] as? Data

        let appInfo = AppInfo(bundleId: bundleId,
                              name: name,
                              oldWebclipExists: oldWebclipExists,
                              icon: iconData,
                              themedIcon: themedIconData)
        appInfos.append(appInfo)
    }

    return appInfos
}

func getHomeScreenApps() -> [String:String] {
    guard let exec = Bundle.main.url(forResource: "homeScreenApps", withExtension: "") else {
        Logger.shared.logMe("Error locating homeScreenApps")
        return [:]
    }
    guard let currentUUID = DataSingleton.shared.getCurrentUUID() else {
        Logger.shared.logMe("Error getting current UUID")
        return [:]
    }
    do {
        let appsCSV = try execute2(exec, arguments:["-u", currentUUID], workingDirectory: documentsDirectory)
        var dict = [String:String]()
        for line in appsCSV.split(separator: "\n") {
            // fucking nightmare
            let components = line.unicodeScalars.map{Character($0)}.split(separator: ",")
            if components.count == 2 {
                dict[String(components[0])] = String(components[1])
            } else {
                dict[String(components[0])] = String(components[0])
            }
        }
        Logger.shared.logMe("\(dict)")
        return dict
    } catch {
        Logger.shared.logMe("Error processing apps csv")
        return [:]
    }
}

func getHomeScreenNumPages() -> Int {
    guard let exec = Bundle.main.url(forResource: "homeScreenApps", withExtension: "") else {
        Logger.shared.logMe("Error locating homeScreenApps")
        return 1
    }
    guard let currentUUID = DataSingleton.shared.getCurrentUUID() else {
        Logger.shared.logMe("Error getting current UUID")
        return 1
    }
    do {
        var pagesStr = try execute2(exec, arguments:["-u", currentUUID, "-n"], workingDirectory: documentsDirectory)
        pagesStr = pagesStr.replacingOccurrences(of: "\n", with: "")
        let pages = Int(pagesStr) ?? 1
        return pages
    } catch {
        Logger.shared.logMe("Error processing apps csv")
        return 1
    }
}
