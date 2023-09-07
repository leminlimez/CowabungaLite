//
//  CustomOperationsManager.swift
//  Cowabunga Lite
//
//  Created by lemin on 7/21/23.
//
// Main Manager for Custom Operations

import Foundation

class CustomOperationsManager: ObservableObject {
    static let shared = CustomOperationsManager()
    @Published var operations: [AdvancedObject] = []
    @Published var enabledOperations: [Int] = []
    
    // MARK: Operations List as a Whole
    public func getOperationsFolder() -> URL {
        let operationsFolder = documentsDirectory.appendingPathComponent("Operations")
        if !FileManager.default.fileExists(atPath: operationsFolder.path) {
            try? FileManager.default.createDirectory(at: operationsFolder, withIntermediateDirectories: false)
        }
        return operationsFolder
    }
    
    public func getOperations() {
        let operationsFolder = getOperationsFolder()
        operations.removeAll(keepingCapacity: true)
        do {
            for t in try FileManager.default.contentsOfDirectory(at: operationsFolder, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
                if let op = getOperationInfo(url: t) {
                    operations.append(op)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func getNewName(_ name: String, i: Int) -> String {
        if !FileManager.default.fileExists(atPath: getOperationsFolder().appendingPathComponent("\(name) \(i)").path) {
            return "\(name) \(i)"
        }
        return getNewName(name, i: i+1)
    }
    
    // MARK: Import Operation
    public func importOperation(_ url: URL) throws {
        let fm = FileManager.default
        
        if url.pathExtension == "cowperation" {
            let unzipURL = fm.temporaryDirectory.appendingPathComponent("cowperation_unzip")
            try? fm.removeItem(at: unzipURL)
            try fm.unzipItem(at: url, to: unzipURL)
            for folder in (try fm.contentsOfDirectory(at: unzipURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)) {
                // check if it is a cowabunga lite file
                let name = folder.lastPathComponent
                let plistURL = folder.appendingPathComponent("Info.plist")
                if fm.fileExists(atPath: plistURL.path) {
                    do {
                        let plistData = try Data(contentsOf: plistURL)
                        if let plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any], plist["Locked"] != nil {
                            var newPlist = plist
                            newPlist["Locked"] = true
                            let newData = try PropertyListSerialization.data(fromPropertyList: newPlist, format: .xml, options: 0)
                            try newData.write(to: plistURL)
                            
                            // get a new name if it is already taken
                            var finalName = name
                            if fm.fileExists(atPath: getOperationsFolder().appendingPathComponent(name).path) {
                                finalName = getNewName(finalName, i: 2)
                            }
                            
                            // import
                            try fm.moveItem(at: folder, to: getOperationsFolder().appendingPathComponent(finalName))
                        }
                    } catch {
                        throw "Error importing operation \"\(name)\": \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    // MARK: Apply Operations
    public func applyOperations() throws {
        guard let toMoveFolder = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent("AppliedOperations") else { throw "No Workspace Found!" }
        if FileManager.default.fileExists(atPath: toMoveFolder.path) {
            try FileManager.default.removeItem(at: toMoveFolder)
        }
        try FileManager.default.createDirectory(at: toMoveFolder, withIntermediateDirectories: false)
        
        for op in enabledOperations {
            try operations[op].applyOperation()
        }
    }
    
    // MARK: Managing An Operation
    // enable an operation
    public func toggleOperation(name: String, enabled: Bool) {
        var operationId = -1
        for (i, o) in operations.enumerated() {
            if (o.name == name) {
                operationId = i
                break
            }
        }
        if operationId == -1 {
            return
        }
        
        operations[operationId].enabled = enabled
        if enabled {
            enabledOperations.append(operationId)
            DataSingleton.shared.setTweakEnabled(.operations, isEnabled: true)
        } else {
            print(enabledOperations)
            for (i, v) in enabledOperations.enumerated() {
                print(i)
                if v == operationId {
                    enabledOperations.remove(at: i)
                }
            }
            print(enabledOperations)
            if enabledOperations.isEmpty {
                DataSingleton.shared.setTweakEnabled(.operations, isEnabled: false)
            }
        }
    }
    
    // get operation info
    private func getOperationInfo(url: URL) -> AdvancedObject? {
        do {
            guard let _ = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) else { throw "Could not get the contents of directory" }
            
            // get the operation info
            let infoPlist = url.appendingPathComponent("Info.plist")
            if !FileManager.default.fileExists(atPath: infoPlist.path) {
                throw "Could not find Info.plist"
            }
            let plistData = try Data(contentsOf: infoPlist)
            let plist = try PropertyListSerialization.propertyList(from: plistData, format: nil) as! [String: Any]
            
            // get the data
            let author: String = plist["Author"] as? String ?? ""
            let version: String = plist["Version"] as? String ?? "1.0"
            let locked: Bool = plist["Locked"] as? Bool ?? false
            
            return .init(name: url.lastPathComponent, author: author, version: version, locked: locked)
        } catch {
            Logger.shared.logMe("Custom Operations Error: \(error.localizedDescription) for operation \"\(url.lastPathComponent)\"")
        }
        return nil
    }
    
    // deleting an operation
    public func deleteOperation(name: String) {
        let operationPath = getOperationsFolder().appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: operationPath.path) {
            try? FileManager.default.removeItem(at: operationPath)
        }
        // update operations
        getOperations()
    }
    
    // creating an operation
    public func createOperation() throws -> AdvancedObject {
        var name = "New Operation"
        if FileManager.default.fileExists(atPath: getOperationsFolder().appendingPathComponent(name).path) {
            name = getNewOperationName()
        }
        let newOp = AdvancedObject.init(name: name)
        try newOp.createFiles()
        operations.append(newOp)
        return newOp
    }
    
    // updating an operation
    public func updateOperation(oldName: String, newName: String, newAuthor: String, newVersion: String) throws {
        var currentOperationIndex = -1
        for (i, v) in operations.enumerated() {
            if v.name == oldName {
                currentOperationIndex = i
                break;
            }
        }
        if currentOperationIndex == -1 {
            throw "Error: Could not find the old operation with name \"\(oldName)\""
        }
        
        // update everything else first
        let oldFolder = getOperationsFolder().appendingPathComponent(oldName)
        let infoPlist = oldFolder.appendingPathComponent("Info.plist")
        let plistData = try Data(contentsOf: infoPlist)
        var plist = try PropertyListSerialization.propertyList(from: plistData, format: nil) as! [String: Any]
        
        if newAuthor != operations[currentOperationIndex].author {
            plist["Author"] = newAuthor
            operations[currentOperationIndex].author = newAuthor
        }
        if newVersion != operations[currentOperationIndex].version {
            plist["Version"] = newVersion
            operations[currentOperationIndex].version = newVersion
        }
        
        let newData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try newData.write(to: infoPlist)
        
        // finally, update the name
        if oldName != newName {
            let newFolder = getOperationsFolder().appendingPathComponent(newName)
            if FileManager.default.fileExists(atPath: newFolder.path) {
                throw "Error: Operation with name \"\(newName)\" already exists!"
            } else {
                try FileManager.default.moveItem(at: oldFolder, to: newFolder)
                operations[currentOperationIndex].name = newName
            }
        }
    }
    
    // getting an operation
    public func getOperation(name: String) throws -> AdvancedObject {
        for op in operations {
            if op.name == name {
                return op
            }
        }
        throw "Could not find operation of name \"\(name)\""
    }
    
    // MARK: Other Useful Functions
    func getNewOperationName(currentNum: Int = 1) -> String {
        if FileManager.default.fileExists(atPath: getOperationsFolder().appendingPathComponent("New Operation \(currentNum)").path) {
            return getNewOperationName(currentNum: currentNum + 1)
        } else {
            return "New Operation \(currentNum)"
        }
    }
}
