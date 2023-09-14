//
//  FileExplorerView.swift
//  Cowabunga Lite
//
//  Created by lemin on 7/21/23.
//

import SwiftUI

struct FileExplorerView: View {
    @FocusState private var nameFieldIsFocused: Bool
    @StateObject var operationsManager = CustomOperationsManager.shared
    @Binding var viewType: Int
    @Binding var operation: AdvancedObject
    @Binding var currentPath: String
    
    var gridItemLayout = [GridItem(.adaptive(minimum: 90))]
    
    // Folder Stuff
    @State var folders: [AdvancedOperationFolder] = []
    @State var selectedFolder: String = ""
    
    // Naming Stuff
    @State var enteringName: Bool = false
    @State var newName: String = ""
    
    // Picker/Menu Stuff
    @State var showPicker: Bool = false
    @State var showNewPopover: Bool = false
    @State var showSelectionView: Bool = false
    @State var selectionViewType: NewType = .domain
    @State var newTypeName: String = ""
    
    var body: some View {
        VStack {
            HStack {
                // MARK: Back Button
                Button(action: {
                    if currentPath == "Domains" {
                        viewType = 1
                    } else {
                        // refresh with new path
                        let toRemove = "/" + (currentPath.split(separator: "/").last ?? "")
                        currentPath = currentPath.replacingOccurrences(of: toRemove, with: "")
                        enteringName = false
                        selectedFolder = ""
                        updateFolders()
                    }
                }) {
                    Text("Back")
                }
                .padding(.vertical, 10)
                
                Spacer()
                
                if selectedFolder == "" {
                    // MARK: Import File
                    if currentPath != "Domains" {
                        ImageButton(systemName: "square.and.arrow.down", text: "Import File", action: {
                            showPicker = true
                        })
                    }
                    
                    // MARK: New Folder Button
                    ImageButton(systemName: "plus", text: "New", action: {
                        if currentPath == "Domains" {
                            newTypeName = ""
                            selectionViewType = .domain
                            showSelectionView = true
                        } else {
                            showNewPopover.toggle()
                        }
                    })
                    .popover(isPresented: $showNewPopover, arrowEdge: .bottom) {
                        VStack {
                            ImageButton(systemName: "folder.fill", text: "Folder", action: {
                                createNewFolder()
                            })
                            .padding(.top, 10)
                            .padding(.horizontal, 10)
                            ImageButton(systemName: "doc.fill", text: "File", action: {
                                newTypeName = ""
                                selectionViewType = .file
                                showSelectionView = true
                            })
                            .padding(.bottom, 10)
                            .padding(.horizontal, 10)
                        }
                    }
                } else {
                    // MARK: Delete Item Button
                    Button(action: {
                        if enteringName {
                            enteringName = false
                        }
                        // remove the folder
                        let folderDir = CustomOperationsManager.shared.getOperationsFolder().appendingPathComponent(operation.name).appendingPathComponent(currentPath).appendingPathComponent(selectedFolder)
                        do {
                            if FileManager.default.fileExists(atPath: folderDir.path) {
                                try FileManager.default.removeItem(at: folderDir)
                                // now, remove the folder in the folders array
                                if let folderOffset = folders.firstIndex(where: {$0.name == selectedFolder}) {
                                    folders.remove(at: folderOffset)
                                    selectedFolder = ""
                                }
                            }
                        } catch {
                            Logger.shared.logMe("Error deleting folder \"\(selectedFolder)\": \(error.localizedDescription)")
                        }
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Delete")
                        }
                    }
                }
            }
            
            // MARK: Title
            HStack {
                Text(currentPath.split(separator: "/").last ?? "Folders")
                    .font(.largeTitle)
                Spacer()
            }
            .padding(.vertical, 5)
            Divider()
                .padding(.vertical, 5)
            
            ScrollView {
                LazyVGrid(columns: gridItemLayout, spacing: 10) {
                    ForEach($folders) { folder in
                        VStack {
                            // MARK: Directory
                            if folder.directory.wrappedValue {
                                // MARK: Folder Icon
                                NiceButton(text: AnyView(
                                    VStack {
                                        Image(systemName: "folder.fill")
                                            .font(.system(size: 55))
                                            .foregroundColor(.blue)
                                            .padding(2)
                                    }
                                        .frame(width: 70, height: 70)
                                ), action: {
                                    if selectedFolder == folder.name.wrappedValue {
                                        if enteringName {
                                            enteringName = false
                                        } else {
                                            // open up the folder
                                            currentPath = currentPath + "/\(folder.name.wrappedValue)"
                                            updateFolders()
                                        }
                                    } else {
                                        selectedFolder = folder.name.wrappedValue
                                    }
                                }, background: .cowGray.opacity(0), clickOpacity: 0)
                            } else {
                                // MARK: File Icon
                                NiceButton(text: AnyView(
                                    VStack {
                                        Image(systemName: "doc.fill")
                                            .font(.system(size: 55))
                                            .padding(2)
                                    }
                                        .frame(width: 70, height: 70)
                                ), action: {
                                    if selectedFolder == folder.name.wrappedValue {
                                        if enteringName {
                                            enteringName = false
                                        } else {
                                            // open up the file
                                            // deselect for now
                                            selectedFolder = ""
                                        }
                                    } else {
                                        selectedFolder = folder.name.wrappedValue
                                    }
                                }, background: .cowGray.opacity(0), clickOpacity: 0)
                            }
                            // MARK: Folder Title
                            if !enteringName || selectedFolder != folder.name.wrappedValue {
                                NiceButton(text: AnyView(
                                    Text(folder.name.wrappedValue)
                                ), action: {
                                    if selectedFolder == folder.name.wrappedValue {
                                        newName = folder.name.wrappedValue
                                        enteringName = true
                                        nameFieldIsFocused = true
                                    } else {
                                        selectedFolder = folder.name.wrappedValue
                                    }
                                }, background: .cowGray.opacity(0), clickOpacity: 0)
                            } else {
                                if #available(macOS 13, *) {
                                    TextField("Folder", text: $newName, axis: .vertical).onSubmit {
                                        submitNewName()
                                    }
                                    .lineLimit(6)
                                    .focused($nameFieldIsFocused)
                                } else if #available(macOS 12, *) {
                                    TextField("Folder", text: $newName).onSubmit {
                                        submitNewName()
                                    }
                                    .focused($nameFieldIsFocused)
                                } else {
                                    TextField("Folder", text: $newName, onCommit: {
                                        submitNewName()
                                    })
                                    .focused($nameFieldIsFocused)
                                }
                            }
                        }
                        .background(Color.cowGray.opacity(0))
                        .overlay(RoundedRectangle(cornerRadius: 0)
                            .stroke(Color.blue, lineWidth: selectedFolder == folder.name.wrappedValue ? 4 : 0))
                    }
                }
            }
            .padding(.horizontal, 10)
            .background(Color.cowGray)
            .cornerRadius(8)
            .onTapGesture {
                if enteringName {
                    submitNewName()
                } else if selectedFolder != "" {
                    selectedFolder = ""
                }
            }
        }
        .padding(.bottom, 10)
        .padding(.horizontal, 10)
        .onAppear {
            updateFolders()
        }
        .fileImporter(
            isPresented: $showPicker,
            allowedContentTypes: [
                .item
            ],
            allowsMultipleSelection: true,
            onCompletion: { result in
                guard let urls = try? result.get() else { return }
                let foldersDir = CustomOperationsManager.shared.getOperationsFolder().appendingPathComponent(operation.name).appendingPathComponent(currentPath)
                for url in urls {
                    do {
                        try FileManager.default.copyItem(at: url, to: foldersDir.appendingPathComponent(url.lastPathComponent))
                    } catch {
                        Logger.shared.logMe("Error importing item \(url.path): \(error.localizedDescription)")
                    }
                }
                // update folders
                updateFolders()
            }
        )
        .sheet(isPresented: $showSelectionView) {
            NewSelectionView(newType: $selectionViewType, showingPopover: $showSelectionView, newTypeName: $newTypeName)
        }
        .onChange(of: newTypeName) { n in
            if n == "" { return; }
            if selectionViewType == .domain {
                createNewFolder(n, focusText: false)
            } else {
                createNewFile(n)
            }
        }
    }
    
    func createNewFile(_ ext: String) {
        if ext == "" { return; }
        if enteringName {
            enteringName = false
        }
        let folderDir = CustomOperationsManager.shared.getOperationsFolder().appendingPathComponent(operation.name).appendingPathComponent(currentPath)
        // get the name of the new file
        var newFileName = "File"
        if FileManager.default.fileExists(atPath: folderDir.appendingPathComponent("\(newFileName).\(ext)").path) {
            newFileName = CustomOperationsManager.shared.getNewName(newFileName, ext, url: folderDir, i: 2)
        }
        do {
            // create the data first
            var newData: Data? = nil
            switch ext {
            case "plist":
                let plist: [String: Any] = [:] // just to stop the annoying warning
                newData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
            case "txt":
                newData = "".data(using: .ascii)
            default:
                newData = "".data(using: .utf8)
            }
            
            // create a new file
            let newFile = "\(newFileName).\(ext)"
            if !FileManager.default.createFile(atPath: folderDir.appendingPathComponent(newFile).path, contents: newData) {
                throw "File manager to create new file."
            }
            
            // now, add the file to the folders array
            folders.insert(.init(name: newFile, directory: false), at: 0)
            
            // make it so the user decides the name
            newName = newFile
            selectedFolder = newFile
            enteringName = true
            nameFieldIsFocused = true
        } catch {
            Logger.shared.logMe("Error creating a new file: \(error.localizedDescription)")
        }
    }
    
    func createNewFolder(_ name: String = "", focusText: Bool = true) {
        if enteringName {
            enteringName = false
        }
        let folderDir = CustomOperationsManager.shared.getOperationsFolder().appendingPathComponent(operation.name).appendingPathComponent(currentPath)
        // get the name of the new folder
        var newFolderName = name == "" ? "New Folder" : name
        if FileManager.default.fileExists(atPath: folderDir.appendingPathComponent(newFolderName).path) {
            newFolderName = CustomOperationsManager.shared.getNewName(newFolderName, url: folderDir, i: 2)
        }
        do {
            try FileManager.default.createDirectory(at: folderDir.appendingPathComponent(newFolderName), withIntermediateDirectories: false)
            
            // now, add the folder to the folders array
            folders.insert(.init(name: newFolderName, directory: true), at: 0)
            
            // make it so the user decides the name
            if focusText {
                newName = ""
                selectedFolder = newFolderName
                enteringName = true
                nameFieldIsFocused = true
            }
        } catch {
            Logger.shared.logMe("Error creating a new folder: \(error.localizedDescription)")
        }
    }
    
    func submitNewName() {
        // rename the folder
        // check if the name actually changed
        if newName == selectedFolder || newName == "" { enteringName = false; return; }
        // first, change it in the file explorer
        let fm = FileManager.default
        let foldersDir = CustomOperationsManager.shared.getOperationsFolder().appendingPathComponent(operation.name).appendingPathComponent(currentPath)
        do {
            // make sure old folder exists and the new name does not already exist
            if fm.fileExists(atPath: foldersDir.appendingPathComponent(selectedFolder).path) && !fm.fileExists(atPath: foldersDir.appendingPathComponent(newName).path) {
                try fm.moveItem(at: foldersDir.appendingPathComponent(selectedFolder), to: foldersDir.appendingPathComponent(newName))
                
                // now, rename the folder in the folders array
                if let folderOffset = folders.firstIndex(where: {$0.name == selectedFolder}) {
                    folders[folderOffset].name = newName
                    selectedFolder = newName
                }
            } else {
                throw "File doesn't exist at \(foldersDir.appendingPathComponent(selectedFolder).path)!"
            }
        } catch {
            Logger.shared.logMe("Error renaming folder \"\(selectedFolder)\" to \"\(newName)\": \(error.localizedDescription)")
        }
        enteringName = false
    }
    
    func updateFolders() {
        folders.removeAll()
        folders = operation.getSubFolders(folderPath: currentPath)
        selectedFolder = ""
    }
}
