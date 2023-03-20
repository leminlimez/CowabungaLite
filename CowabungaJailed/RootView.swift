//
//  RootView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/16/23.
//

import SwiftUI

struct RootView: View {
    @State var homeActive: Bool = true
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: HomeView(), isActive: $homeActive) {
                    HStack {
                        Image(systemName: "house")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                        Text("Home")
                            .padding(.horizontal, 8)
                    }
                }
                .padding(.vertical, 5)
                
                NavigationLink(destination: HomeView()) {
                    HStack {
                        Image(systemName: "info.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                        Text("About")
                            .padding(.horizontal, 8)
                    }
                }
                .padding(.vertical, 5)
                
                Divider()
                
                Text("Tools")
                    .foregroundColor(.secondary)
                
                NavigationLink(destination: StatusBarView()) {
                    HStack {
                        Image(systemName: "wifi")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                        Text("Status Bar")
                            .padding(.horizontal, 8)
                    }
                }
            }
            .frame(width: 150)
        }
//        TabView {
//            HomeView()
//                .tabItem {
//                    Label("Home", systemImage: "house")
//                }
//            HomeView()
//                .tabItem {
//                    Label("About", systemImage: "i.circle")
//                }
//        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
