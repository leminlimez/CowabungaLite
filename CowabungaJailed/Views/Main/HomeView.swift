//
//  ContentView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/16/23.
//

import SwiftUI

struct HomeView: View {
    @State private var logger = Logger.shared
    
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
                TextEditor(text: $logger.logText).font(Font.system(.body, design: .monospaced)).frame(height: 250).disabled(true)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
