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
    
    @State private var options: [Category] = [
        .init(options: [
            .init(title: "Home", icon: "house", view: HomeView(), active: true),
            .init(title: "About", icon: "info.circle", view: HomeView()) // to change later
        ]),
        
        // Tools View
        .init(title: "Tools", options: [
            .init(title: "Status Bar", icon: "wifi", view: StatusBarView()),
            .init(title: "Footnote", icon: "platter.filled.bottom.iphone", view: LockScreenFootnoteView())
//            .init(title: "Dynam Islamd", icon: "iphone", view: DynamicIslandView())
        ]),
        
        .init(options: [
            .init(title: "Apply", icon: "checkmark.circle", view: ApplyView())
        ])
    ]
    
    func updateDevices() {
        // fix to update and maintain UUID if a device is disconnected
        devices = getDevices()
        if selectedDeviceIndex >= (devices?.count ?? 0) {
            selectedDeviceIndex = 0
            DataSingleton.shared.resetCurrentUUID()
        } else if let devices = devices {
            DataSingleton.shared.setCurrentUUID(devices[0].uuid)
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
                                    Text("\(devices[index].name)")
                                }
                            }
                        } else {
                            Text("Loading...")
                        }
                    }.onAppear {
                        updateDevices()
                    }.onChange(of: selectedDeviceIndex) { nv in
                        if nv != 0, let devices = devices {
                            DataSingleton.shared.setCurrentUUID(devices[nv - 1].uuid)
                        } else {
                            DataSingleton.shared.resetCurrentUUID()
                        }
                    }
                    
                    Button(action: {
                        updateDevices()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                
                ForEach($options) { cat in
                    Divider()
                    
                    ForEach(cat.options) { option in
                        NavigationLink(destination: option.view.wrappedValue, isActive: option.active) {
                            HStack {
                                Image(systemName: option.icon.wrappedValue)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.blue)
                                Text(option.title.wrappedValue)
                                    .padding(.horizontal, 8)
                            }
                        }
                    }
                }
            }
            .frame(minWidth: 300)
        }
    }
    
    struct Category: Identifiable {
        var id = UUID()
        var title: String?
        var options: [TabOption]
    }
    
    struct TabOption: Identifiable {
        var id = UUID()
        var title: String
        var icon: String
        var view: AnyView
        var active: Bool = false
        
        init(id: UUID = UUID(), title: String, icon: String, view: any View, active: Bool = false) {
            self.id = id
            self.title = title
            self.icon = icon
            self.view = AnyView(view)
            self.active = active
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
