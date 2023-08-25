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
    case operations = "AppliedOperations"
    case themes = "AppliedTheme"
    case statusBar = "StatusBar"
    case controlCenter = "ControlCenter"
    case springboardOptions = "SpringboardOptions"
    case internalOptions = "InternalOptions"
    case skipSetup = "SkipSetup"
    case otaKiller = "OTAKiller"
    case testing = "Testing"
    case none = "None"
}
