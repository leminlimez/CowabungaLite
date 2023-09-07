//
//  CowabungaJailedApp.swift
//  CowabungaJailed
//
//  Created by lemin on 3/16/23.
//

import SwiftUI

@main
struct CowabungaLiteApp: App {
    init() {
        if !fm.fileExists(atPath: documentsDirectory.path) {
            do {
                try fm.createDirectory(at: documentsDirectory, withIntermediateDirectories: false)
            } catch {
                Logger.shared.logMe("Error creating directory com.leemin.CowabungaLite")
            }
        }
        let _ = CCManager.getPresetsFolder()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .onOpenURL(perform: { url in
                    // MARK: Opening .cowperation
                    if url.pathExtension.lowercased() == "cowperation" {
                        do {
                            try CustomOperationsManager.shared.importOperation(url)
                            
                            // update operations
                            CustomOperationsManager.shared.getOperations()
                        } catch {
                            Logger.shared.logMe(error.localizedDescription)
                        }
                    }
                })
        }
    }
}
