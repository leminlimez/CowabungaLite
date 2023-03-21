//
//  CowabungaJailedApp.swift
//  CowabungaJailed
//
//  Created by lemin on 3/16/23.
//

import SwiftUI

@main
struct CowabungaJailedApp: App {
    init() {
        if !fm.fileExists(atPath: documentsDirectory.path) {
            do {
                try fm.createDirectory(at: documentsDirectory, withIntermediateDirectories: false)
            } catch {
                Logger.shared.logMe("Error creating directory com.leemin.CowabungaJailed")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
