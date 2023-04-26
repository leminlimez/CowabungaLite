//
//  AltIconView.swift
//  CowabungaJailed
//
//  Created by lemin on 4/20/23.
//

import SwiftUI

struct AltIconView: View {
    @StateObject var themeManager = ThemingManager.shared
    @Binding var app: AppOption
    @State var newIcon: String? = nil
    @State var replaceName: Bool = false
    @State var newDisplayName: String = ""
    
    var gridItemLayout = [GridItem(.adaptive(minimum: 45))]
    
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
            HStack {
                // MARK: Cancel Button
                Button(action: {
                    
                }) {
                    Text("Cancel")
                }
                
                Spacer()
                
                // MARK: Save Button
                Button(action: {
                    // save
                    do {
                        try themeManager.setAltIcon(bundleId: app.bundle, displayName: replaceName ? (newDisplayName != "" ? newDisplayName : app.name) : nil, imagePath: newIcon)
                    } catch {
                        print(error.localizedDescription)
                    }
                    // TODO: return to the list of apps
                }) {
                    Text("Save")
                }
            }
            .padding(.bottom, 10)
            
            // MARK: Icon Choice
            Group {
                Text("Icon")
                    .bold()
                LazyVGrid(columns: gridItemLayout, spacing: 10) {
                    ForEach(icons) { icon in
                        Button(action: {
                            if newIcon == icon.imgPath {
                                newIcon = nil
                            } else {
                                newIcon = icon.imgPath
                            }
                        }) {
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
                                    .cornerRadius(8)
                                    .padding(2)
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue, lineWidth: newIcon == icon.imgPath ? 4 : 0))
                            }
                        }
                    }
                }
                // Do Not Theme Button
                // Default Icon Button
                // Other Icons From Themes
                // + Icon (Import from png)
            }
            
            // MARK: Display Name
            Group {
                Text("App Display Name")
                    .bold()
                // Use Default Toggle (Grays out textbox)
                Toggle(isOn: $replaceName) {
                    Text("Replace Display Name")
                }
                // Text box for display name
                TextField(text: $newDisplayName) {
                    Text(app.name)
                }.disabled(!replaceName)
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
