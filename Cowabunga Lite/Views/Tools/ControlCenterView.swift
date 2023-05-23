//
//  ControlCenterView.swift
//  Cowabunga Lite
//
//  Created by lemin on 5/12/23.
//

import SwiftUI

struct ControlCenterView: View {
    @State private var enableTweak = false
    @State private var currentCC: String = "None"
    @StateObject private var dataSingleton = DataSingleton.shared
    
    var gridItemLayout = [GridItem(.adaptive(minimum: 110))]
    
    enum FileLocation: String {
        case mute = "ControlCenter/ManagedPreferencesDomain/mobile/com.apple.control-center.MuteModule.plist"
        case focus = "ControlCenter/ManagedPreferencesDomain/mobile/com.apple.FocusUIModule.plist"
        case spoken = "ControlCenter/ManagedPreferencesDomain/mobile/com.apple.siri.SpokenNotificationsModule.plist"
        case moduleConfig = "ControlCenter/HomeDomain/Library/ControlCenter/ModuleConfiguration.plist"
    }
    
    private struct ModuleType: Identifiable {
        var id = UUID()
        var moduleID: Int
        var title: String
        var fileLocation: FileLocation
        var value: Bool = false
    }
    
    private struct ConfigPreset: Identifiable {
        var id = UUID()
        var title: String
        var imageName: String
        var fileName: String
        var modulesToEnable: [Int] // based on module ID
        var author: String?
    }
    
    @State private var modules: [ModuleType] = [
        .init(moduleID: 1, title: "Mute Module", fileLocation: .mute),
        .init(moduleID: 2, title: "Focus UI Module", fileLocation: .focus),
        .init(moduleID: 3, title: "Siri Spoken Notifications Module", fileLocation: .spoken)
    ]
    
    @State private var presets: [ConfigPreset] = [
        .init(title: "Default", imageName: "DefaultCC", fileName: "DefaultCC", modulesToEnable: [2]),
        .init(title: "Stylistic", imageName: "StylisticCC", fileName: "StylisticCC", modulesToEnable: [1, 2], author: "@LeminLimez"),
        .init(title: "CC Module++", imageName: "CCModulePlusPlus", fileName: "CCModulePlusPlus", modulesToEnable: [1, 2, 3], author: "@iTechExpert21")
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
                                    .frame(maxWidth: 50)
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
            
            if dataSingleton.deviceAvailable {
                Group {
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
                                    Logger.shared.logMe("Error finding cc plist \(module.fileLocation.wrappedValue.rawValue)")
                                    return
                                }
                                module.value.wrappedValue =  try PlistManager.getPlistValues(url: plistURL, key: "SBIconVisibility") as? Bool ?? false
                            } catch {
                                Logger.shared.logMe("Error finding cc plist \(module.fileLocation.wrappedValue.rawValue)")
                                return
                            }
                        }
                    }
                    
                    Divider()
                    
                    Text("Presets")
                        .bold()
                    
                    LazyVGrid(columns: gridItemLayout, spacing: 10) {
                        ForEach($presets) { preset in
                            VStack {
                                Image(preset.imageName.wrappedValue)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 110)
                                    .cornerRadius(10)
                                Text(preset.title.wrappedValue)
                                    .padding(.bottom, 1)
                                Text(preset.author.wrappedValue ?? " ")
                                    .font(.caption)
                                
                                NiceButton(text: AnyView(
                                    Text(currentCC == preset.fileName.wrappedValue ? "Selected" : "Select")
                                        .frame(maxWidth: .infinity)
                                ), action: {
                                    guard let filePath = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.moduleConfig.rawValue) else { return }
                                    if currentCC == preset.fileName.wrappedValue {
                                        if FileManager.default.fileExists(atPath: filePath.path) {
                                            try? FileManager.default.removeItem(at: filePath)
                                        }
                                        currentCC = "None"
                                    } else {
                                        do {
                                            if let ccPlist = Bundle.main.url(forResource: preset.fileName.wrappedValue, withExtension: "plist") {
                                                let ccData = try Data(contentsOf: ccPlist)
                                                try ccData.write(to: filePath)
                                                // enable the modules associated with it
                                                // kinda slow but it works
                                                for module in preset.modulesToEnable.wrappedValue {
                                                    for (i, mod) in modules.enumerated() {
                                                        if mod.moduleID == module {
                                                            modules[i].value = true
                                                            continue
                                                        }
                                                    }
                                                }
                                                currentCC = preset.fileName.wrappedValue
                                            } else {
                                                throw "No bundle for resource \(preset.fileName.wrappedValue) found!"
                                            }
                                        } catch {
                                            currentCC = "None"
                                            print(error.localizedDescription)
                                        }
                                    }
                                }, background: currentCC == preset.fileName.wrappedValue ? .blue : Color.cowGray)
                            }
                        }
                    }.onAppear {
                        do {
                            guard let filePath = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.moduleConfig.rawValue) else { return }
                            if FileManager.default.fileExists(atPath: filePath.path) {
                                let plistData = try Data(contentsOf: filePath)
                                let plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
                                if let pIdentifier = plist["preset-identifier"] as? String {
                                    currentCC = pIdentifier
                                } else {
                                    currentCC = "None"
                                }
                            }
                        } catch {
                            currentCC = "None"
                        }
                    }
                }.disabled(!enableTweak)
            }
        }.disabled(!dataSingleton.deviceAvailable)
    }
}

struct ControlCenterView_Previews: PreviewProvider {
    static var previews: some View {
        ControlCenterView()
    }
}
