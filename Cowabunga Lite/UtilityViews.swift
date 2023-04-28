//
//  UtilityViews.swift
//  CowabungaJailed
//
//  Created by Rory Madden on 28/3/2023.
//

import Foundation
import SwiftUI

// MARK: Color Extension
extension Color {
    static var cowGray:Color {
        return Color(hue: 0, saturation: 0, brightness: 0.7, opacity: 0.2)
    }
}

// MARK: Nice Button Struct
struct NiceButton: View {
    var text: AnyView
    var action: () -> ()
    var padding: CGFloat = 10
    var background: Color = .cowGray
    @State private var isTapped = false
    
    var body: some View {
        Button(action: {
            self.isTapped = true
            withAnimation {
                self.isTapped = false
            }
            self.action()
        }) {
            self.text
                .padding(EdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding))
        }
        .background(self.background)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .background(isTapped ? Color(hue: 0, saturation: 0, brightness: 0.7, opacity: 0.2) : Color(hue: 0, saturation: 0, brightness: 0, opacity: 0))
                .foregroundColor(Color(hue: 0, saturation: 0, brightness: 0, opacity: 0))
        )
        .cornerRadius(8)
        .buttonStyle(BorderlessButtonStyle())
        .foregroundColor(.primary)
    }
}
