//
//  OTAKillerView.swift
//  Cowabunga Lite
//
//  Created by lemin on 8/25/23.
//

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
