//
//  ListOfAppsView.swift
//  CowabungaJailed
//
//  Created by lemin on 4/20/23.
//

import SwiftUI

struct AppOption: Identifiable {
    var id = UUID()
    var name: String
    var bundle: String
    var icon: Data?
    var themedIcon: Data?
    var changed: Bool = false
}

struct ListOfAppsView: View {
    var gridItemLayout = [GridItem(.adaptive(minimum: 80))]
    
    @State var apps: [AppOption] = []
    
    @Binding var viewType: Int
    @Binding var currentApp: AppOption
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    viewType = 0
                }) {
                    Text("􀆁 Back")
                }
                .padding(10)
                Spacer()
                Text("App Settings")
                    .font(.title)
                Spacer()
            }
            
            ScrollView {
                LazyVGrid(columns: gridItemLayout, spacing: 10) {
                    ForEach($apps) { app in
                        NiceButton(text: AnyView(
                            VStack {
                                if app.icon.wrappedValue != nil, let img = NSImage(data: app.icon.wrappedValue!) {
                                    Image(nsImage: img)
                                        .resizable()
                                        .frame(width: 65, height: 65)
                                } else {
                                    Rectangle()
                                        .frame(width: 65, height: 65)
                                }
                                Text(app.name.wrappedValue)
                            }
                                .frame(height: 90)
                        ), action: {
                            currentApp = app.wrappedValue
                            viewType = 2
                        })
                        .padding(5)
                    }
                }
            }
        }
        .onAppear {
            // pause before using
            grabApps()
            print(apps.count)
        }
    }
    
    func grabApps() {
        let newApps = getHomeScreenAppsNew()
        for app in newApps {
            apps.append(.init(name: app.name, bundle: app.bundleId, icon: app.icon, themedIcon: app.themedIcon))
        }
    }
}
