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
    @Published var currentOverlay: String? = nil
    @Published var processing: Bool = false
    @Published var themes: [ThemingManager.Theme] = []
    @Published var overlays: [ThemingManager.Overlay] = []
    
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
    
    struct Overlay: Codable, Identifiable, Equatable {
        var id = UUID()
        var name: String
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
    
    public func getOverlayFolder() -> URL {
        let customFolder = getThemesFolder().appendingPathComponent("Overlays")
        if !FileManager.default.fileExists(atPath: customFolder.path) {
            try? FileManager.default.createDirectory(at: customFolder, withIntermediateDirectories: false)
        }
        return customFolder
    }
    
    public func getOverlayData() -> Data? {
        guard let infoPlist = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent("IconThemingPreferences.plist") else { return nil }
        if !FileManager.default.fileExists(atPath: infoPlist.path) {
            return nil
        }
        guard let infoData = try? Data(contentsOf: infoPlist) else {
            return nil
        }
        guard let plist = try? PropertyListSerialization.propertyList(from: infoData, options: [], format: nil) as? [String: Any] else { return nil }
        guard let val = plist["OverlayTitle"] as? String else { return nil }
        let overlayURL = getOverlayFolder().appendingPathComponent(val)
        guard let overlayData = try? Data(contentsOf: overlayURL) else { return nil }
        return overlayData
    }
    
    public func makeWebClip(displayName: String = " ", image: Data, bundleID: String, isAppClip: Bool = false, nameToDisplay: String!, overlay: Data?) throws {
        let folderName: String = "Cowabunga_" + bundleID + "," + displayName + ".webclip"
        guard let folderURL = getAppliedThemeFolder()?.appendingPathComponent(folderName) else {
            throw "Error getting webclip folder"
        }
        do {
            if !FileManager.default.fileExists(atPath: folderURL.path) {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: false)
            }
            // create the info plist
            let infoPlist = try makeInfoPlist(displayName: nameToDisplay != nil ? nameToDisplay! : displayName, bundleID: bundleID, isAppClip: isAppClip)
            try? FileManager.default.removeItem(at: folderURL.appendingPathComponent("Info.plist")) // delete if info plist already exists
            try infoPlist.write(to: folderURL.appendingPathComponent("Info.plist"))
            // write the icon file
            try? FileManager.default.removeItem(at: folderURL.appendingPathComponent("icon.png")) // delete if icon already exists
            var img = image
            // add the overlay over the icon
            if overlay != nil {
                let icnNS = NSImage(data: image)
                let overNS = NSImage(data: overlay!)
                if let icnNS = icnNS, let overNS = overNS {
                    let overlay = IconOverlayManager.overlayIcon(icnNS, overNS)
                    if let overlayData = overlay.pngData(size: icnNS.size) {
                        img = overlayData
                    }
                }
            }
            try img.write(to: folderURL.appendingPathComponent("icon.png"))
        } catch {
            // remove from backup
            try? FileManager.default.removeItem(at: folderURL)
            throw "Error creating WebClip for icon bundle \(bundleID)\n\(error.localizedDescription)"
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
    
    public func setThemeSettings(themeName: String? = nil, hideDisplayNames: Bool? = nil, appClips: Bool? = nil, themeAllApps: Bool? = nil, overlayName: String? = nil, deletingTheme: Bool = false, deletingOverlay: Bool = false) throws {
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
        if overlayName != nil {
            plist["OverlayTitle"] = overlayName!
            currentOverlay = overlayName
        } else if deletingOverlay == true {
            plist["OverlayTitle"] = nil
            currentOverlay = nil
        }
        let newPlist = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try newPlist.write(to: infoPlistPath)
    }
    
    public func applyTheme() {
        let t = getCurrentAppliedTheme()
        Logger.shared.logMe("Applying icon themes...")
        eraseAppliedTheme()
        do {
            try applyTheme(themeName: t, hideDisplayNames: getThemeToggleSetting("HideDisplayNames"), appClips: getThemeToggleSetting("AsAppClips"), themeAllIcons: getThemeToggleSetting("ThemeAllApps"), overlay: getOverlayData())
            Logger.shared.logMe("Successfully applied icon themes!")
        } catch {
            Logger.shared.logMe("An error occurred while applying icon themes: \(error.localizedDescription)")
        }
    }
    
    public func applyTheme(themeName: String?, hideDisplayNames: Bool = false, appClips: Bool = false, themeAllIcons: Bool = false, overlay: Data?) throws {
        let themeFolder = themeName != nil ? getThemesFolder().appendingPathComponent(themeName!) : nil
        if themeFolder != nil && !FileManager.default.fileExists(atPath: themeFolder!.path) {
            throw "No theme folder found for \(themeName!)!"
        }
        let apps = getHomeScreenAppsNew()
        let altIcons = getAltIcons()
        
        for app in apps {
            // get the name to display
            let displayName = app.name
            
            // STEP 1: Apply it if it is an alt icon
            if altIcons[app.bundleId] != nil, let properties = altIcons[app.bundleId] as? [String: String] {
                let name: String? = properties["DisplayName"]
                let imgPath: String? = properties["ImagePath"]
                
                if name == nil && imgPath == "Hidden" { continue; } // do not theme
                
                if imgPath == nil && name != nil {
                    // theme normally but with custom name
                    do {
                        let imgData = try Data(contentsOf: themeFolder!.appendingPathComponent(app.bundleId + ".png"))
                        try makeWebClip(displayName: displayName, image: imgData, bundleID: app.bundleId, isAppClip: appClips, nameToDisplay: name, overlay: overlay)
                    } catch {
                        Logger.shared.logMe(error.localizedDescription)
                    }
                    
                } else if imgPath != nil {
                    if imgPath == "Default", let imgData = app.icon {
                        // theme with the default icon
                        do {
                            try makeWebClip(displayName: displayName, image: imgData, bundleID: app.bundleId, isAppClip: appClips, nameToDisplay: (hideDisplayNames && name == nil) ? " " : name, overlay: overlay)
                        } catch {
                            Logger.shared.logMe(error.localizedDescription)
                        }
                    } else if imgPath != nil {
                        let imgURL = getThemesFolder().appendingPathComponent(imgPath!)
                        if FileManager.default.fileExists(atPath: imgURL.path) {
                            // theme with the alternate icon
                            do {
                                let imgData = try Data(contentsOf: imgURL)
                                try makeWebClip(displayName: displayName, image: imgData, bundleID: app.bundleId, isAppClip: appClips, nameToDisplay: (hideDisplayNames && name == nil) ? " " : name, overlay: overlay)
                            } catch {
                                Logger.shared.logMe(error.localizedDescription)
                            }
                        }
                    }
                }
            }
            
            // STEP 2: Apply it if it is in the main theme
            else if themeFolder != nil && FileManager.default.fileExists(atPath: themeFolder!.appendingPathComponent(app.bundleId + ".png").path) {
                do {
                    let imgData = try Data(contentsOf: themeFolder!.appendingPathComponent(app.bundleId + ".png"))
                    try makeWebClip(displayName: displayName, image: imgData, bundleID: app.bundleId, isAppClip: appClips, nameToDisplay: hideDisplayNames ? " " : nil, overlay: overlay)
                } catch {
                    Logger.shared.logMe(error.localizedDescription)
                }
            }
            
            // STEP 3: Apply it if applying all icons
            else if themeAllIcons {
                // get the image data
                if let imgData = app.icon {
                    do {
                        try makeWebClip(displayName: displayName, image: imgData, bundleID: app.bundleId, isAppClip: appClips, nameToDisplay: hideDisplayNames ? " " : nil, overlay: overlay)
                    } catch {
                        Logger.shared.logMe(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    public func getOverlayImage(name: String) -> NSImage? {
        let overlayFolder = getOverlayFolder()
        guard let d = try? Data(contentsOf: overlayFolder.appendingPathComponent("\(name).png")) else { return nil }
        guard let i = NSImage(data: d) else { return nil }
        return i
    }
    
    public func getOverlays() {
        let overlayFolder = getOverlayFolder()
        overlays.removeAll(keepingCapacity: true)
        do {
            for t in try FileManager.default.contentsOfDirectory(at: overlayFolder, includingPropertiesForKeys: nil) {
                guard let d = try? Data(contentsOf: t) else { continue }
                guard let i = NSImage(data: d) else { continue }
                overlays.append(.init(name: t.deletingLastPathComponent().lastPathComponent))
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func getThemes() {
        let themesFolder = getThemesFolder()
        themes.removeAll(keepingCapacity: true)
        do {
            for t in try FileManager.default.contentsOfDirectory(at: themesFolder, includingPropertiesForKeys: nil) {
                if t.lastPathComponent != "Custom" && t.lastPathComponent != "Overlays" {
                    guard let c = try? FileManager.default.contentsOfDirectory(at: t, includingPropertiesForKeys: nil) else { continue }
                    themes.append(.init(name: t.lastPathComponent, iconCount: (c).count))
                }
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
    
    public func isCurrentOverlay(_ name: String) -> Bool {
        return currentOverlay == name
    }
    
    func importOverlay(from overlayURL: URL) throws -> String {
        let name = overlayURL.deletingLastPathComponent().lastPathComponent
        let pngData = try Data(contentsOf: overlayURL)
        
        // Write the png
        let overlayFolder = getOverlayFolder()
        try pngData.write(to: overlayFolder.appendingPathComponent("\(name).png"))
        overlays.append(.init(name: name))
        return name
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
    
    
    // MARK: Alt Icon Theming
    // Get The Plist File
    private func getAltIconPlist() -> URL? {
        guard let infoPlist = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent("AltIconThemingPreferences.plist") else { return nil }
        if !FileManager.default.fileExists(atPath: infoPlist.path) {
            do {
                try PropertyListSerialization.data(fromPropertyList: [:], format: .xml, options: 0).write(to: infoPlist)
            } catch {
                return nil
            }
        }
        return infoPlist
    }
    
    // Get Values of Alt Icon
    public func getAltIconData(bundleId: String) -> [String: String] {
        let plist = getAltIcons()
        guard let info = plist[bundleId] as? [String: String] else { return [:] }
        return info
    }
    
    // Set Alt Icon Settings
    public func setAltIcon(bundleId: String, displayName: String?, imagePath: String?) throws {
        guard let infoPlist = getAltIconPlist() else { throw "No alt icon preference plist found!" }
        var plist: [String: Any] = getAltIcons()
        
        var newPrefs: [String: String] = [:]
        if displayName != nil {
            newPrefs["DisplayName"] = displayName!
        }
        if imagePath != nil {
            // Format for image path property:
            // Hidden = no icon theming
            // Default = use default icon
            // Anything else = path to icon in themes folder
            newPrefs["ImagePath"] = imagePath!
        }
        if displayName == nil && imagePath == nil {
            plist[bundleId] = nil // reset/delete
        } else {
            plist[bundleId] = newPrefs
        }
        
        let newData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try newData.write(to: infoPlist)
    }
    
    // Get Alt Icon Settings
    public func getAltIcons() -> [String: Any] {
        guard let infoPlist = getAltIconPlist() else { return [:] }
        guard let plistData = try? Data(contentsOf: infoPlist) else { return [:] }
        guard let plist = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any] else { return [:] }
        return plist
    }
    
    // Import an Icon
    public func importAltIcon(from importURL: URL, bundleId: String) throws -> (Data, String) {
        let customFolder = getThemesFolder().appendingPathComponent("Custom")
        if !FileManager.default.fileExists(atPath: customFolder.path) {
            try FileManager.default.createDirectory(at: customFolder, withIntermediateDirectories: false)
        }
        let imgData = try Data(contentsOf: importURL)
        let newFolder = customFolder.appendingPathComponent(bundleId)
        if !FileManager.default.fileExists(atPath: newFolder.path) {
            try FileManager.default.createDirectory(at: newFolder, withIntermediateDirectories: false)
        }
        
        // get the new icon name
        var newName: Int = 0
        while FileManager.default.fileExists(atPath: newFolder.appendingPathComponent("Icon\(newName).png").path) {
            newName += 1
        }
        
        try imgData.write(to: newFolder.appendingPathComponent("Icon\(newName).png"))
        return (imgData, "Custom/\(bundleId)/Icon\(newName).png")
    }
}
