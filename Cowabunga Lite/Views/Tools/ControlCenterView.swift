//
//  ControlCenterView.swift
//  Cowabunga Lite
//
//  Created by lemin on 5/12/23.
//

import SwiftUI

struct ControlCenterView: View {
    @State private var enableTweak = false
    @StateObject private var dataSingleton = DataSingleton.shared
    
    enum FileLocation: String {
        case mute = "SpringboardOptions/ManagedPreferencesDomain/mobile/com.apple.control-center.MuteModule.plist"
        case focus = "SpringboardOptions/ManagedPreferencesDomain/mobile/com.apple.FocusUIModule.plist"
        case spoken = "SpringboardOptions/ManagedPreferencesDomain/mobile/com.apple.siri.SpokenNotificationsModule.plist"
    }
    
    private struct ModuleType: Identifiable {
        var id = UUID()
        var title: String
        var fileLocation: FileLocation
        var value: Bool = false
    }
    
    @State private var modules: [ModuleType] = [
        .init(title: "Mute Module", fileLocation: .mute),
        .init(title: "Focus UI Module", fileLocation: .focus),
        .init(title: "Siri Spoken Notifications Module", fileLocation: .spoken)
    ]
    
    var body: some View {
        List {
            Group {
                HStack {
                    Image(systemName: "switch.2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                    VStack {
                        HStack {
                            Text("Control Center")
                                .bold()
                            ZStack {
                                Rectangle()
                                    .cornerRadius(50)
                                    .foregroundColor(.blue)
                                Text("Beta")
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        HStack {
                            Toggle("Enable", isOn: $enableTweak).onChange(of: enableTweak, perform: {nv in
                                DataSingleton.shared.setTweakEnabled(.controlCenter, isEnabled: nv)
                            }).onAppear(perform: {
                                enableTweak = DataSingleton.shared.isTweakEnabled(.controlCenter)
                            })
                            Spacer()
                        }
                    }
                }
                Divider()
            }
            
            Group {
                HStack {
                    Text("Warning!")
                        .bold()
                    Spacer()
                }
                HStack{
                    Text("Enabling this tweak resets your current layout and enabled modules.")
                    Spacer()
                }
                HStack {
                    Text("For now:")
                        .bold()
                    Spacer()
                }
                HStack {
                    Text("You must go into Settings and organize them manually.")
                    Spacer()
                }
                Divider()
            }
            
            if dataSingleton.deviceAvailable {
                Group {
                    ForEach($modules) { module in
                        Toggle(isOn: module.value) {
                            Text(module.title.wrappedValue)
                                .minimumScaleFactor(0.5)
                        }.onChange(of: module.value.wrappedValue) { new in
                            do {
                                guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(module.fileLocation.wrappedValue.rawValue) else {
                                    Logger.shared.logMe("Error finding springboard plist \(module.fileLocation.wrappedValue.rawValue)")
                                    return
                                }
                                try PlistManager.setPlistValues(url: plistURL, values: [
                                    "SBIconVisibility": module.value.wrappedValue
                                ])
                            } catch {
                                Logger.shared.logMe(error.localizedDescription)
                                return
                            }
                        }
                        .onAppear {
                            do {
                                guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(module.fileLocation.wrappedValue.rawValue) else {
                                    Logger.shared.logMe("Error finding springboard plist \(module.fileLocation.wrappedValue.rawValue)")
                                    return
                                }
                                module.value.wrappedValue =  try PlistManager.getPlistValues(url: plistURL, key: "SBIconVisibility") as? Bool ?? false
                            } catch {
                                Logger.shared.logMe("Error finding springboard plist \(module.fileLocation.wrappedValue.rawValue)")
                                return
                            }
                        }
                    }
                }
            }
        }.disabled(!dataSingleton.deviceAvailable)
    }
}

struct ControlCenterView_Previews: PreviewProvider {
    static var previews: some View {
        ControlCenterView()
    }
}
