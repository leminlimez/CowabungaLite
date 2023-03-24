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
}
