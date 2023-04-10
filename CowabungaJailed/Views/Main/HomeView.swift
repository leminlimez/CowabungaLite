//
//  ContentView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/16/23.
//

import SwiftUI

struct LinkCell: View {
    var imageName: String
    var url: String? = nil
    var title: String
    var contribution: String
    var systemImage: Bool = false
    @Environment(\.openURL) var openURL
    
    var body: some View {
        NiceButton(text: AnyView(
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
                .cornerRadius(.infinity)
                .frame(width: 24, height: 24)
                Text(title).fontWeight(.bold)
                Text(contribution).foregroundColor(.secondary)
            }.padding(0)
        ), action: {
            if let url = url {
                openURL(URL(string: url)!)
            }
        })
    }
}

struct HomeView: View {
    @State var patronNames: [String] = []
    
    @State private var logger = Logger.shared
    @StateObject private var dataSingleton = DataSingleton.shared
    
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
                            Text(dataSingleton.currentDevice?.name ?? "No Device")
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Text(dataSingleton.currentDevice?.version ?? "Please connect a device.")
                            if (dataSingleton.currentDevice?.uuid != nil) {
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
                HStack {
                    LinkCell(imageName: "avangelista", url: "https://github.com/Avangelista", title: "Avangelista", contribution: "Main Dev")
                    LinkCell(imageName: "LeminLimez", url: "https://github.com/leminlimez", title: "LeminLimez", contribution: "Main Dev")
                }
                Divider()
                Text("Thanks to our Patrons:")
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4), spacing: 10) {
                    ForEach(patronNames.indices, id: \.self) { index in
                        Text(patronNames[index]).id(index)
                    }
                }
                .onAppear(perform: {
                    if let filePath = Bundle.main.path(forResource: "patreon", ofType: "txt") {
                        do {
                            let fileContents = try String(contentsOfFile: filePath)
                            print(fileContents)
                            patronNames = fileContents.components(separatedBy: .newlines).filter{ !$0.isEmpty }
                        } catch {
                            print("Error reading file: \(error.localizedDescription)")
                        }
                    }
                })
                Divider()
                Text("Cowabunga Lite - Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
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
