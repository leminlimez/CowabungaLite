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
    private var gridItemLayout = [GridItem(.adaptive(minimum: 45))]
    
    @State private var apps: [AppOption] = []
    
    var body: some View {
        VStack {
            LazyVGrid(columns: gridItemLayout, spacing: 10) {
                ForEach(apps) { app in
                    VStack {
                        Button(action: {
                            
                        }) {
                            if app.icon != nil, let img = NSImage(data: app.icon!) {
                                Image(nsImage: img)
                                    .resizable()
                                    .frame(width: 45, height: 45)
                            } else {
                                Rectangle()
                                    .frame(width: 45, height: 45)
                            }
                        }
                        Text(app.name)
                    }
                }
            }
        }
    }
    
    func grabApps() {
        let newApps = getHomeScreenAppsNew()
        for app in newApps {
            apps.append(.init(name: app.name, bundle: app.bundleId, icon: app.icon, themedIcon: app.themedIcon))
        }
    }
}
