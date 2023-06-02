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
        var identification: String
        var image: NSImage
        var fileLocation: URL?
        var modulesToEnable: [Int] // based on module ID
        var author: String?
    }
    
    @State private var modules: [ModuleType] = [
        .init(moduleID: 1, title: "Mute Module", fileLocation: .mute),
        .init(moduleID: 2, title: "Focus UI Module", fileLocation: .focus),
        .init(moduleID: 3, title: "Siri Spoken Notifications Module", fileLocation: .spoken)
    ]
    
    @State private var presets: [ConfigPreset] = [
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
                                Image(nsImage: preset.image.wrappedValue)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 110)
                                    .cornerRadius(10)
                                Text(preset.title.wrappedValue)
                                    .padding(.bottom, 1)
                                Text(preset.author.wrappedValue ?? " ")
                                    .font(.caption)

                                NiceButton(text: AnyView(
                                    Text(currentCC == preset.identification.wrappedValue ? "Selected" : "Select")
                                        .frame(maxWidth: .infinity)
                                ), action: {
                                    guard let filePath = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.moduleConfig.rawValue) else { return }
                                    if currentCC == preset.identification.wrappedValue {
                                        if FileManager.default.fileExists(atPath: filePath.path) {
                                            try? FileManager.default.removeItem(at: filePath)
                                        }
                                        currentCC = "None"
                                    } else {
                                        do {
                                            if let ccPlist = preset.fileLocation.wrappedValue {
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
                                                currentCC = preset.identification.wrappedValue
                                            } else {
                                                throw "No url for preset \(preset.identification.wrappedValue) found!"
                                            }
                                        } catch {
                                            currentCC = "None"
                                            print(error.localizedDescription)
                                        }
                                    }
                                }, background: currentCC == preset.identification.wrappedValue ? .blue : Color.cowGray)
                            }
                        }
                    }.onAppear {
                        do {
                            guard let filePath = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(FileLocation.moduleConfig.rawValue) else { return }
                            if FileManager.default.fileExists(atPath: filePath.path) {
                                let plistData = try Data(contentsOf: filePath)
                                let plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
                                if let pIdentifier = plist["preset-identifier"] as? [String: Any], let pID = pIdentifier["identification"] as? String {
                                    currentCC = pID
                                } else {
                                    currentCC = "None"
                                }
                            }
                        } catch {
                            currentCC = "None"
                        }
                    }
                }.disabled(!enableTweak)
                .onAppear {
                    // First, get the default cc
                    presets.removeAll()
                    presets.append(.init(title: "Default", identification: "DefaultCC", image: NSImage(imageLiteralResourceName: "DefaultCC"), fileLocation: Bundle.main.url(forResource: "DefaultCC", withExtension: ".plist"), modulesToEnable: [2]))
                    
                    // Next, get the saved cc presets
                    let presetsURL = CCManager.getPresetsFolder()
                    do {
                        for cc in try FileManager.default.contentsOfDirectory(at: presetsURL, includingPropertiesForKeys: nil) {
                            do {
                                let plistData = try Data(contentsOf: cc.appendingPathComponent("ModuleConfiguration.plist"))
                                let plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
                                if let id = plist["preset-identifiers"] as? [String: Any] {
                                    if let title = id["title"] as? String, let identification = id["identification"] as? String, let mods = id["modules"] as? [Int] {
                                        let author = id["author"] as? String
                                        presets.append(.init(title: title, identification: identification, image: NSImage(contentsOf: cc.appendingPathComponent("preview.png")) ?? NSImage(imageLiteralResourceName: "DefaultCC"), fileLocation: cc.appendingPathComponent("ModuleConfiguration.plist"), modulesToEnable: mods, author: author))
                                    } else {
                                        throw "Something was nil"
                                    }
                                } else {
                                    throw "There were no preset identifiers!"
                                }
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    } catch {
                        print("Error loading cc presets")
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
