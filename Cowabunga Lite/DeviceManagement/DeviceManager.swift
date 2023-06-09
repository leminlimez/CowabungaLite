//
//  Utilities.swift
//  CowabungaJailed
//
//  Created by Rory Madden on 20/3/2023.
//

import Foundation

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
    #if CLI
    guard let docsFolderURL = Bundle.module.url(forResource: "Files", withExtension: nil) else {
        Logger.shared.logMe("Can't find Bundle URL?")
        return
    }
    #else
    guard let docsFolderURL = Bundle.main.url(forResource: "Files", withExtension: nil) else {
        Logger.shared.logMe("Can't find Bundle URL?")
        return
    }
    #endif
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
}

func generateBackup() {
    #if CLI
    guard let script = Bundle.module.url(forResource: "CreateBackup", withExtension: "sh") else {
            Logger.shared.logMe("Error locating CreateBackup.sh")
            return }
    #else
    guard let script = Bundle.main.url(forResource: "CreateBackup", withExtension: "sh") else {
            Logger.shared.logMe("Error locating CreateBackup.sh")
            return }
    #endif
        do {
            #if CLI
            let task = Process()
            let gitPath = "C:\\Program Files\\Git\\git-bash.exe"
            task.launchPath = gitPath
            if !FileManager.default.fileExists(atPath: gitPath) {
                print("Git bash not found at the path \(gitPath)")
                print("If you do not have it, install it from here: https://gitforwindows.org/")
                return
            }
            task.arguments = [script.path, "EnabledTweaks", "Backup"]
            task.currentDirectoryPath = documentsDirectory.path
            task.launch()
            task.waitUntilExit()
            print("Backup created")
            #else
            try shell(script, arguments: ["EnabledTweaks", "Backup"], workingDirectory: documentsDirectory)
            #endif
        } catch {
            Logger.shared.logMe("Error running CreateBackup.sh")
        }
}

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
         #if CLI
         // TODO: Fix me
         WindowsThemingManager.shared.applyTheme()
         #else
         ThemingManager.shared.applyTheme()
         #endif
//         #if CLI
//         let task = Process()
//         task.launchPath = "C:\\Program Files\\Git\\git-bash.exe"
//         task.arguments = [script.path, "EnabledTweaks", "Backup"]
//         task.currentDirectoryPath = documentsDirectory.path
//         task.launch()
//         task.waitUntilExit()
//         print("Backup created")
//         #else
//         ThemingManager.shared.applyTheme()
//         #endif
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
    generateBackup()
    
    // Restore files
    #if CLI
    guard let exec = Bundle.module.url(forResource: "WINidevicebackup2", withExtension: "exe") else {
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
    #else
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
    #endif
}

func getDevices() -> [Device] {
    let workspaceDirectory = documentsDirectory.appendingPathComponent("Workspace")
    if !fm.fileExists(atPath: documentsDirectory.path) {
        do {
            try fm.createDirectory(atPath: documentsDirectory.path, withIntermediateDirectories: false, attributes: nil)
            Logger.shared.logMe("Documents folder created")
        } catch {
            Logger.shared.logMe("Error creating Documents folder: \(error.localizedDescription)")
            return []
        }
    }
    #if CLI
    guard let exec = Bundle.module.url(forResource: "WINidevice_id", withExtension: "exe") else { return [] }
    #else
    guard let exec = Bundle.main.url(forResource: "idevice_id", withExtension: "") else { return [] }
    #endif
    do {
        let devices = try executeWIN(exec, arguments:["-l"], workingDirectory: documentsDirectory) // array of UUIDs
        if devices.contains("ERROR") {
            print(devices)
            return []
        }
        let devicesArr = devices.split(separator: "\n", omittingEmptySubsequences: true)
        
        var deviceStructs: [Device] = []
        for d in devicesArr {
            #if CLI
            guard let exec2 = Bundle.module.url(forResource: "WINidevicename", withExtension: "exe") else { continue }
            let deviceName = try executeWIN(exec2, arguments:["-u", String(d)], workingDirectory: documentsDirectory).replacingOccurrences(of: "\n", with: "")
            guard let exec3 = Bundle.module.url(forResource: "WINideviceinfo", withExtension: "exe") else { continue }
            let deviceVersion = try executeWIN(exec3, arguments:["-u", String(d), "-k", "ProductVersion"], workingDirectory: documentsDirectory).replacingOccurrences(of: "\n", with: "")
            let ipad: Bool = (try executeWIN(exec3, arguments:["-u", String(d), "-k", "ProductName"], workingDirectory: documentsDirectory).replacingOccurrences(of: "\n", with: "") != "iPhone OS")
            let device = Device(uuid: String(d), name: deviceName, version: deviceVersion, ipad: ipad)
            deviceStructs.append(device)
            
            #else
            guard let exec2 = Bundle.main.url(forResource: "idevicename", withExtension: "") else { continue }
            let deviceName = try execute2(exec2, arguments:["-u", String(d)], workingDirectory: documentsDirectory).replacingOccurrences(of: "\n", with: "")
            guard let exec3 = Bundle.main.url(forResource: "ideviceinfo", withExtension: "") else { continue }
            let deviceVersion = try execute2(exec3, arguments:["-u", String(d), "-k", "ProductVersion"], workingDirectory: documentsDirectory).replacingOccurrences(of: "\n", with: "")
            let ipad: Bool = (try execute2(exec3, arguments:["-u", String(d), "-k", "ProductName"], workingDirectory: documentsDirectory).replacingOccurrences(of: "\n", with: "") != "iPhone OS")
            let device = Device(uuid: String(d), name: deviceName, version: deviceVersion, ipad: ipad)
            deviceStructs.append(device)
            #endif
        }
        return deviceStructs
    } catch {
        print(error.localizedDescription)
        return []
    }
}

func getHomeScreenAppsNew() -> [AppInfo] {
    guard let exec = Bundle.main.url(forResource: "homeScreenAppsNew", withExtension: "") else {
        Logger.shared.logMe("Error locating homeScreenAppsNew")
        return []
    }
    guard let currentUUID = DataSingleton.shared.getCurrentUUID() else {
        Logger.shared.logMe("Error getting current UUID")
        return []
    }
    guard let appsPlist = try? execute2(exec, arguments:["-u", currentUUID], workingDirectory: documentsDirectory) else {
        Logger.shared.logMe("Error running homeScreenAppsNew")
        return []
    }
    guard let plistData = appsPlist.data(using: .utf8) else {
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
