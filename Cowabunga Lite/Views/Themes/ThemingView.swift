//
//  ThemingView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/24/23.
//

import SwiftUI

struct ThemingView: View {
    @State var enableTweak = false
    @StateObject var dataSingleton = DataSingleton.shared
    @StateObject var themeManager = ThemingManager.shared
    @State var easterEgg = false
    var gridItemLayout = [GridItem(.adaptive(minimum: 160))]
    var overlayGridItemLayout = [GridItem(.adaptive(minimum: 75))]
    
    @State var isAppClips: Bool = false
    @State var hideAppLabels: Bool = false
    @State var themeAllApps: Bool = false
    
    @State var showPicker: Bool = false
    @State var showPickerForOverlays: Bool = false
    
    @Binding var viewType: Int
    
    struct OverlayObj: Identifiable {
        var id = UUID()
        var title: String
        var image: NSImage?
    }
    @State var overlays: [OverlayObj] = []
        
    var body: some View {
        List {
            Group {
                HStack {
                    Image(systemName: easterEgg ? "doc.badge.gearshape.fill" : "paintbrush")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35).onTapGesture(perform: { easterEgg = !easterEgg })
                    VStack {
                        HStack {
                            Text(easterEgg ? "TrollTools" : "Icon Theming")
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Toggle("Enable", isOn: $enableTweak).onChange(of: enableTweak, perform: {nv in
                                DataSingleton.shared.setTweakEnabled(.themes, isEnabled: nv)
                            }).onAppear(perform: {
                                enableTweak = DataSingleton.shared.isTweakEnabled(.themes)
                            })
                            Spacer()
                        }
                    }
                    Spacer()
                    NiceButton(text: AnyView(
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Import .theme")
                        }
                    ), action: { showPicker.toggle() })
                    .padding(.horizontal, 15)
                }
                Divider()
            }
            if dataSingleton.deviceAvailable {
                Group {
                    if (themeManager.themes.count == 0) {
                        Text("No themes found.\nDownload themes in the Explore tab or import them using the Import button.\nThemes must contain icons of the form \"com.developer.app.png\".")
                            .padding()
                            .background(Color.cowGray)
                            .multilineTextAlignment(.center)
                            .cornerRadius(16)
                            .font(.footnote)
                            .frame(maxWidth: .infinity)
                    } else {
                        Group {
                            Text("Preferences")
                                .bold()
                            Toggle(isOn: $hideAppLabels) {
                                Text("Hide App Labels")
                            }.onChange(of: hideAppLabels, perform: { nv in
                                try? themeManager.setThemeSettings(hideDisplayNames: nv)
                            })
                            if easterEgg {
                                Toggle(isOn: $isAppClips) {
                                    Text("As App Clips")
                                }.onChange(of: isAppClips, perform: { nv in
                                    try? themeManager.setThemeSettings(appClips: nv)
                                })
                            }
                            Toggle(isOn: $themeAllApps) {
                                Text("Theme All Apps (Includes apps not included in the selected theme)")
                            }.onChange(of: themeAllApps, perform: { nv in
                                try? themeManager.setThemeSettings(themeAllApps: nv)
                            })
                            HStack {
                                Spacer()
                                NiceButton(text: AnyView(
                                    Text("App Settings")
                                ), action: { viewType = 1 })
                                Spacer()
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 5)
                        
                        Group {
                            HStack {
                                Text("Overlays")
                                    .bold()
                                ZStack {
                                    Rectangle()
                                        .cornerRadius(50)
                                        .foregroundColor(.blue)
                                        .frame(maxWidth: 50)
                                    Text("Beta")
                                        .foregroundColor(.white)
                                }
                            }
                            LazyVGrid(columns: overlayGridItemLayout, spacing: 20) {
                                ForEach(overlays) { ov in
                                    NiceButton(text: AnyView(
                                        VStack {
                                            if ov.image != nil {
                                                Image(nsImage: ov.image!)
                                                    .resizable()
                                                    .frame(width: 55, height: 55)
                                                    .cornerRadius(12)
                                                    .padding(2)
                                            } else {
                                                Image(systemName: "questionmark.app")
                                                    .font(.system(size: 55))
                                                    .padding(2)
                                            }
                                            Text(ov.title)
                                        }
                                            .frame(width: 70, height: 80)
                                    ), action: {
                                        if themeManager.currentOverlay == ov.title {
                                            try? themeManager.setThemeSettings(deletingOverlay: true)
                                        } else {
                                            try? themeManager.setThemeSettings(overlayName: ov.title)
                                        }
                                    })
                                    .overlay(RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: themeManager.isCurrentOverlay(ov.title) ? 4 : 0))
                                }
                                
                                // MARK: Import Overlay Button
                                NiceButton(text: AnyView(
                                    VStack {
                                        Image(systemName: "plus.app")
                                            .font(.system(size: 55))
                                            .padding(2)
                                    }
                                        .frame(width: 70, height: 80)
                                ), action: {
                                    showPickerForOverlays.toggle()
                                })
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 5)
                        
                        Group {
                            Text("Themes")
                                .bold()
                            LazyVGrid(columns: gridItemLayout, spacing: 10) {
                                ForEach(themeManager.themes, id: \.name) { theme in
                                    ThemeView(theme: theme)
                                }
                            }
                        }
                    }
//                    Divider()
//                    HStack {
//                        Text("Current Icons").bold()
//                        Spacer()
//                        Text("To remove a themed app, delete its icon on your device.")
//                    }
//                    VStack {
//                        HStack(spacing: 20) {
//                            Image(systemName: "app").resizable().frame(width: 50, height: 50)
//                            Text("App Store")
//                            Spacer()
//                            NiceButton(text: AnyView(Text("Select Icon")), action: {})
//                            Toggle("Hide Label", isOn: .constant(true))
//                            Toggle("App Clip", isOn: .constant(true))
//                        }.padding(20).background(RoundedRectangle(cornerRadius: 20).fill(Color.cowGray))
//                        HStack(spacing: 20) {
//                            Image(systemName: "app").resizable().frame(width: 50, height: 50)
//                            Text("Phone")
//                            Spacer()
//                            NiceButton(text: AnyView(Text("Remove Icon")), action: {})
//                            Toggle("Hide Label", isOn: .constant(true))
//                            Toggle("App Clip", isOn: .constant(true))
//                        }.padding(20).background(RoundedRectangle(cornerRadius: 20).fill(Color.cowGray))
//                        NiceButton(text: AnyView(
//                            HStack {
//                                Image(systemName: "square.and.arrow.up")
//                                Text("Export .theme")
//                            }
//                        ), action: {})
//                    }
                }.disabled(!enableTweak)
            }
        }
        .disabled(!dataSingleton.deviceAvailable)
        .onAppear {
            themeManager.getThemes()
            themeManager.currentTheme = themeManager.getCurrentAppliedTheme()
            themeManager.getOverlays()
            themeManager.currentOverlay = themeManager.getCurrentAppliedOverlay()
            hideAppLabels = themeManager.getThemeToggleSetting("HideDisplayNames")
            isAppClips = themeManager.getThemeToggleSetting("AsAppClips")
            themeAllApps = themeManager.getThemeToggleSetting("ThemeAllApps")
            
            overlays.removeAll(keepingCapacity: true)
            for ov in themeManager.overlays {
                overlays.append(.init(title: ov.name, image: themeManager.getOverlayImage(name: ov.name)))
            }
        }
        .fileImporter(isPresented: $showPicker, allowedContentTypes: [.folder], allowsMultipleSelection: false, onCompletion: { result in
            guard let url = try? result.get().first else { return }
            try? ThemingManager.shared.importTheme(from: url)
        })
        .fileImporter(isPresented: $showPickerForOverlays, allowedContentTypes: [.png], allowsMultipleSelection: true, onCompletion: { result in
            guard let urls = try? result.get() else { return }
            for url in urls {
                do {
                    let newName = try themeManager.importOverlay(from: url)
                    overlays.append(.init(title: newName, image: themeManager.getOverlayImage(name: newName)))
                } catch {
                    print(error.localizedDescription)
                }
            }
        })
    }
}
