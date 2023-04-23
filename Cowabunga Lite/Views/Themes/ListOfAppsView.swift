//
//  ListOfAppsView.swift
//  CowabungaJailed
//
//  Created by lemin on 4/20/23.
//

import SwiftUI

struct ListOfAppsView: View {
    struct AppOption: Identifiable {
        var id = UUID()
        var name: String
        var bundle: String
        var icon: String // TODO: Needs type
        var changed: Bool = false
    }
    
    @State private var apps: [AppOption] = []
    
    var body: some View {
        VStack {
            
        }
    }
}
