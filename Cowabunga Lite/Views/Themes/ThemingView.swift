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
    
    @State var isAppClips: Bool = false
    @State var hideAppLabels: Bool = false
    @State var themeAllApps: Bool = false
    
    @State var showPicker: Bool = false
    
    @Binding var viewType: Int
        
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
//                            Toggle(isOn: $hideAppLabels) {
//                                Text("Hide App Labels")
//                            }.onChange(of: hideAppLabels, perform: { nv in
//                                try? themeManager.setThemeSettings(hideDisplayNames: nv)
//                            })
//                            Toggle(isOn: $isAppClips) {
//                                Text("As App Clips")
//                            }.onChange(of: isAppClips, perform: { nv in
//                                try? themeManager.setThemeSettings(appClips: nv)
//                            })
//                            Toggle(isOn: $themeAllApps) {
//                                Text("Theme All Apps (Includes apps not included in the selected theme)")
//                            }.onChange(of: themeAllApps, perform: { nv in
//                                try? themeManager.setThemeSettings(themeAllApps: nv)
//                            })
                        }
                        Group {
                            LazyVGrid(columns: gridItemLayout, spacing: 10) {
                                ForEach(themeManager.themes, id: \.name) { theme in
                                    ThemeView(theme: theme)
                                }
                            }
                        }
                    }
                    
                    Divider()
                    HStack {
                        Spacer()
                        NiceButton(text: AnyView(
                            Text("App Settings")
                        ), action: { viewType = 1 })
                        Spacer()
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
            hideAppLabels = themeManager.getThemeToggleSetting("HideDisplayNames")
            isAppClips = themeManager.getThemeToggleSetting("AsAppClips")
            themeAllApps = themeManager.getThemeToggleSetting("ThemeAllApps")
        }
        .fileImporter(isPresented: $showPicker, allowedContentTypes: [.folder], allowsMultipleSelection: false, onCompletion: { result in
            guard let url = try? result.get().first else { return }
            try? ThemingManager.shared.importTheme(from: url)
        })
    }
}
