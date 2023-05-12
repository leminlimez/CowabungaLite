//
//  IconThemingMainView.swift
//  Cowabunga Lite
//
//  Created by lemin on 4/27/23.
//

import SwiftUI

struct IconThemingMainView: View {
    @State var viewType: Int = 0
    @State var currentApp: AppOption = .init(name: "", bundle: "")
    
    var body: some View {
        VStack {
            if viewType == 0 {
                ThemingView(viewType: $viewType)
            } else if viewType == 1 {
                ListOfAppsView(viewType: $viewType, currentApp: $currentApp)
            } else if viewType == 2 {
                AltIconView(viewType: $viewType, app: $currentApp)
            }
        }.onAppear {
            viewType = 0
            currentApp = .init(name: "", bundle: "")
        }
    }
}

struct IconThemingMainView_Previews: PreviewProvider {
    static var previews: some View {
        IconThemingMainView()
    }
}
