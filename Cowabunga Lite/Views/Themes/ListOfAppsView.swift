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
    var gridItemLayout = [GridItem(.adaptive(minimum: 45))]
    
    @State var apps: [AppOption] = []
    
    @Binding var viewType: Int
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    viewType = 0
                }) {
                    Text("􀆁 Back")
                }
                .padding(5)
                Spacer()
            }
            
            ScrollView {
                LazyVGrid(columns: gridItemLayout, spacing: 10) {
                    ForEach($apps) { app in
                        VStack {
                            NavigationLink(destination: AltIconView(app: app)) {
                                if app.icon.wrappedValue != nil, let img = NSImage(data: app.icon.wrappedValue!) {
                                    Image(nsImage: img)
                                        .resizable()
                                        .frame(width: 45, height: 45)
                                } else {
                                    Rectangle()
                                        .frame(width: 45, height: 45)
                                }
                            }
                            Text(app.name.wrappedValue)
                        }
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
