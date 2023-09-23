//
//  LocationManager17.swift
//  Cowabunga Lite
//
//  Created by lemin on 9/22/23.
//

import Foundation

struct DevDisk17: Decodable {
    let images: [String: String]
}

// Location Manager for iOS 17+
public class LocationManager17: LocationManager {
    
    // get the list of disk images
    private func getDevDisks() async throws -> DevDisk17 {
        if let gitURL = URL(string: "https://raw.githubusercontent.com/master131/iFakeLocation/master/updates.json") {
            let (data, _) = try await URLSession.shared.data(from: gitURL)
            let decoded: DevDisk17 = try JSONDecoder().decode(DevDisk17.self, from: data)
            return decoded
        } else {
            throw "Failed to get the developer disk github url!"
        }
    }
    
    // make sure the directory has files
    private func hasFiles(dir: URL) -> Bool {
        let fm = FileManager.default
        return (
            fm.fileExists(atPath: dir.appendingPathComponent("Image.dmg").path)
            && fm.fileExists(atPath: dir.appendingPathComponent("BuildManifest.plist").path)
            && fm.fileExists(atPath: dir.appendingPathComponent("Image.dmg.trustcache").path)
        )
    }
    
    // MARK: Image Downloading/Mounting
    
    // make sure the disk images are downloaded
    // if not, then download it
    @MainActor public override func loadDiskImages() async throws {
        let fm = FileManager.default
        let diskDirectory = documentsDirectory.appendingPathComponent("DevDisks")
        guard let currentUUID = DataSingleton.shared.getCurrentUUID() else {
            self.downloading = false
            self.loaded = true
            self.succeeded = false
            throw "Failed to get UUID"
        }
        
        if !fm.fileExists(atPath: diskDirectory.path) {
            try fm.createDirectory(at: diskDirectory, withIntermediateDirectories: false)
        }
        
        if let targetVersionString = DataSingleton.shared.getCurrentVersion() {
            let targetVersion = Version(ver: targetVersionString)
            // check if it exists first
            // if not, download the one closest to the current version
            if (
                fm.fileExists(atPath: diskDirectory.appendingPathComponent(targetVersion.description).path)
                && fm.fileExists(atPath: diskDirectory.appendingPathComponent(targetVersion.description).appendingPathComponent(currentUUID).path)
                ) {
                // make sure it has the image
                if hasFiles(dir: diskDirectory.appendingPathComponent(targetVersion.description).appendingPathComponent(currentUUID)) {
                    loaded = true
                    succeeded = true
                    return
                }
            }
            let devDisks = try await getDevDisks()
            
            // download it if the version exists
            if let indexedURL = devDisks.images["\(targetVersion.major).\(targetVersion.minor)"], let downloadURL = URL(string: indexedURL) {
                downloading = true
                let folderName: String = String(indexedURL.split(separator: "/").last ?? "iPhone-iPadOS-Personalized-17")
                URLSession.shared.downloadTask(with: downloadURL) { (tempFileURL, response, error) in
                    let fm = FileManager.default
                    if let tempFileURL = tempFileURL {
                        do {
                            let unzipURL = fm.temporaryDirectory.appendingPathComponent("devdisk_unzip")
                            if fm.fileExists(atPath: unzipURL.path) {
                                try? fm.removeItem(at: unzipURL)
                            }
                            try fm.unzipItem(at: tempFileURL, to: unzipURL)
                            if fm.fileExists(atPath: unzipURL.appendingPathComponent(folderName).path) {
                                if fm.fileExists(atPath: diskDirectory.appendingPathComponent(targetVersion.description).appendingPathComponent(currentUUID).path) {
                                    try? fm.removeItem(at: diskDirectory.appendingPathComponent(targetVersion.description).appendingPathComponent(currentUUID))
                                }
                                try fm.moveItem(at: unzipURL.appendingPathComponent(folderName), to: diskDirectory.appendingPathComponent(targetVersion.description).appendingPathComponent(currentUUID))
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
            self.downloading = false
            self.loaded = true
            self.succeeded = false
        }
    }
}
