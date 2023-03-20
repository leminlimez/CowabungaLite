//
//  RootView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/16/23.
//

import SwiftUI

struct RootView: View {
    @State private var devices: [Device]?
    @State private var selectedDeviceIndex = 0
    @State var homeActive: Bool = true
    
    func updateDevices() {
        devices = getDevices()
        if selectedDeviceIndex >= (devices?.count ?? 0) {
            selectedDeviceIndex = 0
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                HStack {
                    Picker(selection: $selectedDeviceIndex, label: Image(systemName: "iphone")) {
                        if let devices = devices {
                            if devices.isEmpty {
                                Text("None").tag(0)
                            } else {
                                ForEach(0..<devices.count, id: \.self) { index in
                                    Text("\(devices[index].name) (\(devices[index].uuid))")
                                }
                            }
                        } else {
                            Text("Loading...")
                        }
                    }.onAppear {
                        updateDevices()
                    }
                    
                    Button(action: {
                        updateDevices()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                
                Divider()
                
                NavigationLink(destination: HomeView(), isActive: $homeActive) {
                    HStack {
                        Image(systemName: "house")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                        Text("Home")
                            .padding(.horizontal, 8)
                    }
                }
                .padding(.vertical, 5)
                
                NavigationLink(destination: HomeView()) {
                    HStack {
                        Image(systemName: "info.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                        Text("About")
                            .padding(.horizontal, 8)
                    }
                }
                .padding(.vertical, 5)
                
                Divider()
                
                Text("Tools")
                    .foregroundColor(.secondary)
                
                NavigationLink(destination: StatusBarView()) {
                    HStack {
                        Image(systemName: "wifi")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                        Text("Status Bar")
                            .padding(.horizontal, 8)
                    }
                }
                NavigationLink(destination: StatusBarView()) {
                    HStack {
                        Image(systemName: "iphone")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                        Text("Footnote")
                            .padding(.horizontal, 8)
                    }
                }
                
                Divider()
                
                NavigationLink(destination: StatusBarView()) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                        Text("Apply")
                            .padding(.horizontal, 8)
                    }
                }
            }
            .frame(minWidth: 250)
        }
//        TabView {
//            HomeView()
//                .tabItem {
//                    Label("Home", systemImage: "house")
//                }
//            HomeView()
//                .tabItem {
//                    Label("About", systemImage: "i.circle")
//                }
//        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
