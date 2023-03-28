//
//  ContentView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/16/23.
//

import SwiftUI

struct LinkCell: View {
    var imageName: String
    var url: String = ""
    var title: String
    var contribution: String
    var systemImage: Bool = false
    var circle: Bool = false
    
    var body: some View {
        HStack(alignment: .center) {
            Group {
                if systemImage {
                    Image(systemName: imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    if imageName != "" {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
            }
            .cornerRadius(circle ? .infinity : 0)
            .frame(width: 24, height: 24)
            
            VStack {
                HStack {
                    Button(action: {
//                            if url != "" {
//                                UIApplication.shared.open(URL(string: url)!)
//                            }
                    }) {
                        Text(title)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 6)
                    Spacer()
                }
                HStack {
                    Text(contribution)
                        .padding(.horizontal, 6)
                        .font(.footnote)
                    Spacer()
                }
            }
        }
        .foregroundColor(.blue)
    }
}

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
                LinkCell(imageName: "avangelista", title: "Avangelista", contribution: "Main Dev")
                LinkCell(imageName: "LeminLimez", title: "LeminLimez", contribution: "Main Dev")
//                TextEditor(text: $logger.logText).font(Font.system(.body, design: .monospaced)).frame(height: 250).disabled(true)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
