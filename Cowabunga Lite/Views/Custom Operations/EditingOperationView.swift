//
//  EditingOperationView.swift
//  Cowabunga Lite
//
//  Created by lemin on 7/21/23.
//

import SwiftUI

struct EditingOperationView: View {
    @StateObject private var dataSingleton = DataSingleton.shared
    @StateObject var operationsManager = CustomOperationsManager.shared
    @Binding var viewType: Int
    @Binding var operation: AdvancedObject
    @Binding var currentPath: String
    
    @State var showPicker: Bool = false
    
    @State var newName: String = ""
    @State var newAuthor: String = ""
    @State var newVersion: String = ""
    @State var newIcon: String? = nil
    @State var enabledOperation: Bool = false
    
    @State var iconImage: NSImage? = nil
    
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
                
                // MARK: Export Button
                // make sure the operation is saved
                if newName == operation.name && newAuthor == operation.author && newVersion == operation.version && newIcon == operation.icon && !operation.locked {
                    ImageButton(systemName: "square.and.arrow.up", text: "Export .cowperation", action: {
                        do {
                            let url = try operation.exportOperation()
                            // open in finder
                            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
                        } catch {
                            print(error.localizedDescription)
                        }
                    })
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                    .padding(.bottom, 5)
                }
                
                // MARK: Save Button
                if newName != operation.name || newAuthor != operation.author || newVersion != operation.version || newIcon != operation.icon {
                    Button(action: {
                        // save
                        do {
                            if newName != "" && newVersion != "" {
                                try operationsManager.updateOperation(oldName: operation.name, newName: newName, newAuthor: newAuthor, newVersion: newVersion, newIcon: newIcon)
                                operation = try operationsManager.getOperation(name: newName)
                                newIcon = operation.icon
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
                // MARK: Operation Details and Icon
                Group {
                    HStack {
                        // MARK: Icon Changer
                        if !operation.locked {
                            ZStack {
                                NiceButton(text: AnyView(
                                    Group {
                                        if let icn = iconImage {
                                            Image(nsImage: icn)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        } else {
                                            Image("MissingCow")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        }
                                    }
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(7)
                                        .padding(4)
                                ), action: {
                                    showPicker = true
                                }, padding: 0)
                                
                                if newIcon != operation.icon {
                                    Text("*")
                                        .bold()
                                        .font(.title)
                                        .offset(x: 28, y: -24)
                                }
                            }
                            .fileImporter(isPresented: $showPicker, allowedContentTypes: [.png], allowsMultipleSelection: false, onCompletion: { result in
                                guard let url = try? result.get().first else { return }
                                iconImage = NSImage(contentsOf: url)
                                newIcon = url.path
                            })
                        } else {
                            Group {
                                if let icn = iconImage {
                                    Image(nsImage: icn)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } else {
                                    Image("MissingCow")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                            }
                                .frame(width: 50, height: 50)
                                .cornerRadius(7)
                                .padding(4)
                        }
                        
                        VStack {
                            // MARK: Name & Version
                            HStack {
                                Text(operation.name)
                                    .bold()
                                    .padding(.trailing, 1)
                                Text("v\(operation.version)")
                                    .font(.footnote)
                                    .opacity(0.8)
                                Spacer()
                            }
                            .padding(.leading, 4)
                            .padding(.top, 4)
                            .padding(.bottom, 1)
                            
                            // MARK: Author
                            HStack {
                                if operation.author != "" {
                                    Text(operation.author)
                                        .font(.footnote)
                                        .padding(.leading, 4)
                                } else {
                                    Text("No Author")
                                        .font(.footnote)
                                        .padding(.leading, 4)
                                }
                                Spacer()
                            }
                            
                            Spacer()
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 5)
                .padding(.leading, 10)
                
                // MARK: Operation Name
                Group {
                    VStack {
                        if dataSingleton.deviceAvailable {
                            HStack {
                                Toggle("Enable", isOn: $enabledOperation).onChange(of: enabledOperation, perform: { nv in
                                    operationsManager.toggleOperation(name: operation.name, enabled: nv)
                                })
                                .padding(.horizontal, 10)
                                Spacer()
                            }
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                        }
                        
                        HStack {
                            Text("Name \(newName != operation.name ? "*" : "")")
                                .bold()
                                .padding(.horizontal, 10)
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
                if #available(macOS 12, *) {
                    Group {
                        HStack {
                            NiceButton(text: AnyView(
                                Text("Open Domains and Files")
                                    .bold()
                                    .padding(.horizontal, 10)
                            ), action: {
                                currentPath = "Domains"
                                viewType = 2
                            })
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 5)
                    }
                } else {
                    Group {
                        HStack {
                            NiceButton(text: AnyView(
                                Text("Open Domains and Files")
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
                        .padding(.horizontal, 10)
                        .padding(.top, 5)
                    }
                }
            }
        }.onAppear {
            newName = operation.name
            newAuthor = operation.author
            newVersion = operation.version
            newIcon = operation.icon
            iconImage = operation.getImage()
            enabledOperation = operation.enabled
        }
    }
}
