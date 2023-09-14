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
    var circle: Bool = true
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
                .cornerRadius(circle ? .infinity : 0)
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

struct PersonCredit: View {
    var imageName: String
    var name: String
    var contribution: String
    var links: [String: String] // example keys: "github", "twitter", "donations"
    var circle: Bool = false
    @Environment(\.openURL) var openURL
    
    var body: some View {
//        let keys = links.map{$0.key}
        let keys = ["github", "twitter", "donations"]
        HStack {
            // image
            Group {
                if imageName != "" {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .cornerRadius(circle ? .infinity : 0)
            .frame(width: 24, height: 24)
            
            // name
            HStack {
                Text(name)
                Spacer()
            }
            .frame(width: 90)
                
            
            // social buttons
            HStack {
                ForEach(keys.indices, id: \.self) { index in
                    if index != 0 {
                        Divider()
                            .frame(width: 1)
                            .overlay(Rectangle().foregroundColor(.gray))
                    }
                    Button(action: {
                        if let url = links[keys[index]] {
                            openURL(URL(string: url)!)
                        }
                    }, label: {
                        HStack(alignment: .center) {
                            Group {
                                if keys[index] == "donations" {
                                    Image(systemName: "dollarsign")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.primary)
                                } else {
                                    Image(keys[index])
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.primary)
                                }
                            }
                            .frame(width: 20, height: 20)
                        }
                    })
                    .frame(width: 23, height: 23)
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(index == 0 ? .leading : .trailing, index == 0 || index == keys.count-1 ? 10 : 0)
                    .padding(.vertical, 8)
//                    NiceButton(text: AnyView(
//
//                    ), action: {
//
//                    }, padding: 0, cornerRadii: [
//                        "TopLeft": index == 0 ? 8 : 0,
//                        "BottomLeft": index == 0 ? 8 : 0,
//                        "TopRight": index == keys.count-1 ? 8 : 0,
//                        "BottomRight": index == keys.count-1 ? 8 : 0
//                    ])
//                    .aspectRatio(1.0, contentMode: .fit)
                }
            }
            .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.gray, lineWidth: 1)
                )
            .padding(5)
            
            // contribution
            Text(contribution)
                .foregroundColor(.secondary)
                .padding(.leading, 10)
                .padding(.trailing, 5)
        }
    }
}

struct HomeView: View {
    
    @State private var versionBuildString: String?
    
    @State private var logger = Logger.shared
    @StateObject private var dataSingleton = DataSingleton.shared
    
    private var OtherCredits: [String: String] = [
        "sourcelocation": "https://twitter.com/sourceloc",
        "iTechExpert": "https://twitter.com/iTechExpert21",
        "libimobiledevice": "https://libimobiledevice.org"
    ]
    
    @State private var updateAvailable = false
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        let keys = ["libimobiledevice", "iTechExpert", "sourcelocation"]
        
