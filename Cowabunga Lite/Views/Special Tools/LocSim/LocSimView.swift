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
    @StateObject private var dataSingleton = DataSingleton.shared
    
    var body: some View {
        List {
            Group {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                    VStack {
                        HStack {
                            Text("Location Simulation")
                                .bold()
                            Spacer()
                        }
                    }
                }
                Divider()
            }
            
            if dataSingleton.deviceAvailable {
                Spacer()
                if !locationManager.loaded {
                    // show loading screen
                    if locationManager.downloading {
                        CenteredText(text: "Downloading Developer Disk Image...")
                    } else {
                        CenteredText(text: "Preparing Setup...")
                    }
                } else if !locationManager.mounted {
                    if locationManager.succeeded {
                        if locationManager.mountingFailed {
                            // show the user that the mount failed
                            CenteredText(text: "Failed to mount Developer Disk Image!")
                                .padding(5)
                            CenteredText(text: "See log on the apply page for details.")
                        } else if locationManager.mounting {
                            // show that it is currently mounting
                            CenteredText(text: "Mounting Developer Disk Image...")
                        } else {
                            // show button to mount
                            CenteredText(text: "Ready to mount...")
                                .padding(5)
                            HStack {
                                Spacer()
                                Button("Mount") {
                                    locationManager.mountImage()
                                }
                                Spacer()
                            }
                        }
                    } else {
                        CenteredText(text: "Failed to get Developer Disk Image!")
                            .padding(5)
                        CenteredText(text: "See log on the apply page for details.")
                            .font(.footnote)
                    }
                } else {
                    // main view
                    LocSetterView()
                }
                Spacer()
            }
        }
        .padding(5)
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
