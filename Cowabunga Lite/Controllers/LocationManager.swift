//
//  LocationManager.swift
//  Cowabunga Lite
//
//  Created by lemin on 9/15/23.
//

import Foundation

struct DevDiskResponse: Decodable {
    let results: [DevDisk]
}
struct DevDisk: Decodable {
    let tag_name: String
}

public class LocationManager: ObservableObject {
    static let shared = LocationManager()
    
    // disk getter values
    @Published var downloading: Bool = false
    @Published var loaded: Bool = false
    @Published var succeeded: Bool = false
    
    // mounting values
    @Published var mounted: Bool = false
    
    // get the list of disk images
    private func getDevDisks() async throws -> [DevDisk] {
        if let gitURL = URL(string: "https://api.github.com/repos/mspvirajpatel/Xcode_Developer_Disk_Images/releases") {
            let (data, _) = try await URLSession.shared.data(from: gitURL)
            let decoded = try JSONDecoder().decode(DevDiskResponse.self, from: data)
            return decoded.results
        } else {
            throw "Failed to get the developer disk github url!"
        }
    }
    
    // make sure the disk images are downloaded
    // if not, then download it
    public func loadDiskImages() async throws {
        let fm = FileManager.default
        let diskDirectory = documentsDirectory.appendingPathComponent("DevDisks")
        
        if !fm.fileExists(atPath: diskDirectory.path) {
            try fm.createDirectory(at: diskDirectory, withIntermediateDirectories: false)
        }
        
        if let targetVersion = DataSingleton.shared.getCurrentVersion() {
            // check if it exists first
            // if not, redownload
            if fm.fileExists(atPath: diskDirectory.appendingPathComponent(targetVersion).path) {
                // make sure it has the image
                if fm.fileExists(atPath: diskDirectory.appendingPathComponent(targetVersion).appendingPathComponent("DeveloperDiskImage.dmg").path) {
                    loaded = true
                    succeeded = true
                    return
                }
            }
            let devDisks = try await getDevDisks()
            for disk in devDisks {
                if disk.tag_name == targetVersion {
                    if let downloadURL = URL(string: "https://github.com/mspvirajpatel/Xcode_Developer_Disk_Images/releases/download/\(targetVersion)/\(targetVersion).zip") {
                        downloading = true
                        URLSession.shared.downloadTask(with: downloadURL) { (tempFileURL, response, error) in
                            let fm = FileManager.default
                            if let tempFileURL = tempFileURL {
                                do {
                                    let unzipURL = diskDirectory.appendingPathComponent(targetVersion)
                                    if fm.fileExists(atPath: unzipURL.path) {
                                        try? fm.removeItem(at: unzipURL)
                                    }
                                    try fm.unzipItem(at: tempFileURL, to: unzipURL)
                                    self.downloading = false
                                    self.loaded = true
                                    self.succeeded = true
                                } catch {
                                    Logger.shared.logMe("Failed to download the dev image: \(error.localizedDescription)")
                                    self.downloading = false
                                    self.loaded = true
                                    self.succeeded = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // mount the dev image
    public func mountImage() {
        if let targetVersion = DataSingleton.shared.getCurrentVersion() {
            let diskImagePath = documentsDirectory.appendingPathComponent("DevDisks").appendingPathComponent(targetVersion).appendingPathComponent("DeveloperDiskImage.dmg").path
            if FileManager.default.fileExists(atPath: diskImagePath) {
                // get the image mounter executable
                guard let exec = Bundle.main.url(forResource: "ideviceimagemounter", withExtension: "") else {
                    Logger.shared.logMe("Error locating ideviceimagemounter")
                    return
                }
                // get the current uuid
                guard let currentUUID = DataSingleton.shared.getCurrentUUID() else {
                    Logger.shared.logMe("Error getting current UUID")
                    return
                }
                
                // execute
                do {
                    try execute(exec, arguments: ["-u", currentUUID, diskImagePath])
                    mounted = true
                } catch {
                    Logger.shared.logMe("Error mounting image: \(error.localizedDescription)")
                }
            } else {
                Logger.shared.logMe("DeveloperDiskImage.dmg not found for version \(targetVersion)")
            }
        } else {
            Logger.shared.logMe("Device version returned nil")
        }
    }
}
