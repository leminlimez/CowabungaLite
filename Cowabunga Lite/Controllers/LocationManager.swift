//
//  LocationManager.swift
//  Cowabunga Lite
//
//  Created by lemin on 9/15/23.
//

import Foundation

public class LocationManager {
    static func loadLocationServices(completionHandler: @escaping () -> Void) throws {
        let fm = FileManager.default
        let diskDirectory = documentsDirectory.appendingPathComponent("DevDisks")
        
        if !fm.fileExists(atPath: diskDirectory.path) {
            try fm.createDirectory(at: diskDirectory, withIntermediateDirectories: false)
        }
        
        let targetVersion = DataSingleton.shared.getCurrentVersion()
        if let gitURL = URL(string: "https://api.github.com/repos/mspvirajpatel/Xcode_Developer_Disk_Images/releases") {
            let task = URLSession.shared.dataTask(with: gitURL, completionHandler: { (data, response, error) in
                
            })
            
            task.resume()
        }
    }
}
