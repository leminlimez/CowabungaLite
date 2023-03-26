//
//  ThemingView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/24/23.
//

import SwiftUI

struct ThemingView: View {
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
                            Text("Icon Theming")
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Toggle("Enable", isOn: $enableTweak).onChange(of: enableTweak, perform: {nv in
                                DataSingleton.shared.setTweakEnabled(.themes, isEnabled: nv)
                            }).onAppear(perform: {
                                enableTweak = DataSingleton.shared.isTweakEnabled(.themes)
                            })
                            Spacer()
                        }
                    }
                }
                Divider()
            }
            if dataSingleton.deviceAvailable {
                HStack {
                    Button("Apply Test Theme", action: {
                        try? ThemingManager.applyTheme(themeName: "Test")
                    })
                    Button("Remove Applied Theme", action: {
                        ThemingManager.eraseAppliedTheme()
                    })
                }
            }
        }.disabled(!dataSingleton.deviceAvailable)
    }
}

struct ThemingView_Previews: PreviewProvider {
    static var previews: some View {
        ThemingView()
    }
}
