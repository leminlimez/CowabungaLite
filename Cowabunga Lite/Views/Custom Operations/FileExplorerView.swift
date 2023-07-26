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
                            Button(action: {
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
                            }) {
                                VStack {
                                    Image(systemName: "folder.fill")
                                        .font(.system(size: 55))
//                                        .foregroundColor(selectedFolder == folder.name.wrappedValue ? .blue : .white)
                                        .foregroundColor(.blue)
                                        .padding(2)
                                }
                                    .frame(width: 70, height: 70)
                            }
                            if !enteringName {
                                Button(action: {
                                    if selectedFolder == folder.name.wrappedValue {
                                        
                                    }
                                }) {
                                    
                                }
                            }
                            Text(folder.name.wrappedValue)
                        }
                        .background(Color.cowGray)
                        .overlay(RoundedRectangle(cornerRadius: 0)
                            .stroke(Color.blue, lineWidth: selectedFolder == folder.name.wrappedValue ? 4 : 0))
                    }
                }
            }
            .padding(.horizontal, 10)
            .background(Color.cowGray)
            .cornerRadius(8)
        }
        .padding(.horizontal, 10)
    }
    
    func updateFolders() {
        folders.removeAll()
        folders = operation.getSubFolders(folderPath: currentPath)
        selectedFolder = ""
    }
}
