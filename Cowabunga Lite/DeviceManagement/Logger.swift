//
//  Logger.swift
//  CowabungaJailed
//
//  Created by Lauren Woo on 21/4/2023.
//

import Foundation

@objc class Logger: NSObject, ObservableObject {
    @objc static let shared = Logger()
    
    @objc static var versionBuildString: String? = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0" == "0" ? nil : "Beta \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0")"
    
    @Published var logText = "Cowabunga Lite version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") (\(versionBuildString ?? "Release")) on MacOS \(ProcessInfo.osVersion)\n"

    @objc func logMe(_ message: String) {
        print(message)
        logText += "\(message)\n"
    }
}

