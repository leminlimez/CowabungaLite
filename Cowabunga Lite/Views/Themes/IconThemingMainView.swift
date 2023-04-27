//
//  IconThemingMainView.swift
//  Cowabunga Lite
//
//  Created by lemin on 4/27/23.
//

import SwiftUI

struct IconThemingMainView: View {
    @State var viewType: Int = 0
    
    var body: some View {
        VStack {
            if viewType == 0 {
                ThemingView(viewType: $viewType)
            } else if viewType == 1 {
                ListOfAppsView(viewType: $viewType)
            }
        }.onAppear {
            viewType = 0
        }
    }
}

struct IconThemingMainView_Previews: PreviewProvider {
    static var previews: some View {
        IconThemingMainView()
    }
}
