//
//  AboutView.swift
//  CowabungaJailed
//
//  Created by lemin on 3/22/23.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                LinkCell(imageName: "LeminLimez", title: "LeminLimez", contribution: "Main Dev")
                LinkCell(imageName: "avangelista", title: "Avangelista", contribution: "Main Dev")
            } header: {
                Text("Credits")
            }
        }
    }
    
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
}
