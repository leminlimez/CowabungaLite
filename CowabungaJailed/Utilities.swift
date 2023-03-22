//
//  Utilities.swift
//  CowabungaJailed
//
//  Created by Rory Madden on 20/3/2023.
//

import Foundation

class Logger: ObservableObject {
    static let shared = Logger()
    
    @Published var logText = ""

    func logMe(_ message: String) {
        logText += "\(message)\n"
    }
}

enum Tweak: String {
    case footnote = "Footnote"
    case statusBar = "StatusBar"
    case skipSetup = "SkipSetup"
    case dynamicIsland = "DynamicIsland"
}

class DataSingleton {
    static let shared = DataSingleton()
    private var currentUUID: String?
    private var currentWorkspace: URL?
    private var enabledTweaks: Set<Tweak> = []
    
    func setTweakEnabled(_ tweak: Tweak, isEnabled: Bool) {
        if isEnabled {
            enabledTweaks.insert(tweak)
        } else {
            enabledTweaks.remove(tweak)
        }
    }
    
    func isTweakEnabled(_ tweak: Tweak) -> Bool {
        return enabledTweaks.contains(tweak)
    }
    
    func allEnabledTweaks() -> Set<Tweak> {
        return enabledTweaks
    }
    
    func setCurrentUUID(_ UUID: String) {
        Logger.shared.logMe("Setting UUID to \(UUID)")
        currentUUID = UUID
        setupWorkspaceForUUID(UUID)
    }
    
    func getCurrentUUID() -> String? {
        return currentUUID
    }
    
    func resetCurrentUUID() {
        Logger.shared.logMe("Resetting UUID")
        currentUUID = nil
    }
    
    func setCurrentWorkspace(_ workspaceURL: URL) {
        currentWorkspace = workspaceURL
    }
    
    func getCurrentWorkspace() -> URL? {
        return currentWorkspace
    }
}

extension FileManager {
    func mergeDirectory(at sourceURL: URL, to destinationURL: URL) throws {
        try createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
        let contents = try contentsOfDirectory(at: sourceURL, includingPropertiesForKeys: nil, options: [])
        for item in contents {
            let newItemURL = destinationURL.appendingPathComponent(item.lastPathComponent)
            var isDirectory: ObjCBool = false
            if fileExists(atPath: newItemURL.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    try mergeDirectory(at: item, to: newItemURL)
                } else {
                    let newFileAttributes = try fm.attributesOfItem(atPath: newItemURL.path)
                    let oldFileAttributes = try fm.attributesOfItem(atPath: item.path)
                    if let newModifiedTime = newFileAttributes[.modificationDate] as? Date,
                       let oldModifiedTime = oldFileAttributes[.modificationDate] as? Date,
                       newModifiedTime.compare(oldModifiedTime) == .orderedAscending {
                            try removeItem(at: newItemURL)
                            try copyItem(at: item, to: newItemURL)
                    }
                }
            } else {
                try copyItem(at: item, to: newItemURL)
            }
        }
    }
}

func setupWorkspaceForUUID(_ UUID: String) {
    let workspaceDirectory = documentsDirectory.appendingPathComponent("Workspace")
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
    let editingDirectory = UUIDDirectory.appendingPathComponent("Files")
    guard let docsFolderURL = Bundle.main.url(forResource: "Files", withExtension: nil) else {
        Logger.shared.logMe("Can't find Bundle URL?")
        return
    }
    do {
        let files = try fm.contentsOfDirectory(at: docsFolderURL, includingPropertiesForKeys: nil)
        for file in files {
            let newURL = editingDirectory.appendingPathComponent(file.lastPathComponent)
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
//    if !fm.fileExists(atPath: editingDirectory.path) {
//        guard let docsFolderURL = Bundle.main.url(forResource: "Files", withExtension: nil) else {
//            Logger.shared.logMe("Can't find Bundle URL?")
//            return
//        }
//        do {
//            try fm.copyItem(at: docsFolderURL, to: editingDirectory)
//            Logger.shared.logMe("Successfully copied Files folder")
//        } catch {
//            Logger.shared.logMe("Error copying Files folder: \(error)")
//            return
//        }
//    }
}

func shell(_ scriptURL: URL, arguments: [String] = [], workingDirectory: URL? = nil) throws {
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe

    task.executableURL = URL(fileURLWithPath: "/bin/sh")
    let scriptArguments = arguments.joined(separator: " ")
    task.arguments = ["-c", "source \(scriptURL.path) \(scriptArguments)"]
    if let workingDirectory = workingDirectory {
        task.currentDirectoryURL = workingDirectory
    }
    
    try task.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: data, encoding: .utf8) {
        Logger.shared.logMe(output)
    }
}

func execute(_ execURL: URL, arguments: [String] = [], workingDirectory: URL? = nil) throws {
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    
    let bundlePath = Bundle.main.bundlePath
    let frameworksPath = (bundlePath as NSString).appendingPathComponent("Contents/Frameworks")
    let environment = ["DYLD_LIBRARY_PATH": frameworksPath]
    task.environment = environment

    task.executableURL = execURL
    task.arguments = arguments
    if let workingDirectory = workingDirectory {
        task.currentDirectoryURL = workingDirectory
    }
    
    try task.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: data, encoding: .utf8) {
        Logger.shared.logMe(output)
    }
}

