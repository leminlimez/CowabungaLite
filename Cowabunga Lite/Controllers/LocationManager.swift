//
//  LocationManager.swift
//  Cowabunga Lite
//
//  Created by lemin on 9/15/23.
//

import Foundation

struct DevDisk: Decodable {
    let tag_name: String
}

public class LocationManager: ObservableObject {
    static let shared = LocationManager()
    static let DT_SIMULATELOCATION_SERVICE = "com.apple.dt.simulatelocation"
    
    // disk getter values
    @Published var downloading: Bool = false
    @Published var loaded: Bool = false
    @Published var succeeded: Bool = false
    
    // mounting values
    @Published var mounting: Bool = false
    @Published var mounted: Bool = false
    @Published var mountingFailed: Bool = false
    
    // get the list of disk images
    private func getDevDisks() async throws -> [DevDisk] {
        if let gitURL = URL(string: "https://api.github.com/repos/mspvirajpatel/Xcode_Developer_Disk_Images/releases") {
            let (data, _) = try await URLSession.shared.data(from: gitURL)
            let decoded: [DevDisk] = try JSONDecoder().decode([DevDisk].self, from: data)
            return decoded
        } else {
            throw "Failed to get the developer disk github url!"
        }
    }
    
    // get close version
    private func dropVersionPatch(_ ver: String) -> String {
        let split = ver.split(separator: ".")
        return "\(split[0]).\(split[1])"
    }
    
    // reset the values (for when device changes)
    public func resetValues() {
        mounted = false
        succeeded = false
        mountingFailed = false
        loaded = false
    }
    
    // MARK: Managing the Location
    
    // set the location given latitude and longitude
    // returns whether or not it was successful
    public func setLocation(lat: String, lon: String) -> Bool {
        // get the locsim utils executable
        guard let exec = Bundle.main.url(forResource: "locsimUtils", withExtension: "") else {
            Logger.shared.logMe("Error locating locsimUtils")
            return false
        }
        // get the current uuid
        guard let currentUUID = DataSingleton.shared.getCurrentUUID() else {
            Logger.shared.logMe("Error getting current UUID")
            return false
        }
        // execute
        do {
            let result = try execute2(exec, arguments: ["-u", currentUUID, "-l", lat, "-s", lon])
            if result.contains("ERROR") || result.contains("Usage") {
                return false
            }
        } catch {
            Logger.shared.logMe("Error executing locsimUtils: \(error.localizedDescription)")
        }
        return true
    }
    
    // reset the location
    // returns whether or not it was successful
    public func resetLocation() -> Bool {
        // get the locsim utils executable
        guard let exec = Bundle.main.url(forResource: "locsimUtils", withExtension: "") else {
            Logger.shared.logMe("Error locating locsimUtils")
            return false
        }
        // get the current uuid
        guard let currentUUID = DataSingleton.shared.getCurrentUUID() else {
            Logger.shared.logMe("Error getting current UUID")
            return false
        }
        // execute
        do {
            let result = try execute2(exec, arguments: ["-u", currentUUID, "-r", "bbhhjjkk"])
            if result.contains("ERROR") || result.contains("Usage") {
                return false
            }
        } catch {
            Logger.shared.logMe("Error executing locsimUtils: \(error.localizedDescription)")
        }
        return true
    }
    
    // MARK: Image Downloading/Mounting
    
    // check if the device actually needs mounting
    public func deviceNeedsMounting() -> Bool {
        // get the locsim utils executable
        guard let exec = Bundle.main.url(forResource: "locsimUtils", withExtension: "") else {
            Logger.shared.logMe("Error locating locsimUtils")
            return true
        }
        // get the current uuid
        guard let currentUUID = DataSingleton.shared.getCurrentUUID() else {
            Logger.shared.logMe("Error getting current UUID")
            return true
        }
        // execute
        do {
            let result = try execute2(exec, arguments: ["-u", currentUUID, "-m"])
            if !result.contains("Make sure a developer disk image is mounted!") {
                return false
            }
        } catch {
            Logger.shared.logMe("Error executing locsimUtils: \(error.localizedDescription)")
        }
        return true
    }
    
