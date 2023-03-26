//
//  ThemingManager.swift
//  CowabungaJailed
//
//  Created by lemin on 3/24/23.
//

import Foundation

class ThemingManager {
    struct AppIconChange {
        var appID: String
        var themeIconURL: URL?
        var name: String
    }
    
    private static let filePath: String = "HomeDomain/Library/WebClips"
    
    public static func makeInfoPlist(displayName: String = " ", bundleID: String, isAppClip: Bool = false) throws -> Data {
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
    
    public static func getAppliedThemeFolder() -> URL? {
        return DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent("AppliedTheme/HomeDomain/Library/WebClips")
    }
    
    public static func makeWebClip(displayName: String = " ", image: Data, bundleID: String, isAppClip: Bool = false) throws {
        let folderName: String = "Cowabunga_" + bundleID + ".webclip"// + String(bundleID.data(using: .utf8)!.base64EncodedString()) + ".webclip"
        guard let folderURL = getAppliedThemeFolder()?.appendingPathComponent(folderName) else {
            throw "Error getting webclip folder"
        }
        do {
            if !FileManager.default.fileExists(atPath: folderURL.path) {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: false)
            }
            // create the info plist
            let infoPlist = try makeInfoPlist(displayName: displayName, bundleID: bundleID, isAppClip: isAppClip)
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
    
    public static func eraseAppliedTheme() {
        guard let appliedFolder = getAppliedThemeFolder() else {
            return
        }
        do {
            for folder in try FileManager.default.contentsOfDirectory(at: appliedFolder, includingPropertiesForKeys: nil) {
                try? FileManager.default.removeItem(at: folder)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public static func getThemesFolder() -> URL {
        let themesFolder = documentsDirectory.appendingPathComponent("Themes")
        if !FileManager.default.fileExists(atPath: themesFolder.path) {
            try? FileManager.default.createDirectory(at: themesFolder, withIntermediateDirectories: false)
        }
        return themesFolder
    }
    
    public static func applyTheme(themeName: String, hideDisplayNames: Bool = false, appClips: Bool = false) throws {
        let themeFolder = getThemesFolder().appendingPathComponent(themeName)
        if !FileManager.default.fileExists(atPath: themeFolder.path) {
            throw "No theme folder found for \(themeName)!"
        }
        for file in try FileManager.default.contentsOfDirectory(at: themeFolder, includingPropertiesForKeys: nil) {
            let bundleID: String = file.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "-large", with: "")
            // CHECK IF THE USER HAS THE BUNDLE ID INSTALLED
            // IF NOT, CONTINUE
            var displayName: String = " "
            if !hideDisplayNames {
                // get the display name from the bundle id
            }
            do {
                let imgData = try Data(contentsOf: file)
                try makeWebClip(displayName: displayName, image: imgData, bundleID: bundleID, isAppClip: appClips)
            } catch {
                Logger.shared.logMe(error.localizedDescription)
            }
        }
    }
}
