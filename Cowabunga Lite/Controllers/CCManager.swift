//
//  CCManager.swift
//  Cowabunga Lite
//
//  Created by lemin on 5/28/23.
//

import Foundation

class CCManager {
    public static func getPresetsFolder() -> URL {
        let presetsFolder = documentsDirectory.appendingPathComponent("CC_Presets")
        if !FileManager.default.fileExists(atPath: presetsFolder.path) {
            try? FileManager.default.createDirectory(at: presetsFolder, withIntermediateDirectories: false)
        }
        return presetsFolder
    }
}
