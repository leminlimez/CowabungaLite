//
//  RootView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/16/23.
//

import SwiftUI

struct RootView: View {
    @StateObject private var dataSingleton = DataSingleton.shared
    @State private var devices: [Device]?
    @State private var selectedDeviceIndex = 0
    
    @State private var options: [Category] = [
        .init(options: [
            .init(title: "Home", icon: "house", view: HomeView(), active: true),
//            .init(title: "About", icon: "info.circle", view: AboutView()), // to change later
            .init(title: "Explore", icon: "safari", view: ThemesExploreView()),
//            .init(title: "Appabetical", icon: "rectangle.2.swap", view: AppabeticalView())
        ]),
        
        // Tools View
        .init(title: "Tools", options: [
            .init(tweak: .themes, title: "Icon Theming", icon: "paintbrush", view: IconThemingMainView()),
            .init(tweak: .statusBar, title: "Status Bar", icon: "wifi", view: StatusBarView()),
//            .init(tweak: .footnote, title: "Lock Screen Footnote", icon: "platter.filled.bottom.iphone", view: LockScreenFootnoteView()),
            .init(tweak: .springboardOptions, title: "Springboard Options", icon: "app.badge", view: SpringboardOptionsView()),
            .init(tweak: .skipSetup, title: "Setup Options", icon: "gear", view: SupervisionView()),
//            .init(tweak: .testing, title: "Testing Tweaks", icon: "testtube.2", view: TestingView())
        ]),
        
        // Apply
        .init(options: [
            .init(title: "Apply", icon: "checkmark.circle", view: ApplyView())
        ])
    ]
    
    func updateDevices() {
        devices = getDevices()
        if let devices = devices {
            if devices.isEmpty {
                selectedDeviceIndex = 0
                DataSingleton.shared.resetCurrentDevice()
            } else if dataSingleton.deviceAvailable, let index = devices.firstIndex(where: { $0.uuid == dataSingleton.getCurrentUUID() }) {
                selectedDeviceIndex = index
            } else {
                DataSingleton.shared.setCurrentDevice(devices[0])
            }
        }
        // Return to Home view
        options[0].options[0].active = true
        for i in 1..<options.count {
            for j in 0..<options[i].options.count {
                options[i].options[j].active = false
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                HStack {
                    Picker(selection: $selectedDeviceIndex, label: Image(systemName: dataSingleton.currentDevice?.ipad == true ? "ipad" : "iphone")) {
                        if let devices = devices {
                            if devices.isEmpty {
                                Text("None").tag(0)
                            } else {
                                ForEach(0..<devices.count, id: \.self) { index in
                                    Text("\(devices[index].name) (\(devices[index].version))")
                                }
                            }
                        } else {
                            Text("Loading...")
                        }
                    }.onAppear {
                        updateDevices()
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                            updateDevices()
                        }
                    }.onChange(of: selectedDeviceIndex) { nv in
                        if let devices = devices {
                            DataSingleton.shared.setCurrentDevice(devices[nv])
                        } else {
                            DataSingleton.shared.resetCurrentDevice()
                        }
                        updateDevices()
                    }
                    if let devices = devices {
                        if devices.isEmpty {
                            ProgressView()
                                .scaleEffect(0.6)
                        }
                    }
                    
//                    Button(action: {
//                        updateDevices()
//                    }) {
//                        Image(systemName: "arrow.clockwise")
//                    }
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
                                Text(option.title.wrappedValue)
                                    .padding(.horizontal, 8)
                                if (dataSingleton.enabledTweaks.contains(option.tweak.wrappedValue)) {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 10, height: 10)
                                }
                            }
                        }
                    }
                }
            }
            .frame(minWidth: 300)
        }
        .onAppear {
            updateDevices()
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
        var tweak: Tweak
        
        init(tweak: Tweak = .none, title: String, icon: String, view: any View, active: Bool = false) {
            self.title = title
            self.icon = icon
            self.view = AnyView(view)
            self.active = active
            self.tweak = tweak
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
