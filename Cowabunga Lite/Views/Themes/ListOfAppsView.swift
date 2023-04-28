//
//  ListOfAppsView.swift
//  CowabungaJailed
//
//  Created by lemin on 4/20/23.
//

import SwiftUI

struct AppOption: Identifiable {
    var id = UUID()
    var name: String
    var bundle: String
    var icon: Data?
    var themedIcon: Data?
    var changed: Bool = false
}

struct ListOfAppsView: View {
    var gridItemLayout = [GridItem(.adaptive(minimum: 80))]
    @StateObject var themeManager = ThemingManager.shared
    
    @State var apps: [AppOption] = []
    
    @Binding var viewType: Int
    @Binding var currentApp: AppOption
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Button(action: {
                        viewType = 0
                    }) {
                        Text("Back")
                    }
                    .padding(10)
                    Spacer()
                }
                HStack {
                    Spacer()
                    Text("App Settings")
                        .font(.title)
                        .padding(10)
                    Spacer()
                }
            }
            
            if apps.count == 0 {
                VStack {
                    Spacer()
                    Text("Error loading apps.\nPlease try again.")
                        .padding(10)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: gridItemLayout, spacing: 7) {
                        ForEach($apps) { app in
                            NiceButton(text: AnyView(
                                ZStack {
                                    VStack {
                                        if app.icon.wrappedValue != nil, let img = NSImage(data: app.icon.wrappedValue!) {
                                            Image(nsImage: img)
                                                .resizable()
                                                .frame(width: 65, height: 65)
                                                .cornerRadius(10)
                                        } else {
                                            Rectangle()
                                                .frame(width: 65, height: 65)
                                                .cornerRadius(25)
                                        }
                                        Text(app.name.wrappedValue)
                                    }
                                    
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            if app.changed.wrappedValue {
                                                Image(systemName: "lock.fill")
                                                    .foregroundColor(.blue)
                                                    .font(.system(size: 25))
                                                    .padding(.bottom, 14)
                                            }
                                        }
                                    }
                                }
                                    .frame(height: 90)
                            ), action: {
                                currentApp = app.wrappedValue
                                viewType = 2
                            })
                            .padding(5)
                        }
                    }
                    .padding(.horizontal, 10)
                }
            }
        }
        .onAppear {
            // pause before using
            grabApps()
        }
    }
    
    func grabApps() {
        let newApps = getHomeScreenAppsNew()
        let changes = themeManager.getAltIcons()
        for app in newApps {
            var checked = false
            var icon = app.icon
            if let altData = changes[app.bundleId] as? [String: String] {
                checked = true
                if let imgPath = altData["ImagePath"], imgPath != "Hidden", imgPath != "Default" {
                    let fullPath = themeManager.getThemesFolder().appendingPathComponent(imgPath)
                    if FileManager.default.fileExists(atPath: fullPath.path) {
                        icon = try? Data(contentsOf: fullPath)
                    }
                }
            }
            apps.append(.init(name: app.name, bundle: app.bundleId, icon: icon, themedIcon: app.themedIcon, changed: checked))
        }
    }
}
