//
//  FileExplorerMainView.swift
//  Cowabunga Lite
//
//  Created by lemin on 9/11/23.
//

import Foundation
import SwiftUI

struct FileExplorerMainView: View {
    @State var viewType2: Int = 0
    @Binding var viewType: Int
    @Binding var operation: AdvancedObject
    @Binding var currentPath: String
    
    var body: some View {
        VStack {
            if viewType2 == 0 {
                FileExplorerView(viewType: $viewType, operation: $operation, currentPath: $currentPath)
            }
        }
        .onAppear {
            viewType2 = 0
        }
    }
}
