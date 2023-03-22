//
//  SpringboardOptionsView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/22/23.
//

import Foundation
import SwiftUI

struct SpringboardOptionsView: View {
    @StateObject private var logger = Logger.shared
    @StateObject private var dataSingleton = DataSingleton.shared
    @State private var enableTweak: Bool = false
    
    struct SBOption: Identifiable {
        var id = UUID()
        var key: String
        var name: String
        var imageName: String
        var value: Bool = false
    }
    
    @State private var sbOptions: [SBOption] = [
        .init(key: "SBDontLockAfterCrash", name: "Don't lock after respring", imageName: "lock.open"),
        .init(key: "SBDontDimOrLockOnAC", name: "Don't dim when charging", imageName: "battery.100.bolt"),
        .init(key: "SBHideLowPowerAlerts", name: "No Low Battery alerts", imageName: "battery.25"),
        .init(key: "SBDisableHomeButton", name: "Disable Home Button", imageName: "iphone.homebutton"),
        .init(key: "SBDontLockEver", name: "Disable Lock Button", imageName: "lock.square"),
        .init(key: "SBDisableNotificationCenterBlur", name: "Disable Notif Center Blur", imageName: "app.badge"),
        .init(key: "SBControlCenterEnabledInLockScreen", name: "Lock Screen CC", imageName: "square.grid.2x2"),
        .init(key: "SBControlCenterDemo", name: "CC AirPlay Radar", imageName: "wifi.circle")
    ]
    
    var body: some View {
        List {
            Group {
                HStack {
                    Image(systemName: "snowflake")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                    VStack {
                        HStack {
                            Text("Springboard Options")
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Toggle("Enable", isOn: $enableTweak).onChange(of: enableTweak, perform: {nv in
                                DataSingleton.shared.setTweakEnabled(.springboardOptions, isEnabled: nv)
                            }).onAppear(perform: {
                                enableTweak = DataSingleton.shared.isTweakEnabled(.springboardOptions)
                            })
                            Spacer()
                        }
                    }
                }
                Divider()
                if dataSingleton.deviceAvailable {
                    Group {
                        ForEach($sbOptions) { option in
                            HStack {
//                                Image(systemName: option.imageName.wrappedValue)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 24, height: 24)
//                                    .foregroundColor(.blue)
                                Toggle(isOn: option.value) {
                                    Text(option.name.wrappedValue)
                                        .minimumScaleFactor(0.5)
                                }.onChange(of: option.value.wrappedValue) { new in
                                    do {
                                        guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent("SpringboardOptions/HomeDomain/Library/Preferences/com.apple.SpringBoard.plist") else {
                                            Logger.shared.logMe("Error finding springboard plist")
                                            return
                                        }
                                        try PlistManager.setPlistValues(url: plistURL, values: [
                                            option.key.wrappedValue: option.value.wrappedValue
                                        ])
                                    } catch {
                                        Logger.shared.logMe(error.localizedDescription)
                                        return
                                    }
                                }
                                .onAppear {
                                    do {
                                        option.value.wrappedValue =  try PlistManager.getPlistValues(path: "SpringboardOptions/HomeDomain/Library/Preferences/com.apple.SpringBoard.plist", key: option.key.wrappedValue) as? Bool ?? false
                                    } catch {
                                        Logger.shared.logMe("Error finding springboard plist")
                                        return
                                    }
                                }
                                .padding(.leading, 10)
                            }
                        }
                    }
                }
            }.disabled(!dataSingleton.deviceAvailable)
        }
    }
}
