//
//  DeviceSupportAPI.swift
//  Cowabunga Lite
//
//  Created by lemin on 10/27/23.
//

import Foundation

class DeviceSupportAPI: ObservableObject {
    static let shared = DeviceSupportAPI()
    
    private let lastTestedVersionHardCoded: String = "17.1.9" // hard coded last tested version in case user starts app for the first time w/out wifi
    private let apiVersion: String = "1.0"
    
    var lastTestedVersion: String? = nil
    
    private var serverURL = ""
    private var session = URLSession.shared
    
    // fetch the latest version from the github json
    func fetchLatestVersion() async throws -> String {
        if serverURL == "" {
            let hash = try await getCommitHash()
            serverURL = "https://raw.githubusercontent.com/leminlimez/Cowabunga-explore-repo/\(hash)/"
        }
        
        let request = URLRequest(url: .init(string: serverURL + "CBLSupportedDevices.json")!)
        
        let (data, response) = try await session.data(for: request) as! (Data, HTTPURLResponse)
        guard response.statusCode == 200 else { throw "Could not connect to server" }
        let info = try JSONDecoder().decode(SupportedDevices.self, from: data)
        
        // determine if it is for debug or not
        var debug: Bool = false
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String, build != "0" {
            // on the debug version
            debug = true
        }
        
        if (debug ? info.DEBUG_version : info.version).compare(apiVersion, options: .numeric) == .orderedSame {
            let ver = debug ? info.DEBUG_max_os : info.max_os
            print("Last Tested Version (from server): \(ver)")
            UserDefaults.standard.setValue(ver, forKey: "LastTestedVersion")
            return ver
        }
        
        throw "No data found!"
    }
    
    // get the last tested version for the variable
    func getLastTestedVersion() async {
        // make it so they don't have to wait
        if let ver = UserDefaults.standard.string(forKey: "LastTestedVersion"), ver.compare(lastTestedVersionHardCoded, options: .numeric) == .orderedDescending {
            lastTestedVersion = ver
        } else {
            lastTestedVersion = lastTestedVersionHardCoded
        }
        
        // fetch the request if possible
        do {
            lastTestedVersion = try await fetchLatestVersion()
        } catch {
            print(error.localizedDescription)
        }
        print("Last Tested Version: \(lastTestedVersion ?? "UNKNOWN")")
    }
    
    func getCommitHash() async throws -> String {
        let request = URLRequest(url: .init(string: serverURL + "https://api.github.com/repos/leminlimez/Cowabunga-explore-repo/commits/main")!)
        
        let (data, response) = try await session.data(for: request) as! (Data, HTTPURLResponse)
        guard response.statusCode == 200 else { throw "Could not connect to server" }
        guard let themes = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { throw "Unable to obtain repo hash. Maybe update to the latest version?" }
        guard let hash = themes["sha"] as? String else { throw "Unable to obtain repo hash. Maybe update to the latest version?" }
        return hash
    }
}

struct SupportedDevices: Decodable {
    let max_os: String
    let version: String
    let DEBUG_max_os: String
    let DEBUG_version: String
}
