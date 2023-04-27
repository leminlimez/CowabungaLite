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
    
    var gridItemLayout = [GridItem(.adaptive(minimum: 70))]
    
    struct IconData: Identifiable {
        var id = UUID()
        var imgPath: String
        var icon: NSImage? = nil
        var systemImage: String? = nil
    }
    
    @State var icons: [IconData] = [
        .init(imgPath: "Hidden", systemImage: "xmark.app")
    ]
    
    var body: some View {
        VStack {
            ZStack {
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
                    .padding(10)
                }
                HStack {
                    Spacer()
                    
                    Text(app.name)
                        .font(.title)
                        .padding(10)
                    
                    Spacer()
                }
            }
            .padding(.bottom, 10)
            
            ScrollView {
                // MARK: Icon Choice
                Group {
                    Text("Icon")
                        .font(.title2)
                    LazyVGrid(columns: gridItemLayout, spacing: 10) {
                        ForEach(icons) { icon in
                            NiceButton(text: AnyView(
                                VStack {
                                    if icon.systemImage != nil {
                                        Image(systemName: icon.systemImage!)
                                            .font(.system(size: 45))
                                            .padding(2)
                                            .overlay(RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.blue, lineWidth: newIcon == icon.imgPath ? 4 : 0))
                                    } else if icon.icon != nil {
                                        Image(nsImage: icon.icon!)
                                            .resizable()
                                            .frame(width: 45, height: 45)
                                            .cornerRadius(10)
                                            .padding(2)
                                            .overlay(RoundedRectangle(cornerRadius: 14)
                                                .stroke(Color.blue, lineWidth: newIcon == icon.imgPath ? 4 : 0))
                                    } else {
                                        Image(systemName: "questionmark.app")
                                            .font(.system(size: 45))
                                            .padding(2)
                                    }
                                }
                                    .frame(width: 50, height: 50)
                            ), action: {
                                if icon.icon != nil || icon.systemImage != nil {
                                    if newIcon == icon.imgPath {
                                        newIcon = nil
                                    } else {
                                        newIcon = icon.imgPath
                                    }
                                }
                            })
                        }
                    }
                    .padding(.horizontal, 25)
                    // Do Not Theme Button
                    // Default Icon Button
                    // Other Icons From Themes
                    // + Icon (Import from png)
                }
                .padding(.bottom, 15)
                
                // MARK: Display Name
                Group {
                    Text("App Display Name")
                        .font(.title2)
                    
                    HStack {
                        // Use Default Toggle (Grays out textbox)
                        Toggle(isOn: $replaceName) {
                            Text("Replace Display Name")
                        }
                        // Text box for display name
                        TextField(text: $newDisplayName) {
                            Text(app.name)
                        }.disabled(!replaceName)
                    }
                    .padding(10)
                }
            }
            .onAppear {
                // MARK: Generate the Icons
                // add default
                if app.icon != nil {
                    let img = NSImage(data: app.icon!)
                    icons.append(.init(imgPath: "Default", icon: img))
                } else {
                    icons.append(.init(imgPath: "Default", systemImage: "questionmark.app"))
                }
                
                // add the icons from the other theme
                do {
                    for p in try FileManager.default.contentsOfDirectory(at: themeManager.getThemesFolder(), includingPropertiesForKeys: nil) {
                        let imgPath = p.appendingPathComponent(app.bundle + ".png")
                        if FileManager.default.fileExists(atPath: imgPath.path) {
                            let imgData = try Data(contentsOf: imgPath)
                            let img = NSImage(data: imgData)
                            icons.append(.init(imgPath: p.lastPathComponent + "/\(app.bundle).png", icon: img))
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
        }
    }
}
