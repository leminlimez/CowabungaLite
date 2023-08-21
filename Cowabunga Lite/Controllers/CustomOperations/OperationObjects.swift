//
//  OperationObjects.swift
//  Cowabunga Lite
//
//  Created by lemin on 7/21/23.
//

import Foundation

struct AdvancedOperationFolder: Identifiable {
    var id = UUID()
    var name: String
}

struct AdvancedObject: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var author: String
    var version: String
    var locked: Bool // if it has been exported, so that user cannot change certain properties like author and version
    var enabled: Bool // if the tweak is enabled
    
    init(name: String, author: String = "", version: String = "1.0", locked: Bool = false, enabled: Bool = false) {
        self.name = name
        self.author = author
        self.version = version
        self.locked = locked
        self.enabled = enabled
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
            for f in try FileManager.default.contentsOfDirectory(at: folderPath, includingPropertiesForKeys: nil) {
                folders.append(.init(name: f.lastPathComponent))
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
        
        for d in try FileManager.default.contentsOfDirectory(at: domainsFolder, includingPropertiesForKeys: nil) {
            try FileManager.default.copyItem(at: d, to: toMoveFolder.appendingPathComponent(d.lastPathComponent))
        }
    }
}