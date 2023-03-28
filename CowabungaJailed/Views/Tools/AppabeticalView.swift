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
    @State private var isTapped = false

    
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
                        }),
                    action: {
                        withAnimation {
                            self.isTapped = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation {
                                self.isTapped = false
                            }
                        }
                        
                        if self.selectedItems.contains(item) {
                            self.selectedItems.removeAll(where: { $0 == item })
                        } else {
                            self.selectedItems.append(item)
                        }
                        self.selectedItems.sort()
                    })
                }
            }
        }.disabled(!dataSingleton.deviceAvailable)
    }
}

struct AppabeticalView_Previews: PreviewProvider {
    static var previews: some View {
        AppabeticalView()
    }
}