        VStack {
            List {
                Group {
                    HStack {
                        if dataSingleton.currentDevice?.name != nil {
                            Image(systemName: dataSingleton.currentDevice?.ipad == true ? "ipad" : "iphone")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 35, height: 35)
                        } else {
                            Image(systemName: "iphone.slash")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 35, height: 35)
                        }
                        ZStack {
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
                                            if (!DataSingleton.shared.deviceTested) {
                                                Text("Untested.")
                                                    .foregroundColor(.yellow)
                                            } else {
                                                Text("Supported!")
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                            }
                            HStack {
                                Spacer()
                                // if update available then show button
                                if updateAvailable {
                                    LinkCell(imageName: "arrow.down.circle", url: "https://github.com/leminlimez/CowabungaLite/releases/latest", title: "Update Available", contribution: "", systemImage: true, circle: false)
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    Group {
                        HStack {
                            Spacer()
                            
                            // App Icon Goes Here
                            Image("cowliteicon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 150)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                            
                            VStack {
                                // title
                                HStack {
                                    Text("Cowabunga Lite")
                                        .bold()
                                        .font(.largeTitle)
                                        .padding(.trailing, 10)
                                    Spacer()
                                }
                                
                                // github button
                                HStack {
                                    LinkCell(imageName: "star", url: "https://github.com/leminlimez/CowabungaLite", title: "Star the Project on GitHub", contribution: "", systemImage: true, circle: false)
                                    Spacer()
                                }
                                
                                // discord button
                                HStack {
                                    LinkCell(imageName: "discord.fill", url: "https://discord.gg/Cowabunga", title: "Join the Discord", contribution: "", circle: false)
                                    Spacer()
                                }
                            }
                            .frame(width: 250)
                            
                            Spacer()
                        }
                    }
                    
                    Group {
                        // Important Credits and Links
                        PersonCredit(imageName: "LeminLimez", name: "LeminLimez", contribution: "Main Mac Developer, Cowabunga MDC Developer", links: [
                            "github": "https://github.com/leminlimez",
                            "twitter": "https://twitter.com/LeminLimez",
                            "donations" : "https://ko-fi.com/leminlimez"
                        ], circle: true)
                        PersonCredit(imageName: "avangelista", name: "Avangelista", contribution: "Main Windows Developer, Backup Generator, App Getter", links: [
                            "github": "https://github.com/Avangelista",
                            "twitter": "https://twitter.com/AvangelistaDev",
                            "donations" : "https://ko-fi.com/avangelista"
                        ], circle: true)
                    }
                    
                    Group {
                        HStack {
                            Text("Additional Thanks")
                            // Other Credits
                            HStack {
                                ForEach(keys.indices, id: \.self) { index in
                                    if index != 0 {
                                        Divider()
                                            .frame(width: 1)
                                            .overlay(Rectangle().foregroundColor(.gray))
                                    }
                                    Button(action: {
                                        if let url = OtherCredits[keys[index]] {
                                            openURL(URL(string: url)!)
                                        }
                                    }, label: {
                                        HStack(alignment: .center) {
                                            Group {
                                                Text(keys[index])
                                            }
                                            .frame(width: 110, height: 20)
                                        }
                                    })
                                    .frame(width: 110, height: 23)
                                    .buttonStyle(BorderlessButtonStyle())
                                    .padding(index == 0 ? .leading : .trailing, index == 0 || index == keys.count-1 ? 10 : 0)
                                    .padding(.vertical, 8)
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.gray, lineWidth: 1)
                            )
                            .padding(5)
                        }
                    }
                    //                Group {
                    //                    HStack {
                    //                        LinkCell(imageName: "LeminLimez", url: "https://github.com/leminlimez", title: "LeminLimez", contribution: "Main Dev")
                    //                        LinkCell(imageName: "avangelista", url: "https://github.com/Avangelista", title: "Avangelista", contribution: "Main Dev")
                    //                    }
                    //                    HStack {
                    //                        LinkCell(imageName: "iTechExpert", url: "https://twitter.com/iTechExpert21", title: "iTech Expert", contribution: "Airdrop to Everyone, Known WiFi Networks")
                    //                    }
                    //                }
                    //                Divider()
                    //                HStack {
                    //                    LinkCell(imageName: "discord.fill", url: "https://discord.gg/Cowabunga", title: "Join the Discord", contribution: "", circle: false)
                    //                    LinkCell(imageName: "heart.fill", url: "https://patreon.com/Cowabunga_iOS", title: "Support us on Patreon", contribution: "", systemImage: true, circle: false)
                    //                }
                    //                Divider()
                    //                TextEditor(text: $logger.logText).font(Font.system(.body, design: .monospaced)).frame(height: 250).disabled(true)
                }
            }
            HStack {
                Spacer()
                Text("Cowabunga Lite Mac - Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") (\(versionBuildString ?? "Release"))")
                    .padding(.bottom, 10)
                    .padding(.trailing, 10)
            }
            .onAppear(perform: {
                if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String, build != "0" {
                    versionBuildString = "Beta \(build)"
                }
                
                checkUpdate()
            })
        }
    }
    
    func checkUpdate() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let url = URL(string: "https://api.github.com/repos/leminlimez/CowabungaLite/releases/latest") {
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data else { return }
                
                if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    if (json["tag_name"] as? String)?.replacingOccurrences(of: "v", with: "").compare(version, options: .numeric) == .orderedDescending {
                        updateAvailable = true
                    }
                }
            }
            task.resume()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
