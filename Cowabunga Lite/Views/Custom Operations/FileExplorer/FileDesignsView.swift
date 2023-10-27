//
//  FileDesignsView.swift
//  Cowabunga Lite
//
//  Created by lemin on 9/14/23.
//

import Foundation
import SwiftUI

struct FileDesignsView: View {
    // Formatting Config
//    @State var folderSize: CGFloat = 55
    let ignoreExt: [String] = [
        "txt",
        "png",
        "jpg",
        "jpeg"
    ]
    
    // File Type
    @State var ext: String // file extension (what to overlay)
    
    var body: some View {
        VStack {
            ZStack {
                if !ignoreExt.contains(ext) {
                    Image(systemName: "doc.fill")
                        .font(.system(size: 55))
                        .padding(2)
                }
                switch ext {
                case "plist":
                    Image(systemName: "list.dash")
                        .font(.system(size: 30))
                        .padding(.top, 20)
                        .padding(2)
                        .foregroundColor(.secondary)
                        .colorInvert()
                case "txt":
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 55))
                        .padding(2)
                case "png", "jpg", "jpeg":
                    Image(systemName: "photo")
                        .font(.system(size: 55))
                        .padding(2)
                default:
                    VStack {
                        
                    }
                }
            }
        }
    }
}
