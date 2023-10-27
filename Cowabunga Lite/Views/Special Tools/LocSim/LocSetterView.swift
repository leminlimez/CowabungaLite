//
//  LocSetterView.swift
//  Cowabunga Lite
//
//  Created by lemin on 9/16/23.
//

import Foundation
import SwiftUI

struct LocSetterView: View {
    @StateObject var locationManager = LocationManager.shared
    
    @State var lat: String = ""
    @State var lon: String = ""
    
    var body: some View {
        VStack {
            // MARK: Latitude Input
            Group {
                Text("Latitude")
                    .bold()
                HStack {
                    Spacer()
                    TextField("XXX.XXXXX", text: $lat)
                    Spacer()
                }
            }
            
            // MARK: Longitude Input
            Group {
                Text("Longitude")
                    .bold()
                HStack {
                    Spacer()
                    TextField("XXX.XXXXX", text: $lon)
                    Spacer()
                }
            }
            
            // MARK: Set Location
            Button(action: {
                if lat != "" && lon != "" {
                    print(lat, lon)
                    let _ = locationManager.setLocation(lat: lat, lon: lon)
                }
            }) {
                Text("Set Location")
            }
            .padding(5)
            
            // MARK: Reset Location
            Button(action: {
                let _ = locationManager.resetLocation()
            }) {
                Text("Reset Location")
            }
            .padding(5)
        }
    }
}
