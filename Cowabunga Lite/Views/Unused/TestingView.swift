//
//  TestingView.swift
//  Cowabunga Lite
//
//  Created by lemin on 5/5/23.
//

import SwiftUI

struct TestingView: View {
    @State private var enableTweak = false
    @StateObject private var dataSingleton = DataSingleton.shared
    
    var body: some View {
        List {
            Group {
                HStack {
                    Image(systemName: "testtube.2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                    VStack {
                        HStack {
                            Text("Testing Tweaks (Real)")
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Toggle("Modify", isOn: $enableTweak).onChange(of: enableTweak, perform: {nv in
                                DataSingleton.shared.setTweakEnabled(.testing, isEnabled: nv)
                            }).onAppear(perform: {
                                enableTweak = DataSingleton.shared.isTweakEnabled(.testing)
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

struct TestingView_Previews: PreviewProvider {
    static var previews: some View {
        TestingView()
    }
}
