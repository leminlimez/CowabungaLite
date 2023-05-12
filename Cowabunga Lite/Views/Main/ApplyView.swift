//
//  ApplyView.swift
//  CowabungaJailed
//
//  Created by Rory Madden on 21/3/2023.
//

import SwiftUI

struct ApplyView: View {
    @StateObject private var logger = Logger.shared
    @StateObject private var dataSingleton = DataSingleton.shared
    @State private var canApply: Bool = true
    
    var body: some View {
        List {
            Text("1. PLEASE make sure you have made a backup beforehand JUST IN CASE.\n2. Disable Find My iPhone before applying. You may re-enable it after.\n3. Check the log after applying for any issues. It should say \"Restore Successful\" at the bottom if successful.")
            Text("Enabled tweaks: \(dataSingleton.enabledTweaks.isEmpty ? "None" : "")")
            ForEach(Array(dataSingleton.enabledTweaks), id: \.self) { tweak in
                HStack(spacing: 5) {
                    Text("•")
                        .foregroundColor(.secondary)
                    Text(tweak.rawValue)
                        .foregroundColor(.primary)
                }
            }
            
            NiceButton(text: AnyView(
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text("Apply Tweaks")
                }
            )) {
                if canApply {
                    canApply = false
                    Task {
                        applyTweaks()
                        canApply = true
                    }
                }
            }
            .disabled(!canApply)
            TextEditor(text: .constant(logger.logText))
                .font(Font.system(.body, design: .monospaced))
                .frame(height: 250)
                .lineLimit(nil)
        }.disabled(!dataSingleton.deviceAvailable)
    }
}

struct ApplyView_Previews: PreviewProvider {
    static var previews: some View {
        ApplyView()
    }
}
