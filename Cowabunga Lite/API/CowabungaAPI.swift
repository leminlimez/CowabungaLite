//
//  CowabungaAPI.swift
//  CowabungaLite
//
//  Created by lemin on 3/29/2023.
//

import ZIPFoundation
import SwiftUI

enum ThemeFilterType: String, CaseIterable {
    case random = "Random"
    case newest = "Newest"
    case oldest = "Oldest"
}

class CowabungaAPI: ObservableObject {
    
    static let shared = CowabungaAPI()
    
    var serverURL = ""
    var session = URLSession.shared
    
    let fm = FileManager.default
    
    func fetchThemes(type: DownloadableTheme.ThemeType) async throws -> [DownloadableTheme] {
        let request = URLRequest(url: .init(string: serverURL + "\(type.rawValue)-themes.json")!)
        
        let (data, response) = try await session.data(for: request) as! (Data, HTTPURLResponse)
        guard response.statusCode == 200 else { throw "Could not connect to server" }
        let themes = (try JSONDecoder().decode([DownloadableTheme].self, from: data))
        
        for i in themes.indices {
            themes[i].type = type
        }
        
        return themes
    }
    
    func filterTheme(themes: [DownloadableTheme], filterType: ThemeFilterType) -> [DownloadableTheme] {
        var filtered = themes
        if filterType == ThemeFilterType.newest {
            filtered = filtered.reversed()
        } else if filterType == ThemeFilterType.random {
            filtered = filtered.shuffled()
        }
        return filtered
    }
    
    func downloadTheme(theme: DownloadableTheme) async throws {
        let tempThemeDownloadURL = fm.temporaryDirectory.appendingPathComponent("theme.zip")
        try? fm.removeItem(at: tempThemeDownloadURL)
        
        let downloadURL = getDownloadURLForTheme(theme: theme)
        let previewURL = getPreviewURLForTheme(theme: theme)
        
        print("Downloading from \(downloadURL)")
        
        var saveURL = documentsDirectory
        
        // Get the save path
        switch theme.type {
        case .icon:
            saveURL = saveURL.appendingPathComponent("Themes")
        case .cc:
            saveURL = saveURL.appendingPathComponent("CC_Presets")
        default:
            throw "unknown theme type"
        }
        saveURL.appendPathComponent(theme.name)
        
//        try? FileManager.default.createDirectory(at: saveURL, withIntermediateDirectories: true)
        
        
        let request1 = URLRequest(url: downloadURL)
            
        let (data1,response1) = try await session.data(for: request1) as! (Data, HTTPURLResponse)
        guard response1.statusCode == 200 else { throw "Could not connect to server while downloading theme" }
        try data1.write(to: tempThemeDownloadURL)
        
        // Extract the main files
        switch theme.type {
        case .icon:
            // Case for Icon Themes
            let tmpExtract = saveURL.deletingLastPathComponent().appendingPathComponent("tmp_extract")
            if FileManager.default.fileExists(atPath: tmpExtract.path) {
                try? FileManager.default.removeItem(at: tmpExtract)
            }
            try fm.unzipItem(at: tempThemeDownloadURL, to: tmpExtract)
            
            try ThemingManager.shared.importTheme(from: tmpExtract.appendingPathComponent(theme.name))
            
            try fm.removeItem(at: tmpExtract)
        case .cc:
            // Case for CC Presets
            if !FileManager.default.fileExists(atPath: saveURL.path) {
                try FileManager.default.createDirectory(at: saveURL, withIntermediateDirectories: false)
            }
            // Apply the properties
            let plistData = try Data(contentsOf: tempThemeDownloadURL)
            var plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
            let info: [String: Any] = [
                "title": theme.name,
                "identification": theme.identification ?? theme.name,
                "author": theme.contact["Twitter"] ?? "Unknown",
                "modules": theme.modules ?? []
            ]
            plist["preset-identifiers"] = info
            let newData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
            try newData.write(to: saveURL.appendingPathComponent("ModuleConfiguration.plist"))
        default:
            throw "unknown theme type"
        }
        
        let request2 = URLRequest(url: previewURL)
        let previewSaveURL = saveURL.appendingPathComponent("preview.png")
        let (data2,response2) = try await session.data(for: request2) as! (Data, HTTPURLResponse)
        guard response2.statusCode == 200 else { throw "Could not connect to server while downloading preview" }
        print(previewSaveURL)
        try data2.write(to: previewSaveURL)
        
        try? fm.removeItem(at: tempThemeDownloadURL)
        
        
        //            let saveURL = PasscodeKeyFaceManager.getPasscodesDirectory()!
        //
        //
        //            // save the passthm file
        //            let themeSaveURL = saveURL.appendingPathComponent("theme.passthm")
        //            let themeTask = URLSession.shared.dataTask(with: theme.url) { data, response, error in
        //                guard let data = data else {
        //                    print("No data found!")
        //                    UIApplication.shared.dismissAlert(animated: true)
        //                    UIApplication.shared.alert(title: "Could not download passcode theme!", body: error?.localizedDescription ?? "Unknown Error")
        //                    return
        //                }
        //                do {
        //                    try data.write(to: themeSaveURL)
        //                } catch {
        //                    print("Could not save data to theme save url!")
        //                    UIApplication.shared.dismissAlert(animated: true)
        //                    UIApplication.shared.alert(title: "Could not download passcode theme!", body: error.localizedDescription)
        //                    return
        //                }
        //
        //                // save the preview file
        //                let previewSaveURL = saveURL.appendingPathComponent("preview.png")
        //                let task = URLSession.shared.dataTask(with: theme.preview) { prevData, prevResponse, prevError in
        //                    guard let prevData = prevData else {
        //                        print("No data found!")
        //                        UIApplication.shared.dismissAlert(animated: true)
        //                        UIApplication.shared.alert(title: "Could not download passcode theme!", body: prevError?.localizedDescription ?? "Unknown Error")
        //                        return
        //                    }
        //                    do {
        //                        try prevData.write(to: previewSaveURL)
        //                        UIApplication.shared.dismissAlert(animated: true)
        //                        UIApplication.shared.alert(title: "Successfully saved passcode theme!", body: "You can use it by tapping the import button in the Passcode Editor and tapping \"Saved\".")
        //                    } catch {
        //                        print("Could not save data to preview url!")
        //                        UIApplication.shared.dismissAlert(animated: true)
        //                        UIApplication.shared.alert(title: "Could not download passcode theme!", body: error.localizedDescription)
        //                        return
        //                    }
        //                }
        //                task.resume()
        //            }
        //            themeTask.resume()
    }
    
