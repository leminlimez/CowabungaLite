//
//  OperationsMainView.swift
//  Cowabunga Lite
//
//  Created by lemin on 7/21/23.
//

import SwiftUI

struct OperationsMainView: View {
    @State var viewType: Int = 0
    @State var currentOperation: AdvancedObject = .init(name: "")
    @State var currentPath: String = ""
    
    var body: some View {
        VStack {
            if viewType == 0 {
                CustomOperationsView(viewType: $viewType, currentOperation: $currentOperation)
            } else if viewType == 1 {
                EditingOperationView(viewType: $viewType, operation: $currentOperation, currentPath: $currentPath)
            } else if viewType == 2 {
                FileExplorerView(viewType: $viewType, operation: $currentOperation, currentPath: $currentPath)
            }
        }.onAppear {
            viewType = 0
            currentOperation = .init(name: "")
            currentPath = ""
        }
    }
}

struct OperationsMainView_Previews: PreviewProvider {
    static var previews: some View {
        OperationsMainView()
    }
}
