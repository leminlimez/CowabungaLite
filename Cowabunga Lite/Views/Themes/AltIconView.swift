//
//  AltIconView.swift
//  CowabungaJailed
//
//  Created by lemin on 4/20/23.
//

import SwiftUI

struct AltIconView: View {
    @StateObject var themeManager = ThemingManager.shared
    @Binding var viewType: Int
    @Binding var app: AppOption
    
    @State var newIcon: String? = nil
    @State var replaceName: Bool = false
    @State var newDisplayName: String = ""
    
    @State var showPicker: Bool = false
    
    var gridItemLayout = [GridItem(.adaptive(minimum: 80))]
    
    struct IconData: Identifiable {
        var id = UUID()
        var title: String
        var imgPath: String
        var icon: NSImage? = nil
        var systemImage: String? = nil
    }
    
    @State var icons: [IconData] = [
        .init(title: "No Theme", imgPath: "Hidden", systemImage: "xmark.app")
    ]
    
    @State var customIcons: [IconData] = []
    
    var body: some View {
        VStack {
            HStack {
                // MARK: Cancel Button
                Button(action: {
                    viewType = 1
                }) {
                    Text("Cancel")
                }
                .padding(10)
                
                Spacer()
                
                // MARK: Save Button
                Button(action: {
                    // save
                    do {
                        try themeManager.setAltIcon(bundleId: app.bundle, displayName: replaceName ? (newDisplayName != "" ? newDisplayName : app.name) : nil, imagePath: newIcon)
                    } catch {
                        print(error.localizedDescription)
                    }
                    viewType = 1
                }) {
                    Text("Save")
                }
                .padding(.horizontal, 10)
                .padding(.top, 10)
                .padding(.bottom, 5)
            }
            
            ScrollView {
                // MARK: Original Icon and Name
                Group {
                    HStack {
                        if app.icon != nil, let img = NSImage(data: app.icon!) {
                            Image(nsImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 35, height: 35)
                        } else {
                            Rectangle()
                                .frame(width: 35, height: 35)
                                .cornerRadius(10)
                        }
                        VStack {
                            HStack {
                                Text(app.name)
                                    .bold()
                                Spacer()
                            }
                            HStack {
                                Text(app.changed ? "Custom" : "Default")
                                    .foregroundColor(app.changed ? .green : .blue)
                                Spacer()
                            }
                        }
                    }
                    .padding(.bottom, 5)
                    Divider()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                
                // MARK: Display Name
                Group {
                    HStack {
                        Text("App Display Name")
                            .bold()
                            .padding(.horizontal, 10)
                        Spacer()
                    }
                    .padding(.top, 10)
                    
                    HStack {
                        // Use Default Toggle (Grays out textbox)
                        Toggle(isOn: $replaceName) {
                            Text("Replace Display Name")
                        }
                        // Text box for display name
                        TextField(app.name, text: $newDisplayName)
                            .disabled(!replaceName)
                    }
                    .padding(.horizontal, 10)
                }
                
                Divider()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                
                // MARK: Icon Choice
                Group {
                    HStack {
                        Text("Icon")
                            .bold()
                            .padding(.horizontal, 10)
                        Spacer()
                    }
                    LazyVGrid(columns: gridItemLayout, spacing: 10) {
                        ForEach(icons) { icon in
                            NiceButton(text: AnyView(
                                VStack {
                                    if icon.systemImage != nil {
                                        Image(systemName: icon.systemImage!)
                                            .font(.system(size: 55))
                                            .padding(2)
                                    } else if icon.icon != nil {
                                        Image(nsImage: icon.icon!)
                                            .resizable()
                                            .frame(width: 55, height: 55)
                                            .cornerRadius(12)
                                            .padding(2)
                                    } else {
                                        Image(systemName: "questionmark.app")
                                            .font(.system(size: 55))
                                            .padding(2)
                                    }
                                    Text(icon.title)
                                }
                                    .frame(width: 70, height: 80)
                            ), action: {
                                if icon.icon != nil || icon.systemImage != nil {
                                    if newIcon == icon.imgPath {
                                        newIcon = nil
                                    } else {
                                        newIcon = icon.imgPath
                                    }
                                }
                            })
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: newIcon == icon.imgPath ? 4 : 0))
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 5)
                    
                    LazyVGrid(columns: gridItemLayout, spacing: 10) {
                        // MARK: Import Icon Button
                        NiceButton(text: AnyView(
                            VStack {
                                Image(systemName: "plus.app")
                                    .font(.system(size: 55))
                                    .padding(2)
                            }
                                .frame(width: 70, height: 70)
                        ), action: {
                            showPicker.toggle()
                        })
                        
                        ForEach(customIcons) { icon in
                            NiceButton(text: AnyView(
                                VStack {
                                    if icon.systemImage != nil {
                                        Image(systemName: icon.systemImage!)
                                            .font(.system(size: 55))
                                            .padding(2)
                                    } else if icon.icon != nil {
                                        Image(nsImage: icon.icon!)
                                            .resizable()
                                            .frame(width: 55, height: 55)
                                            .cornerRadius(12)
                                            .padding(2)
                                    } else {
                                        Image(systemName: "questionmark.app")
                                            .font(.system(size: 55))
                                            .padding(2)
                                    }
                                }
                                    .frame(width: 70, height: 70)
                            ), action: {
                                if icon.icon != nil || icon.systemImage != nil {
                                    if newIcon == icon.imgPath {
                                        newIcon = nil
                                    } else {
                                        newIcon = icon.imgPath
                                    }
                                }
                            })
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: newIcon == icon.imgPath ? 4 : 0))
                        }
                    }
                    .padding(.horizontal, 10)
                    // Do Not Theme Button
                    // Default Icon Button
                    // Other Icons From Themes
                    // + Icon (Import from png)
                }
                .padding(.bottom, 5)
            }
            .onAppear {
                // MARK: Generate the Icons
                // add default
                if app.icon != nil {
                    let img = NSImage(data: app.icon!)
                    icons.append(.init(title: "Default", imgPath: "Default", icon: img))
                } else {
                    icons.append(.init(title: "Default", imgPath: "Default", systemImage: "questionmark.app"))
                }
                
                // add the icons from the other theme
                do {
                    for p in try FileManager.default.contentsOfDirectory(at: themeManager.getThemesFolder(), includingPropertiesForKeys: nil) {
                        if p.lastPathComponent == "Custom" {
                            if FileManager.default.fileExists(atPath: p.appendingPathComponent(app.bundle).path) {
                                for i in try FileManager.default.contentsOfDirectory(at: p.appendingPathComponent(app.bundle), includingPropertiesForKeys: nil) {
                                    let imgData = try Data(contentsOf: i)
                                    let img = NSImage(data: imgData)
                                    customIcons.append(.init(title: "Custom", imgPath: "Custom/\(app.bundle)/\(i.lastPathComponent)", icon: img))
                                }
                            }
                        } else {
                            let imgPath = p.appendingPathComponent(app.bundle + ".png")
                            if FileManager.default.fileExists(atPath: imgPath.path) {
                                let imgData = try Data(contentsOf: imgPath)
                                let img = NSImage(data: imgData)
                                icons.append(.init(title: p.lastPathComponent, imgPath: p.lastPathComponent + "/\(app.bundle).png", icon: img))
                            }
                        }
                    }
                } catch {
                    print("Failed to load icons! \(error.localizedDescription)")
                }
                
                // get the data
                let appData = themeManager.getAltIconData(bundleId: app.bundle)
                newIcon = appData["ImagePath"]
                replaceName = appData["Name"] != nil
                newDisplayName = appData["Name"] ?? ""
            }
            .fileImporter(isPresented: $showPicker, allowedContentTypes: [.png], allowsMultipleSelection: false, onCompletion: { result in
                guard let url = try? result.get().first else { return }
                guard let (imgData, p) = try? ThemingManager.shared.importAltIcon(from: url, bundleId: app.bundle) else { return }
                let img = NSImage(data: imgData)
                customIcons.append(.init(title: "Custom", imgPath: p, icon: img))
            })
        }
    }
}
