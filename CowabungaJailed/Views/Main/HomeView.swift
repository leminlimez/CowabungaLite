//
//  ContentView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/16/23.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
            VStack {
                HStack {
                    Image(systemName: "iphone")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                    VStack {
                        HStack {
                            Text("Huawei P30 Pro")
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Text("iOS 15.4.1")
                            Text("Supported!")
                                .foregroundColor(.green)
                            Spacer()
                        }
                    }
                }
                .padding(.bottom, 5)
                List {
                    Text("Console stuff")
                        .foregroundColor(.secondary)
                }
                .cornerRadius(12)
                .padding(5)
                .padding(.bottom, 10)
                
                Button(action: {
                    
                }) {
                    Text("Apply")
                }
            }
            .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
