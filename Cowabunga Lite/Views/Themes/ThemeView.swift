//
//  ThemeView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/26/23.
//

import SwiftUI

struct ThemeView: View {
    @StateObject var themeManager = ThemingManager.shared
    @State var theme: ThemingManager.Theme
    var defaultWallpaper: Bool = false
    @State var icons: [NSImage?] = []
    
    var body: some View {
        VStack {
            ZStack {
                Image("wallpaper")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 90)
                    .scaleEffect(defaultWallpaper ? 2 : 1)
                    .clipped()
                    .cornerRadius(8)
                    .allowsHitTesting(false)
                if icons.count >= 8 {
                    VStack {
                        HStack {
                            ForEach(icons[0...3], id: \.self) {
                                if $0 != nil {
                                    Image(nsImage: $0!)
                                        .resizable()
                                        .frame(width: 28, height: 28)
                                        .cornerRadius(5)
                                        .padding(2)
                                }
                            }
                        }
                        HStack {
                            ForEach(icons[4...7], id: \.self) {
                                if $0 != nil {
                                    Image(nsImage: $0!)
                                        .resizable()
                                        .frame(width: 28, height: 28)
                                        .cornerRadius(5)
                                        .padding(2)
                                }
                            }
                        }
                    }
                    if icons.compactMap({ $0 }).isEmpty {
                        noIconsFoundPreview
                    }
                }
            }
            HStack {
                Text(theme.name)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Text("· \(theme.iconCount)")
                    .font(.headline)
                    .foregroundColor(Color.secondary)
                Spacer()
            }
            HStack {
                NiceButton(text: AnyView(
                    Text(themeManager.isCurrentTheme(theme.name) ? "Selected" : "Select")
                        .frame(maxWidth: .infinity)
                ), action: {
                    if !themeManager.processing {
                        if themeManager.currentTheme == theme.name {
                            try? themeManager.setThemeSettings(deletingTheme: true)
                        } else {
                            do {
                                try themeManager.setThemeSettings(themeName: theme.name)
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }, background: themeManager.isCurrentTheme(theme.name) ? .blue : Color.cowGray)
                
                NiceButton(text: AnyView(
                    Image(systemName: "trash.fill")
                        .frame(maxWidth: 20)
                        .foregroundColor(.red)
                ), action: {
                    themeManager.deleteTheme(themeName: theme.name)
                })
            }
        }
        .padding(10)
        .background(Color.cowGray)
        .cornerRadius(16)
        .onAppear {
            icons = (try? themeManager.icons(forAppIDs: ["com.apple.mobilephone", "com.apple.mobilesafari", "com.apple.mobileslideshow", "com.apple.camera", "com.apple.AppStore", "com.apple.Preferences", "com.apple.Music", "com.apple.calculator"], from: theme)) ?? []
        }
    }
    
    @ViewBuilder
    var noIconsFoundPreview: some View {
        Text("Not enough icons to show a preview. \nInvalid theme?")
            .multilineTextAlignment(.center)
            .padding(6)
            .foregroundColor(.white)
            .font(.footnote)
            .cornerRadius(4)
            .padding(6)
        
    }
}

//struct ThemeView_Previews: PreviewProvider {
//    static var previews: some View {
//        ThemeView(theme: ThemingManager.Theme(name: "Theme", iconCount: 23))
//            .frame(width: 190)
//    }
//}
