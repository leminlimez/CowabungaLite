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
    var clickOpacity: CGFloat = 0.2
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
                .background(isTapped ? Color(hue: 0, saturation: 0, brightness: 0.7, opacity: clickOpacity) : Color(hue: 0, saturation: 0, brightness: 0, opacity: 0))
                .foregroundColor(Color(hue: 0, saturation: 0, brightness: 0, opacity: 0))
        )
        .cornerRadius(8)
        .buttonStyle(BorderlessButtonStyle())
        .foregroundColor(.primary)
    }
}

// MARK: Image Button Struct
struct ImageButton: View {
    // Required Values
    var systemName: String
    var text: String
    
    // Optional Configuration
    var hasSpacer: Bool = false
    var imageColor: Color = .primary
    var textColor: Color = .primary
    
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemName)
                    .foregroundColor(imageColor)
                Text(text)
                    .foregroundColor(textColor)
                if hasSpacer {
                    Spacer()
                }
            }
        }
    }
}

// MARK: Centered Text Struct (for Lists)
struct CenteredText: View {
    var text: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(text)
            Spacer()
        }
    }
}

// MARK: Beta Tag Struct
struct BetaTag: View {
    var body: some View {
        ZStack {
            Rectangle()
                .cornerRadius(50)
                .foregroundColor(.blue)
                .frame(maxWidth: 40, maxHeight: 20)
            Text("Beta")
                .foregroundColor(.white)
                .bold()
        }
    }
}
