//
//  SupervisionView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/27/23.
//

import SwiftUI

struct SupervisionView: View {
    @StateObject private var logger = Logger.shared
    @StateObject private var dataSingleton = DataSingleton.shared
    @State private var skipSetup = false
    @State private var supervisionEnabled = false
    @State private var managedCompanyName = ""
    @State private var enableTweak = false
    
    var body: some View {
        List {
            Group {
                HStack {
                    Image(systemName: "gear")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                    VStack {
                        HStack {
                            Text("Setup Options")
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
            .hideSeparator()
            
            if dataSingleton.deviceAvailable {
                Group {
                    // MARK: Skipping Setup
                    Toggle("Skip Setup (recommended)", isOn: $skipSetup).onChange(of: skipSetup, perform: { nv in
                        MainUtils.setSkipSetup(nv)
                    }).onAppear(perform: {
                        skipSetup = MainUtils.getSkipSetupEnabled()
                    })
                    
                    // MARK: Supervision
                    Toggle("Enable Supervision", isOn: $supervisionEnabled).onChange(of: supervisionEnabled, perform: { nv in
                        MainUtils.setSupervision(nv)
                    }).onAppear(perform: {
                        supervisionEnabled = MainUtils.getSupervisionEnabled()
                    })
                    TextField("Organization Name", text: $managedCompanyName).onChange(of: managedCompanyName, perform: { nv in
                        MainUtils.setOrganizationName(nv)
                    }).onAppear(perform: {
                        managedCompanyName = MainUtils.getOrganizationName()
                    })
                }.disabled(!enableTweak)
                    .hideSeparator()
            }
        }.disabled(!dataSingleton.deviceAvailable)
    }
}

struct SupervisionView_Previews: PreviewProvider {
    static var previews: some View {
        SupervisionView()
    }
}
