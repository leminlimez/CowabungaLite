//
//  ThemingManager.swift
//  CowabungaJailed
//
//  Created by lemin on 3/24/23.
//

import Foundation
import AppKit

class ThemingManager: ObservableObject {
    static let shared = ThemingManager()
    @Published var currentTheme: String? = nil
    @Published var processing: Bool = false
    @Published var themes: [ThemingManager.Theme] = []
    
    struct AppIconChange {
        var appID: String
        var themeIconURL: URL?
        var name: String
    }
    
    struct Theme: Codable, Identifiable, Equatable {
        var id = UUID()
        var name: String
        var iconCount: Int
    }
    
    public func makeInfoPlist(displayName: String = " ", bundleID: String, isAppClip: Bool = false) throws -> Data {
        let info: [String: Any] = [
            "ApplicationBundleIdentifier": bundleID,
            "ApplicationBundleVersion": 1,
            "ClassicMode": false,
            "ConfigurationIsManaged": false,
            "ContentMode": "UIWebClipContentModeRecommended",
            "FullScreen": true,
            "IconIsPrecomposed": false,
            "IconIsScreenShotBased": false,
            "IgnoreManifestScope": false,
            "IsAppClip": isAppClip,
            "Orientations": 0,
            "ScenelessBackgroundLaunch": false,
            "Title": displayName,
            "WebClipStatusBarStyle": "UIWebClipStatusBarStyleDefault",
            "RemovalDisallowed": false
        ]
        
        return try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0)
    }
    
    public func getAppliedThemeFolder() -> URL? {
        return DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent("AppliedTheme/HomeDomain/Library/WebClips")
    }
    
    public func getCurrentAppliedTheme() -> String? {
        guard let infoPlist = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent("IconThemingPreferences.plist") else { return nil }
        if !FileManager.default.fileExists(atPath: infoPlist.path) {
            return nil
        }
        guard let infoData = try? Data(contentsOf: infoPlist) else {
            return nil
        }
        guard let plist = try? PropertyListSerialization.propertyList(from: infoData, options: [], format: nil) as? [String: Any] else { return nil }
        guard let name = plist["CurrentlyAppliedTheme"] as? String else { return nil }
        return name
    }
    
    public func getThemeToggleSetting(_ settingName: String) -> Bool {
        guard let infoPlist = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent("IconThemingPreferences.plist") else { return false }
        if !FileManager.default.fileExists(atPath: infoPlist.path) {
            return false
        }
        guard let infoData = try? Data(contentsOf: infoPlist) else {
            return false
        }
        guard let plist = try? PropertyListSerialization.propertyList(from: infoData, options: [], format: nil) as? [String: Any] else { return false }
        guard let val = plist[settingName] as? Bool else { return false }
        return val
    }
    
    public func makeWebClip(displayName: String = " ", image: Data, bundleID: String, isAppClip: Bool = false, hideDisplayName: Bool = false) throws {
        let folderName: String = "Cowabunga_" + bundleID + "," + displayName + ".webclip"
        guard let folderURL = getAppliedThemeFolder()?.appendingPathComponent(folderName) else {
            throw "Error getting webclip folder"
        }
        do {
            if !FileManager.default.fileExists(atPath: folderURL.path) {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: false)
            }
            // create the info plist
            let infoPlist = try makeInfoPlist(displayName: hideDisplayName ? " " : displayName, bundleID: bundleID, isAppClip: isAppClip)
            try? FileManager.default.removeItem(at: folderURL.appendingPathComponent("Info.plist")) // delete if info plist already exists
            try infoPlist.write(to: folderURL.appendingPathComponent("Info.plist"))
            // write the icon file
            try? FileManager.default.removeItem(at: folderURL.appendingPathComponent("icon.png")) // delete if icon already exists
            try image.write(to: folderURL.appendingPathComponent("icon.png"))
        } catch {
            // remove from backup
            try? FileManager.default.removeItem(at: folderURL)
            throw "Error creating WebClip for icon bundle \(bundleID)"
        }
    }
    
    public func eraseAppliedTheme() {
        processing = true
        guard let appliedFolder = getAppliedThemeFolder() else {
            processing = false
            return
        }
        do {
            for folder in try FileManager.default.contentsOfDirectory(at: appliedFolder, includingPropertiesForKeys: nil) {
                try? FileManager.default.removeItem(at: folder)
            }
            processing = false
        } catch {
            processing = false
            print(error.localizedDescription)
        }
    }
    
    public func getThemesFolder() -> URL {
        let themesFolder = documentsDirectory.appendingPathComponent("Themes")
        if !FileManager.default.fileExists(atPath: themesFolder.path) {
            try? FileManager.default.createDirectory(at: themesFolder, withIntermediateDirectories: false)
        }
        return themesFolder
    }
    
    public func deleteTheme(themeName: String) {
        processing = true
        if currentTheme == themeName {
            eraseAppliedTheme()
            currentTheme = nil
        }
        let themePath = getThemesFolder().appendingPathComponent(themeName)
        if FileManager.default.fileExists(atPath: themePath.path) {
            try? FileManager.default.removeItem(at: themePath)
        }
        // update themes
        getThemes()
        processing = false
    }
    
    public func setThemeSettings(themeName: String? = nil, hideDisplayNames: Bool? = nil, appClips: Bool? = nil, themeAllApps: Bool? = nil, deletingTheme: Bool = false) throws {
        guard let infoPlistPath = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent("IconThemingPreferences.plist") else { return }
        var plist: [String: Any] = [:]
        if FileManager.default.fileExists(atPath: infoPlistPath.path) {
            do {
                plist = try PropertyListSerialization.propertyList(from: try Data(contentsOf: infoPlistPath), format: nil) as? [String: Any] ?? [:]
            }
            try? FileManager.default.removeItem(at: infoPlistPath)
        }
        if themeName != nil {
            plist["CurrentlyAppliedTheme"] = themeName!
            currentTheme = themeName
        } else if deletingTheme == true {
            plist["CurrentlyAppliedTheme"] = nil
            currentTheme = nil
        }
        if hideDisplayNames != nil {
            plist["HideDisplayNames"] = hideDisplayNames!
        }
        if appClips != nil {
            plist["AsAppClips"] = appClips!
        }
        if themeAllApps != nil {
            plist["ThemeAllApps"] = themeAllApps!
        }
        let newPlist = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try newPlist.write(to: infoPlistPath)
    }
    
    public func applyTheme() {
        let t = getCurrentAppliedTheme()
        if t == nil {
            Logger.shared.logMe("Applying icon themes...")
            eraseAppliedTheme()
            if getThemeToggleSetting("ThemeAllApps") == true {
                do {
                    try applyTheme(themeName: nil, hideDisplayNames: getThemeToggleSetting("HideDisplayNames"), appClips: getThemeToggleSetting("AsAppClips"), themeAllIcons: getThemeToggleSetting("ThemeAllApps"))
                    Logger.shared.logMe("Successfully applied icon themes!")
                } catch {
                    Logger.shared.logMe("An error occurred while applying icon themes: \(error.localizedDescription)")
                }
            }
            
        } else {
            Logger.shared.logMe("Applying icon themes...")
            eraseAppliedTheme()
            do {
                try applyTheme(themeName: t!, hideDisplayNames: getThemeToggleSetting("HideDisplayNames"), appClips: getThemeToggleSetting("AsAppClips"), themeAllIcons: getThemeToggleSetting("ThemeAllApps"))
                Logger.shared.logMe("Successfully applied icon themes!")
            } catch {
                Logger.shared.logMe("An error occurred while applying icon themes: \(error.localizedDescription)")
            }
        }
    }
    
    public func applyTheme(themeName: String?, hideDisplayNames: Bool = false, appClips: Bool = false, themeAllIcons: Bool = false) throws {
        let themeFolder = themeName != nil ? getThemesFolder().appendingPathComponent(themeName!) : nil
        if themeFolder != nil && !FileManager.default.fileExists(atPath: themeFolder!.path) {
            throw "No theme folder found for \(themeName!)!"
        }
        let apps = getHomeScreenAppsNew()
        
        for app in apps {
            // get the name to display
            let displayName = hideDisplayNames ? " " : app.name
            
            // STEP 1: Apply it if it is an alt icon
            // TODO: Alt Icon Applying
            
            // STEP 2: Apply it if it is in the main theme
            if themeFolder != nil && FileManager.default.fileExists(atPath: themeFolder!.appendingPathComponent(app.bundleId + ".png").path) {
                do {
                    let imgData = try Data(contentsOf: themeFolder!.appendingPathComponent(app.bundleId + ".png"))
                    try makeWebClip(displayName: displayName, image: imgData, bundleID: app.bundleId, isAppClip: appClips, hideDisplayName: hideDisplayNames)
                } catch {
                    Logger.shared.logMe(error.localizedDescription)
                }
            }
            
            // STEP 3: Apply it if applying all icons
            else if themeAllIcons {
                // get the image data
                if let imgData = app.icon {
                    do {
                        try makeWebClip(displayName: displayName, image: imgData, bundleID: app.bundleId, isAppClip: appClips, hideDisplayName: hideDisplayNames)
                    } catch {
                        Logger.shared.logMe(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    public func getThemes() {
        let themesFolder = getThemesFolder()
        themes.removeAll(keepingCapacity: true)
        do {
            for t in try FileManager.default.contentsOfDirectory(at: themesFolder, includingPropertiesForKeys: nil) {
                guard let c = try? FileManager.default.contentsOfDirectory(at: t, includingPropertiesForKeys: nil) else { continue }
                themes.append(.init(name: t.lastPathComponent, iconCount: (c).count))
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Getting icons
    func icons(forAppIDs appIDs: [String], from theme: Theme) throws -> [NSImage?] {
        appIDs.map { try? icon(forAppID: $0, from: theme) }
    }
    func icon(forAppID appID: String, from theme: Theme) throws -> NSImage {
        guard let image = NSImage(contentsOf: getThemesFolder().appendingPathComponent(theme.name).appendingPathComponent(appID + ".png")) else { throw "Couldn't open image" }
        return image
    }
    func icon(forAppID appID: String, fromThemeWithName name: String) throws -> NSImage {
        return try icon(forAppID: appID, from: Theme(name: name, iconCount: 1))
    }
    
    public func isCurrentTheme(_ name: String) -> Bool {
        return currentTheme == name
    }
    
    func importTheme(from importURL: URL) throws {
        var name = importURL.deletingPathExtension().lastPathComponent
        var finalURL = importURL
        try? fm.createDirectory(at: getThemesFolder(), withIntermediateDirectories: true)
        let themeURL = getThemesFolder().appendingPathComponent(name)
        
        if importURL.lastPathComponent.contains(".theme") {
            // unzip
            let unzipURL = fm.temporaryDirectory.appendingPathComponent("theme_unzip")
            try? fm.removeItem(at: unzipURL)
            try fm.unzipItem(at: importURL, to: unzipURL)
            
            for folder in (try? fm.contentsOfDirectory(at: unzipURL, includingPropertiesForKeys: nil)) ?? [] {
                if folder.deletingPathExtension().lastPathComponent == "IconBundles" {
                    name = importURL.deletingPathExtension().lastPathComponent
                    finalURL = folder
                    break
                }
            }
        }
        
        try? fm.removeItem(at: themeURL)
        try fm.createDirectory(at: themeURL, withIntermediateDirectories: true)
        
        for icon in (try? fm.contentsOfDirectory(at: finalURL, includingPropertiesForKeys: nil)) ?? [] {
            guard !icon.lastPathComponent.contains(".DS_Store") else { continue }
            try? fm.copyItem(at: icon, to: themeURL.appendingPathComponent(appIDFromIcon(url: icon) + ".png"))
        }
        getThemes()
    }
    
    private func appIDFromIcon(url: URL) -> String {
        return url.deletingPathExtension().lastPathComponent.replacingOccurrences(of: iconFileEnding(iconFilename: url.lastPathComponent), with: "")
    }
    
    // MARK: - Utils
    private func iconFileEnding(iconFilename: String) -> String {
        if iconFilename.contains("-large.png") {
            return "-large"
        } else if iconFilename.contains("@2x.png") {
            return"@2x"
        } else if iconFilename.contains("@3x.png") {
            return "@3x"
        } else {
            return ""
        }
    }
}
