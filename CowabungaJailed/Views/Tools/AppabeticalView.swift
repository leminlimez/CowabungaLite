//
//  AppabeticalView.swift
//  CowabungaJailed
//
//  Created by Rory Madden on 28/3/2023.
//

import SwiftUI

struct AppabeticalView: View {
    @StateObject private var dataSingleton = DataSingleton.shared
    @State private var pages = 1
    @State private var selectedItems: [Int] = []
    @State private var together = false
    @State private var az = true
    
    var body: some View {
        List {
            Group {
                HStack {
                    Image(systemName: "rectangle.2.swap")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                    VStack {
                        HStack {
                            Text("Appabetical")
                                .bold()
                            Spacer()
                        }
                    }
                }
                Divider()
                Text("Select Pages")
                    .onAppear(perform: {
                    pages = getHomeScreenNumPages()
                })
                ForEach(0...pages - 1, id: \.self) { item in
                    NiceButton(text: AnyView(
                        HStack {
                            Text("Page \(String(item + 1))")
                            Spacer()
                            Image(systemName: "checkmark")
                                .opacity(self.selectedItems.contains(item) ? 1.0 : 0.0)
                                .foregroundColor(.accentColor)
                                .font(.system(.headline))
                        }.frame(maxWidth: 300)),
                    action: {
                        if self.selectedItems.contains(item) {
                            self.selectedItems.removeAll(where: { $0 == item })
                        } else {
                            self.selectedItems.append(item)
                        }
                        self.selectedItems.sort()
                    })
                }
                Picker("Ordering", selection: $az) {
                    Text("A-Z").tag(true)
                    Text("Color").tag(false)
                }.frame(maxWidth: 320)
                Picker("Pages", selection: $together) {
                    Text("Sort pages independently").tag(false)
                    Text("Sort apps across pages").tag(true)
                }.frame(maxWidth: 320)
                NiceButton(text: AnyView(
                    HStack {
                        Text("Sort Apps")
                    }.frame(maxWidth: 300)
                )) {
                    
                }.disabled(selectedItems.isEmpty)
            }
        }.disabled(!dataSingleton.deviceAvailable)
    }
}

struct AppabeticalView_Previews: PreviewProvider {
    static var previews: some View {
        AppabeticalView()
    }
}
