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
    
    @State var loaded: Bool = false
    
    @State var searchTerm: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    viewType = 0
                }) {
                    Text("Back")
                }
                .padding(10)
                Spacer()
            }
            
            if loaded {
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
                                if searchTerm == "" || app.name.wrappedValue.lowercased().contains(searchTerm.lowercased()) {
                                    NiceButton(text: AnyView(
                                        ZStack {
                                            VStack {
                                                if app.themedIcon.wrappedValue != nil, let img = NSImage(data: app.themedIcon.wrappedValue!) {
                                                    Image(nsImage: img)
                                                        .resizable()
                                                        .frame(width: 65, height: 65)
                                                        .cornerRadius(15)
                                                } else {
                                                    Rectangle()
                                                        .frame(width: 65, height: 65)
                                                        .cornerRadius(15)
                                                }
                                                Text(app.name.wrappedValue)
                                            }
                                            
                                            HStack {
                                                Spacer()
                                                VStack {
                                                    if app.changed.wrappedValue {
                                                        ZStack {
                                                            Image(systemName: "gearshape.fill")
                                                                .foregroundColor(.white)
                                                                .font(.system(size: 25, weight: .bold))
                                                            Image(systemName: "gearshape")
                                                                .foregroundColor(.black)
                                                                .font(.system(size: 25, weight: .bold))
                                                        }
                                                        .offset(x: 8, y: -8)
                                                    }
                                                    Spacer()
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
                        }
                        .padding(.horizontal, 10)
                    }
                    .searchable(text: $searchTerm)
                }
            } else {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            // pause before using
            loaded = false
            Task {
                grabApps()
                loaded = true
            }
        }
    }
    
    func grabApps() {
        let newApps = getHomeScreenAppsNew()
        let changes = themeManager.getAltIcons()
        for app in newApps {
            var checked = false
            var themedIcon = app.icon
            if let altData = changes[app.bundleId] as? [String: String] {
                checked = true
                if let imgPath = altData["ImagePath"], imgPath != "Hidden", imgPath != "Default" {
                    let fullPath = themeManager.getThemesFolder().appendingPathComponent(imgPath)
                    if FileManager.default.fileExists(atPath: fullPath.path) {
                        themedIcon = try? Data(contentsOf: fullPath)
                    }
                }
            }
            apps.append(.init(name: app.name, bundle: app.bundleId, icon: app.icon, themedIcon: themedIcon, changed: checked))
        }
    }
}
