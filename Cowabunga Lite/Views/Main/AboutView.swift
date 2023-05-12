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
                LinkCell(imageName: "avangelista", title: "Avangelista", contribution: "Main Dev")
                LinkCell(imageName: "LeminLimez", title: "LeminLimez", contribution: "Main Dev")
            } header: {
                Text("Credits")
            }
        }
    }
    
    
}
