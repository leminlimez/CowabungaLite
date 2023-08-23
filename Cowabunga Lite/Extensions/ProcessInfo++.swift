//
//  ProcessInfo++.swift
//  Cowabunga Lite
//
//  Created by lemin on 8/23/23.
//

import Foundation

extension ProcessInfo {
    public static var osVersion: String {
        get {
            return "\(ProcessInfo.processInfo.operatingSystemVersion.majorVersion).\(ProcessInfo.processInfo.operatingSystemVersion.minorVersion).\(ProcessInfo.processInfo.operatingSystemVersion.patchVersion)"
        }
    }
}
