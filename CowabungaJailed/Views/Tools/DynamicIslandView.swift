//
//  DynamicIslandView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/20/23.
//

import SwiftUI

struct DynamicIslandView: View {
    @StateObject private var logger = Logger.shared
    @State private var enableTweak = false
    
    var body: some View {
        List {
            HStack {
                Image(systemName: "platter.filled.top.iphone")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
                VStack {
                    HStack {
                        Text("Dynamic Island")
                            .bold()
                        Spacer()
                    }
                    HStack {
                        Toggle("Enable", isOn: $enableTweak).onChange(of: enableTweak, perform: {nv in
                            DataSingleton.shared.setTweakEnabled(.dynamicIsland, isEnabled: nv)
                        }).onAppear(perform: {
                            enableTweak = DataSingleton.shared.isTweakEnabled(.dynamicIsland)
                        })
                        Spacer()
                    }
                }
            }
        }
    }
}

struct DynamicIslandView_Previews: PreviewProvider {
    static var previews: some View {
        DynamicIslandView()
    }
}
