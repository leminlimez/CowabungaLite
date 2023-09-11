//
//  FileExplorerView.swift
//  Cowabunga Lite
//
//  Created by lemin on 7/21/23.
//

import SwiftUI

struct FileExplorerView: View {
    @StateObject var operationsManager = CustomOperationsManager.shared
    @Binding var viewType: Int
    @Binding var operation: AdvancedObject
    @Binding var currentPath: String
    
    var gridItemLayout = [GridItem(.adaptive(minimum: 80))]
    
    @State var folders: [AdvancedOperationFolder] = []
    @State var selectedFolder: String = ""
    
    @State var enteringName: Bool = false
    @State var newName: String = ""
    
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
                                        //                                        .foregroundColor(selectedFolder == folder.name.wrappedValue ? .blue : .white)
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
                                        //                                        .foregroundColor(selectedFolder == folder.name.wrappedValue ? .blue : .white)
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
                                } else {
                                    TextField("Folder", text: $newName).onSubmit {
                                        submitNewName()
                                    }
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
    }
    
    func submitNewName() {
        // rename the folder
        // check if the name actually changed
        if newName == selectedFolder { enteringName = false; return; }
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
