//
//  LocSimView.swift
//  Cowabunga Lite
//
//  Created by lemin on 9/15/23.
//

import Foundation
import SwiftUI

struct LocSimView: View {
    @StateObject var locationManager = LocationManager.shared
    
    var body: some View {
        VStack {
            if !locationManager.loaded {
                // show loading screen
                Spacer()
                if locationManager.downloading {
                    Text("Downloading Developer Disk Image...")
                } else {
                    Text("Preparing Setup...")
                }
                Spacer()
            } else if !locationManager.mounted {
                Spacer()
                if locationManager.succeeded {
                    if locationManager.mountingFailed {
                        // show the user that the mount failed
                        Text("Failed to mount Developer Disk Image!")
                            .padding(5)
                        Text("See log on the apply page for details.")
                    } else if locationManager.mounting {
                        // show that it is currently mounting
                        Text("Mounting Developer Disk Image...")
                    } else {
                        // show button to mount
                        Text("Ready to mount...")
                            .padding(5)
                        Button("Mount") {
                            locationManager.mountImage()
                        }
                    }
                } else {
                    Text("Failed to get Developer Disk Image!")
                        .padding(5)
                    Text("See log on the apply page for details.")
                        .font(.footnote)
                }
                Spacer()
            } else {
                // main view
                Text("h")
            }
        }
        .onAppear {
            // if the image is not downloaded, download the image
            if !locationManager.loaded && !locationManager.downloading {
                if locationManager.deviceNeedsMounting() {
                    Task {
                        do {
                            try await locationManager.loadDiskImages()
                        } catch {
                            Logger.shared.logMe("Error loading Developer Disk Image: \(error.localizedDescription)")
                            locationManager.succeeded = false
                            locationManager.downloading = false
                            locationManager.loaded = true
                        }
                    }
                } else {
                    locationManager.succeeded = true
                    locationManager.mounted = true
                    locationManager.loaded = true
                }
            }
        }
    }
}