func execute2(_ execURL: URL, arguments: [String] = [], workingDirectory: URL? = nil) throws -> String {
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    
    let bundlePath = Bundle.main.bundlePath
    let frameworksPath = (bundlePath as NSString).appendingPathComponent("Contents/Frameworks")
    let environment = ["DYLD_LIBRARY_PATH": frameworksPath]
    task.environment = environment

    task.executableURL = execURL
    task.arguments = arguments
    if let workingDirectory = workingDirectory {
        task.currentDirectoryURL = workingDirectory
    }
    
    try task.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: data, encoding: .utf8) {
        return output
    }
    return ""
}

func printDirectoryTree(at path: URL, level: Int) {
    let prefix = String(repeating: "│   ", count: level > 0 ? level - 1 : 0) + (level > 0 ? "├── " : "")
    
    do {
        let contents = try fm.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
        for url in contents {
            let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
            Logger.shared.logMe(prefix + url.lastPathComponent)
            if isDirectory {
                printDirectoryTree(at: url, level: level + 1)
            }
        }
    } catch {
        Logger.shared.logMe(error.localizedDescription)
    }
}

func copyFolderFromBundleToDocuments() -> Bool {
    guard let docsFolderURL = Bundle.main.url(forResource: "Files", withExtension: nil) else {
        Logger.shared.logMe("Can't find Bundle URL?")
        return false
    }

    let destinationURL = documentsDirectory.appendingPathComponent("Files")

//    if fm.fileExists(atPath: destinationURL.path) {
//        do {
//            try fm.removeItem(at: destinationURL)
//            Logger.shared.logMe("Successfully removed existing Files folder from Documents directory")
//        } catch {
//            Logger.shared.logMe("Error removing existing Files folder: \(error)")
//            return false
//        }
//    }
//
//    do {
//        try fm.copyItem(at: docsFolderURL, to: destinationURL)
//        Logger.shared.logMe("Successfully copied Files folder to Documents directory")
//    } catch {
//        Logger.shared.logMe("Error copying Files folder: \(error)")
//        return false
//    }
//
//    return true
    
    do {
        let files = try fm.contentsOfDirectory(at: docsFolderURL, includingPropertiesForKeys: nil)
        for file in files {
            let newURL = destinationURL.appendingPathComponent(file.lastPathComponent)
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
                       newModifiedTime.compare(oldModifiedTime) == .orderedAscending {
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
        return false
    }
    return true
}

struct Device {
    let uuid: String
    let name: String
}

func getDevices() -> [Device] {
    guard let exec = Bundle.main.url(forResource: "idevice_id", withExtension: "") else { return [] }
    do {
        let devices = try execute2(exec, arguments:["-l"], workingDirectory: documentsDirectory) // array of UUIDs
        if devices.contains("ERROR") {
            return []
        }
        let devicesArr = devices.split(separator: "\n", omittingEmptySubsequences: true)
        
        var deviceStructs: [Device] = []
        for d in devicesArr {
            guard let exec2 = Bundle.main.url(forResource: "idevicename", withExtension: "") else { continue }
            let deviceName = try execute2(exec2, arguments:["-u", String(d)], workingDirectory: documentsDirectory).replacingOccurrences(of: "\n", with: "")
            let device = Device(uuid: String(d), name: deviceName)
            deviceStructs.append(device)
        }
        return deviceStructs
    } catch {
        return []
    }
}

