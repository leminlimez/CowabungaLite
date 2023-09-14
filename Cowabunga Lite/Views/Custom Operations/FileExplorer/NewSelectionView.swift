//
//  NewSelectionView.swift
//  Cowabunga Lite
//
//  Created by lemin on 9/13/23.
//

import Foundation
import SwiftUI

enum NewType {
    case domain
    case file
}

// ask users what type of file they want to add
struct NewSelectionView: View {
    var gridItemLayout = [GridItem(.adaptive(minimum: 90))]
    @Binding var newType: NewType
    @State var fileTypes: [String] = []
    
    @Binding var showingPopover: Bool
    @Binding var newTypeName: String
    
    var body: some View {
        VStack {
            // MARK: Title
            Text(newType == .domain ? "Common Domain Names" : "Common File Types")
                .font(.title)
            
            Divider()
            
            ScrollView {
                LazyVGrid(columns: gridItemLayout, spacing: 10) {
                    ForEach(fileTypes, id: \.self) { fileType in
                        VStack {
                            if newType == .domain {
                                // MARK: Folder Icon
                                NiceButton(text: AnyView(
                                    VStack {
                                        Image(systemName: "folder.fill")
                                            .font(.system(size: 55))
                                            .foregroundColor(.blue)
                                            .padding(2)
                                    }
                                        .frame(width: 70, height: 70)
                                ), action: {
                                    if fileType == "Other" {
                                        newTypeName = "New Domain"
                                    } else {
                                        newTypeName = fileType
                                    }
                                    showingPopover = false
                                }, background: .cowGray.opacity(0), clickOpacity: 0)
                            } else {
                                // MARK: File Icon
                                NiceButton(text: AnyView(
                                    VStack {
                                        FileDesignsView(ext: fileType)
                                    }
                                        .frame(width: 70, height: 70)
                                ), action: {
                                    newTypeName = fileType
                                    showingPopover = false
                                }, background: .cowGray.opacity(0), clickOpacity: 0)
                            }
                            // MARK: Type Name
                            Text(fileType)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
        }
        .padding(5)
        .onAppear {
            if newType == .domain {
                fileTypes = [
                    "HomeDomain",
                    "ManagedPreferencesDomain",
                    "SystemPreferencesDomain",
                    "Other"
                ]
            } else {
                fileTypes = [
                    "plist",
                    "txt"
                ]
            }
        }
        .frame(minWidth: 450, minHeight: 300)
    }
}
