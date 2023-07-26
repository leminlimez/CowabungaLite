//
//  EditingOperationView.swift
//  Cowabunga Lite
//
//  Created by lemin on 7/21/23.
//

import SwiftUI

struct EditingOperationView: View {
    @StateObject var operationsManager = CustomOperationsManager.shared
    @Binding var viewType: Int
    @Binding var operation: AdvancedObject
    @Binding var currentPath: String
    
    @State var newName: String = ""
    @State var newAuthor: String = ""
    @State var newVersion: String = ""
    @State var enabledOperation: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                // MARK: Back Button
                Button(action: {
                    // TODO: warn about saving
                    viewType = 0
                }) {
                    Text("Back")
                }
                .padding(10)
                
                Spacer()
                
                // MARK: Save Button
                if newName != operation.name || newAuthor != operation.author || newVersion != operation.version {
                    Button(action: {
                        // save
                        do {
                            if newName != "" && newVersion != "" {
                                try operationsManager.updateOperation(oldName: operation.name, newName: newName, newAuthor: newAuthor, newVersion: newVersion)
                                operation = try operationsManager.getOperation(name: newName)
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }) {
                        Text("Save")
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                    .padding(.bottom, 5)
                }
            }
            
            ScrollView {
                // MARK: Operation Name
                Group {
                    VStack {
                        HStack {
                            Text("Name \(newName != operation.name ? "*" : "")")
                                .bold()
                                .padding(.horizontal, 10)
                            Spacer()
                        }
                        .padding(.top, 10)
                        HStack {
                            Toggle("Enable", isOn: $enabledOperation).onChange(of: enabledOperation, perform: { nv in
                                operationsManager.toggleOperation(name: operation.name, enabled: nv)
                            })
                            Spacer()
                        }
                    }
                    
                    HStack {
                        // Text box for name
                        TextField(operation.name, text: $newName)
                    }
                    .padding(.horizontal, 10)
                }
                
                if !operation.locked {
                    // MARK: Operation Author
                    Group {
                        HStack {
                            Text("Author \(newAuthor != operation.author ? "*" : "")")
                                .bold()
                                .padding(.horizontal, 10)
                            Spacer()
                        }
                        .padding(.top, 10)
                        
                        HStack {
                            // Text box for author
                            TextField(operation.author == "" ? "No Author" : operation.author, text: $newAuthor)
                        }
                        .padding(.horizontal, 10)
                    }
                    // MARK: Operation Version
                    Group {
                        HStack {
                            Text("Version \(newVersion != operation.version ? "*" : "")")
                                .bold()
                                .padding(.horizontal, 10)
                            Spacer()
                        }
                        .padding(.top, 10)
                        
                        HStack {
                            // Text box for version
                            TextField(operation.version, text: $newVersion)
                        }
                        .padding(.horizontal, 10)
                    }
                }
                
                // MARK: Editing Domains
                Group {
                    HStack {
                        NiceButton(text: AnyView(
                            Text("Open Domains and Files (TEMPORARY)")
                                .bold()
                                .padding(.horizontal, 10)
                        ), action: {
                            currentPath = "Domains"
                            let _ = operation.getSubFolders(folderPath: "Domains")
                            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: operationsManager.getOperationsFolder().appendingPathComponent(operation.name).appendingPathComponent("Domains").path)
//                            viewType = 2
                        })
                        Spacer()
                    }
                }
            }
        }.onAppear {
            newName = operation.name
            newAuthor = operation.author
            newVersion = operation.version
            enabledOperation = operation.enabled
        }
    }
}
