//
//  OTAKillerView.swift
//  Cowabunga Lite
//
//  Created by lemin on 8/25/23.
//

/* 
 * MARK: DEPRICATED
 * Recent iOS updates have caused problems re enabling ota, so this has been depricated for the user's safety.
 *
 * MARK: To re-enable (not recommended):
 * - Add folder "OTAKiller" to "FileFolders/Files"
 * - Add folder "ManagedPreferencesDomain" inside of "OTAKiller"
 * - Add folder "mobile" inside of "ManagedPreferencesDomain"
 * - Add an empty plist titled "com.Apple.MobileAsset.plist" inside that "mobile" folder
 * - Re-enable "OTA Killer" tab by uncommenting the line inside of "Views/RootView.swift"
 *
 * To re-enable it for removing all tweaks and deep clean, add that same empty plist inside of the same paths in
 * "FileFolders/restore" and "FileFolders/restore-deepclean" folders.
 */

import Foundation
import SwiftUI

struct OTAKillerView: View {
    @StateObject private var logger = Logger.shared
    @StateObject private var dataSingleton = DataSingleton.shared
    
    @State private var enableTweak: Bool = false
    
    @State private var otaDisabled: Bool = false
    
    var body: some View {
        List {
            Group {
                HStack {
                    Image(systemName: "network.badge.shield.half.filled")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                    VStack {
                        HStack {
                            Text("OTA Killer")
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Toggle("Modify", isOn: $enableTweak).onChange(of: enableTweak, perform: {nv in
                                DataSingleton.shared.setTweakEnabled(.otaKiller, isEnabled: nv)
                            }).onAppear(perform: {
                                enableTweak = DataSingleton.shared.isTweakEnabled(.otaKiller)
                            })
                            Spacer()
                        }
                    }
                }
                Divider()
            }
            .hideSeparator()
            
            if dataSingleton.deviceAvailable {
                Group {
                    // MARK: OTA Killer
                    Toggle(isOn: $otaDisabled) {
                        Text("Disable OTA Updates")
                            .minimumScaleFactor(0.5)
                            .onChange(of: otaDisabled, perform: { nv in
                                MainUtils.setOTABlocked(nv)
                            })
                            .onAppear {
                                otaDisabled = MainUtils.getOTABlocked()
                            }
                    }
                }.disabled(!enableTweak)
            }
        }.disabled(!dataSingleton.deviceAvailable)
    }
}
