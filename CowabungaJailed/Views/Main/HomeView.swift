//
//  ContentView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/16/23.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        List {
            Group {
                HStack {
                    Image(systemName: "iphone")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                    VStack {
                        HStack {
                            Text(DataSingleton.shared.getCurrentName() ?? "No Device")
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Text(DataSingleton.shared.getCurrentVersion() ?? "Please connect a device.")
                            if (DataSingleton.shared.getCurrentUUID() != nil) {
                                if (!DataSingleton.shared.deviceAvailable) {
                                    Text("Not Supported.")
                                        .foregroundColor(.red)
                                } else {
                                    Text("Supported!")
                                        .foregroundColor(.green)
                                }
                            }
                            Spacer()
                        }
                    }
                }
                Divider()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
