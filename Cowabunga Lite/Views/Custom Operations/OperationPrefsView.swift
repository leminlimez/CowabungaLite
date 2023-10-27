//
//  OperationPrefsView.swift
//  Cowabunga Lite
//
//  Created by lemin on 9/21/23.
//

import Foundation
import SwiftUI

//struct PlistPrefValueView: View {
//    @Binding var pref: PlistPref
//    
//    var body: some View {
//        HStack {
//            switch pref.value {
//            case .string(<#T##String#>)
//            }
//        }
//    }
//}

struct PrefOptionView: View {
    @State var pref: AdvancedOperationPref
    
    var body: some View {
        HStack {
            Text(pref.label)
                .bold()
            switch pref {
            case is PlistPref:
                HStack {
                    
                }
            default:
                HStack {
                    
                }
            }
        }
    }
}

struct OperationPrefsView: View {
    @State var operation: AdvancedObject
    @State var prefs: [AdvancedOperationPref] = []
    
    var body: some View {
        VStack {
            if prefs.count == 0 {
                Spacer()
                Text("Error: No preferences found!")
                Spacer()
            } else {
                ForEach(prefs) { pref in
                    PrefOptionView(pref: pref)
                }
            }
        }
        .padding(5)
    }
}
