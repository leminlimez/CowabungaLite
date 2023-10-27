//
//  OperationObjects.swift
//  Cowabunga Lite
//
//  Created by lemin on 7/21/23.
//

import Foundation
import ZIPFoundation
import SwiftUI

// MARK: Folder in a Custom Operation (File Editor View)
struct AdvancedOperationFolder: Identifiable {
    var id = UUID()
    var name: String
    var directory: Bool
    var ext: String? = nil
}


// MARK: Operation Preference Classes
// Main Class
class AdvancedOperationPref: Identifiable {
    var id = UUID()
    
    var filePath: String
    var label: String
    
    init(
        filePath: String, label: String
    ) {
        self.filePath = filePath
        self.label = label
    }
}

// Plist Class
enum PlistPrefValueType {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
}

class PlistPref: AdvancedOperationPref {
    var key: String
    var value: PlistPrefValueType
    
    init(
        filePath: String, label: String,
        key: String, value: PlistPrefValueType
    ) {
        self.key = key
        self.value = value
        super.init(filePath: filePath, label: label)
    }
}

// File Replacement Class
class FileReplacementPref: AdvancedOperationPref {
    var newFilePath: String
    
    init(
        filePath: String, label: String,
         newFilePath: String
    ) {
        self.newFilePath = newFilePath
        super.init(filePath: filePath, label: label)
    }
}


// MARK: Main Operation Object
struct AdvancedObject: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var author: String
    var version: String
    var icon: String?
    var locked: Bool // if it has been exported, so that user cannot change certain properties like author and version
    var hasPrefs: Bool // if it has preferences/certain properties or files that the user can modify, even when locked (loads separately)
    var enabled: Bool // if the tweak is enabled
    
    init(
        name: String, author: String = "", version: String = "1.0",
        icon: String? = nil,
        locked: Bool = false,
        hasPrefs: Bool = false,
        enabled: Bool = false
    ) {
        self.name = name
        self.author = author
        self.version = version
        self.icon = icon
        self.locked = locked
        self.hasPrefs = hasPrefs
        self.enabled = enabled
    }
    
    // MARK: Get The Icon
    func getImage() -> NSImage? {
        if let icn = icon {
            let iconPath = CustomOperationsManager.shared.getOperationsFolder().appendingPathComponent(name).appendingPathComponent(icn)
            if FileManager.default.fileExists(atPath: iconPath.path) {
                return NSImage(contentsOf: iconPath)
            }
        }
        return nil
    }
    
    // MARK: Create the Operation Files
    func createFiles() throws {
        let folder = CustomOperationsManager.shared.getOperationsFolder().appendingPathComponent(name)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: false)
        
        let newPlist: [String: Any] = [
            "Author": author,
            "Version": version,
            "Locked": locked,
            "UsesPreferences": hasPrefs
        ]
        
        let plistData = try PropertyListSerialization.data(fromPropertyList: newPlist, format: .xml, options: 0)
        try plistData.write(to: folder.appendingPathComponent("Info.plist"))
    }
    
    // MARK: Get the Sub Folders of a Folder (File Explore View)
    func getSubFolders(folderPath: String) -> [AdvancedOperationFolder] {
        var folders: [AdvancedOperationFolder] = []
        let paths = folderPath.split(separator: "/")
        var folderPath = CustomOperationsManager.shared.getOperationsFolder().appendingPathComponent(name)
        for path in paths {
            folderPath = folderPath.appendingPathComponent(String(path))
        }
        do {
            if !FileManager.default.fileExists(atPath: folderPath.path) {
                try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: false)
            }
            for f in try FileManager.default.contentsOfDirectory(at: folderPath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
                var dir = false
                var ext: String = ""
                if let v = try? f.resourceValues(forKeys: [.isDirectoryKey]) {
                    if v.isDirectory ?? false {
                        dir = true
                    } else {
                        ext = f.pathExtension
                    }
                }
                folders.append(.init(name: f.lastPathComponent, directory: dir, ext: ext))
            }
        } catch {
            print(error.localizedDescription)
        }
        return folders
    }
    
    // MARK: Get the Operation Domains (File Explore View)
    func getDomains() -> [String] {
        var domains: [String] = []
        do {
            let domainsFolder = CustomOperationsManager.shared.getOperationsFolder().appendingPathComponent(name).appendingPathComponent("Domains")
            if !FileManager.default.fileExists(atPath: domainsFolder.path) {
                try FileManager.default.createDirectory(at: domainsFolder, withIntermediateDirectories: false)
            }
            for d in try FileManager.default.contentsOfDirectory(at: domainsFolder, includingPropertiesForKeys: nil) {
                domains.append(d.lastPathComponent)
            }
        } catch {
            print(error.localizedDescription)
        }
        return domains
    }
    
    // MARK: Apply the Operation
    func applyOperation() throws {
        let domainsFolder = CustomOperationsManager.shared.getOperationsFolder().appendingPathComponent(name).appendingPathComponent("Domains")
        if !FileManager.default.fileExists(atPath: domainsFolder.path) {
            try FileManager.default.createDirectory(at: domainsFolder, withIntermediateDirectories: false)
        }
        guard let toMoveFolder = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent("AppliedOperations") else { throw "No Workspace Found!" }
        if !FileManager.default.fileExists(atPath: toMoveFolder.path) {
            try FileManager.default.createDirectory(at: toMoveFolder, withIntermediateDirectories: false)
        }
        
        if FileManager.default.fileExists(atPath: toMoveFolder.appendingPathComponent(".DS_Store").path) {
            try? FileManager.default.removeItem(at: toMoveFolder.appendingPathComponent(".DS_Store"))
        }
        
        for d in try FileManager.default.contentsOfDirectory(at: domainsFolder, includingPropertiesForKeys: nil) {
            if FileManager.default.fileExists(atPath: toMoveFolder.appendingPathComponent(d.lastPathComponent).path) {
                try FileManager.default.mergeDirectory(at: d, to: toMoveFolder.appendingPathComponent(d.lastPathComponent))
            } else {
                try FileManager.default.copyItem(at: d, to: toMoveFolder.appendingPathComponent(d.lastPathComponent))
            }
        }
    }
    
    // MARK: Export the Operation
    func exportOperation() throws -> URL {
        let operationFolder = CustomOperationsManager.shared.getOperationsFolder().appendingPathComponent(name)
        var archiveURL: URL?
        var error: NSError?
        let coordinator = NSFileCoordinator()
        
        // compress to zip
        coordinator.coordinate(readingItemAt: operationFolder, options: [.forUploading], error: &error) { (zipURL) in
            let tmpURL = try! fm.url(
                for: .itemReplacementDirectory,
                in: .userDomainMask,
                appropriateFor: zipURL,
                create: true
            ).appendingPathComponent("\(name).cowperation")
            try! fm.moveItem(at: zipURL, to: tmpURL)
            archiveURL = tmpURL
        }
        
        if let archiveURL = archiveURL {
            return archiveURL
        } else {
            throw "There was an error exporting the operation \"\(name)\""
        }
    }
    
    // MARK: Load and Return the Prefs
    func loadPreferences() -> [AdvancedOperationPref] {
        return []
    }
}