    func getCommitHash() async throws -> String {
        let request = URLRequest(url: .init(string: serverURL + "https://api.github.com/repos/leminlimez/Cowabunga-explore-repo/commits/main")!)
        
        let (data, response) = try await session.data(for: request) as! (Data, HTTPURLResponse)
        guard response.statusCode == 200 else { throw "Could not connect to server" }
        guard let themes = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { throw "Unable to obtain repo hash. Maybe update to the latest version?" }
        guard let hash = themes["sha"] as? String else { throw "Unable to obtain repo hash. Maybe update to the latest version?" }
        return hash
    }
    
    func getDownloadURLForTheme(theme: DownloadableTheme) -> URL {
        URL(string: serverURL + theme.url)!
    }
    
    func getPreviewURLForTheme(theme: DownloadableTheme) -> URL {
        URL(string: serverURL + theme.preview)!
    }
    
    init() {
        Task {
            do {
                let hash = try await getCommitHash()
                serverURL = "https://raw.githubusercontent.com/leminlimez/Cowabunga-explore-repo/\(hash)/"
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

class DownloadableTheme: Identifiable, Codable {
    var name: String
    var identification: String?
    var description: String
    var url: String
    var preview: String
    var contact: [String: String]
    var modules: [Int]? = nil
    var type: ThemeType?
    var version: String

    init(name: String, description: String, contact: [String : String], preview: String, url: String, version: String) {
        self.name = name
        self.description = description
        self.contact = contact
        self.preview = preview
        self.url = url
        self.version = version
    }
    
    init(name: String, identification: String, description: String, contact: [String : String], modules: [Int], preview: String, url: String, version: String) {
        self.name = name
        self.identification = identification
        self.description = description
        self.contact = contact
        self.modules = modules
        self.preview = preview
        self.url = url
        self.version = version
    }
    
    enum ThemeType: String, Codable {
        case passcode, lock, icon, cc
    }
}
