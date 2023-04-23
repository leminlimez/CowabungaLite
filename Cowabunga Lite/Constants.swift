//
//  Constants.swift
//  CowabungaJailed
//
//  Created by Rory Madden on 22/3/2023.
//

import Foundation

let fm = FileManager.default
@usableFromInline let documentsDirectory = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("com.leemin.CowabungaLite")

struct AppInfo {
    let bundleId: String
    let name: String
    let oldWebclipExists: Bool
    let icon: Data?
    let themedIcon: Data?
}

struct Device {
    let uuid: String
    let name: String
    let version: String
    let ipad: Bool
}

enum Tweak: String {
    case footnote = "Footnote"
    case statusBar = "StatusBar"
    case springboardOptions = "SpringboardOptions"
    case skipSetup = "SkipSetup"
    case themes = "AppliedTheme"
    case dynamicIsland = "DynamicIsland"
    case none = "None"
}
