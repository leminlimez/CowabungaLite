//
//  SkipSetup.swift
//  CowabungaJailed
//
//  Created by Rory Madden on 22/3/2023.
//

import SwiftUI

struct SkipSetupView: View {
    @State private var enableTweak = false
    @StateObject private var dataSingleton = DataSingleton.shared
    
    var body: some View {
        List {
            Group {
                HStack {
                    Image(systemName: "gear.badge.xmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                    VStack {
                        HStack {
                            Text("Skip Setup")
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Toggle("Modify", isOn: $enableTweak).onChange(of: enableTweak, perform: {nv in
                                DataSingleton.shared.setTweakEnabled(.skipSetup, isEnabled: nv)
                            }).onAppear(perform: {
                                enableTweak = DataSingleton.shared.isTweakEnabled(.skipSetup)
                            })
                            Spacer()
                        }
                    }
                }
                Divider()
            }
        }.disabled(!dataSingleton.deviceAvailable)
    }
}

struct SkipSetupView_Previews: PreviewProvider {
    static var previews: some View {
        SkipSetupView()
    }
}