    // make sure the disk images are downloaded
    // if not, then download it
    @MainActor public func loadDiskImages() async throws {
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
                if disk.tag_name == targetVersion || disk.tag_name == dropVersionPatch(targetVersion) {
                    if let downloadURL = URL(string: "https://github.com/mspvirajpatel/Xcode_Developer_Disk_Images/releases/download/\(disk.tag_name)/\(disk.tag_name).zip") {
                        downloading = true
                        URLSession.shared.downloadTask(with: downloadURL) { (tempFileURL, response, error) in
                            let fm = FileManager.default
                            if let tempFileURL = tempFileURL {
                                do {
                                    let unzipURL = fm.temporaryDirectory.appendingPathComponent("devdisk_unzip")
                                    if fm.fileExists(atPath: unzipURL.path) {
                                        try? fm.removeItem(at: unzipURL)
                                    }
                                    try fm.unzipItem(at: tempFileURL, to: unzipURL)
                                    if fm.fileExists(atPath: unzipURL.appendingPathComponent(disk.tag_name).path) {
                                        if fm.fileExists(atPath: diskDirectory.appendingPathComponent(targetVersion).path) {
                                            try? fm.removeItem(at: diskDirectory.appendingPathComponent(targetVersion))
                                        }
                                        try fm.moveItem(at: unzipURL.appendingPathComponent(disk.tag_name), to: diskDirectory.appendingPathComponent(targetVersion))
                                    } else {
                                        throw "Could not find the main version file!"
                                    }
                                    self.downloading = false
                                    self.loaded = true
                                    self.succeeded = true
                                } catch {
                                    Logger.shared.logMe("Failed to download the dev image: \(error.localizedDescription)")
                                    self.downloading = false
                                    self.loaded = true
                                    self.succeeded = false
                                }
                            } else {
                                Logger.shared.logMe("Failed to download the dev image: url was nil")
                                self.downloading = false
                                self.loaded = true
                                self.succeeded = false
                            }
                        }.resume()
                        return;
                    }
                }
            }
            self.downloading = false
            self.loaded = true
            self.succeeded = false
        }
    }
    
    // mount the dev image
    public func mountImage() {
        mounting = true
        if let targetVersion = DataSingleton.shared.getCurrentVersion() {
            let diskImagePath = documentsDirectory.appendingPathComponent("DevDisks").appendingPathComponent(targetVersion).appendingPathComponent("DeveloperDiskImage.dmg").path
            if FileManager.default.fileExists(atPath: diskImagePath) {
                // get the image mounter executable
                guard let exec = Bundle.main.url(forResource: "ideviceimagemounter", withExtension: "") else {
                    Logger.shared.logMe("Error locating ideviceimagemounter")
                    mountingFailed = true
                    mounting = false
                    return
                }
                // get the current uuid
                guard let currentUUID = DataSingleton.shared.getCurrentUUID() else {
                    Logger.shared.logMe("Error getting current UUID")
                    mountingFailed = true
                    mounting = false
                    return
                }
                
                // execute
                do {
                    let result = try execute2(exec, arguments: ["-u", currentUUID, diskImagePath])
                    if result == "Error: ImageMountFailed" {
                        Logger.shared.logMe("Failed to mount the developer image!")
                        mountingFailed = true
                        mounting = false
                    } else {
                        mounted = true
                        mounting = false
                    }
                    return
                } catch {
                    Logger.shared.logMe("Error mounting image: \(error.localizedDescription)")
                }
            } else {
                Logger.shared.logMe("DeveloperDiskImage.dmg not found for version \(targetVersion)")
            }
        } else {
            Logger.shared.logMe("Device version returned nil")
        }
        mountingFailed = true
        mounting = false
    }
}
