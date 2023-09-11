//
//  OperationObjects.swift
//  Cowabunga Lite
//
//  Created by lemin on 7/21/23.
//

import Foundation
import ZIPFoundation
import SwiftUI

struct AdvancedOperationFolder: Identifiable {
    var id = UUID()
    var name: String
    var directory: Bool
}

struct AdvancedObject: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var author: String
    var version: String
    var icon: String?
    var locked: Bool // if it has been exported, so that user cannot change certain properties like author and version
    var enabled: Bool // if the tweak is enabled
    
    init(name: String, author: String = "", version: String = "1.0", icon: String? = nil, locked: Bool = false, enabled: Bool = false) {
        self.name = name
        self.author = author
        self.version = version
        self.icon = icon
        self.locked = locked
        self.enabled = enabled
    }
    
    func getImage() -> NSImage? {
        if let icn = icon {
            let iconPath = CustomOperationsManager.shared.getOperationsFolder().appendingPathComponent(name).appendingPathComponent(icn)
            if FileManager.default.fileExists(atPath: iconPath.path) {
                return NSImage(contentsOf: iconPath)
            }
        }
        return nil
    }
    
    func createFiles() throws {
        let folder = CustomOperationsManager.shared.getOperationsFolder().appendingPathComponent(name)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: false)
        
        let newPlist: [String: Any] = [
            "Author": author,
            "Version": version,
            "Locked": locked
        ]
        
        let plistData = try PropertyListSerialization.data(fromPropertyList: newPlist, format: .xml, options: 0)
        try plistData.write(to: folder.appendingPathComponent("Info.plist"))
    }
    
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
                if let v = try? f.resourceValues(forKeys: [.isDirectoryKey]) {
                    if v.isDirectory ?? false {
                        dir = true
                    }
                }
                folders.append(.init(name: f.lastPathComponent, directory: dir))
            }
        } catch {
            print(error.localizedDescription)
        }
        return folders
    }
    
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
}
