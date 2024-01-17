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
    
    private let keyCombination = ["up", "up", "down", "down", "left", "right", "left", "right", "b", "a", "space"]
    @State private var currentKeyOrder = -1
    @State private var showBootloopButton: Bool = false
    
    @Namespace var logID
    
    @State private var testNum: Int = 1
    
    var body: some View {
        List {
            if dataSingleton.deviceAvailable && (dataSingleton.currentDevice?.version ?? "15").compare("17.2", options: .numeric) == .orderedDescending {
                MitigationBanner()
                    .hideSeparator()
                Divider()
            }
            
            Text("1. PLEASE make sure you have made a backup beforehand JUST IN CASE.\n2. Disable Find My iPhone before applying. You may re-enable it after.\n3. Check the log after applying for any issues. It should say \"Restore Successful\" at the bottom if successful.")
                .hideSeparator()
            Text("If you get error 205 relating to downloading files, try setting your device's language to English temporarily.")
                .hideSeparator()
            Text("Enabled tweaks: \(dataSingleton.enabledTweaks.isEmpty ? "None" : "")")
                .hideSeparator()
            ForEach(Array(dataSingleton.enabledTweaks), id: \.self) { tweak in
                HStack(spacing: 5) {
                    Text("•")
                        .foregroundColor(.secondary)
                    Text(tweak.rawValue)
                        .foregroundColor(.primary)
                }
                .hideSeparator()
            }
            
            HStack {
                HStack {
                    // MARK: Regular Apply Button
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
                    // MARK: Remove All Tweaks
                    NiceButton(text: AnyView(
                        HStack {
                            Image(systemName: "trash")
                            Text("Remove All Tweaks")
                        }
                    )) {
                        if canApply {
                            canApply = false
                            Task {
                                removeTweaks(deepClean: false)
                                canApply = true
                            }
                        }
                    }
                    // MARK: Deep Clean
                    NiceButton(text: AnyView(
                        HStack {
                            Image(systemName: "paintbrush")
                            Text("Deep Clean")
                        }
                    )) {
                        if canApply {
                            canApply = false
                            Task {
                                removeTweaks(deepClean: true)
                                canApply = true
                            }
                        }
                    }
                }.disabled(!canApply)
                
                // MARK: Copy Log
                NiceButton(text: AnyView(
                    HStack {
                        Image(systemName: "clipboard")
                        Text("Copy Logs")
                    }
                )) {
                    // save to clipboard
                    let pasteboard = NSPasteboard.general
                    pasteboard.declareTypes([.string], owner: nil)
                    pasteboard.setString(logger.logText, forType: .string)
                }
                
                // MARK: Bootloop Button
                if showBootloopButton {
                    NiceButton(text: AnyView(
                        HStack {
                            Image(systemName: "apple.logo")
                            Text("Bootloop Device")
                                .foregroundColor(.red)
                        }
                    ), action: {
                        if canApply {
                            canApply = false
                            Task {
                                bootloopDevice()
                                canApply = true
                            }
                        }
                    })
                }
                
                // Test button
//                NiceButton(text: AnyView(
//                    Text("Test console")
//                )) {
//                    var toAdd: String = ""
//                    for i in 0...4 {
//                        if i != 0 {
//                            toAdd += "\n"
//                        }
//                        toAdd += "test \(testNum)"
//                        testNum += 1
//                    }
//                    Logger.shared.logMe(toAdd)//"test \(testNum)")
//                }
            }
            .hideSeparator()
            
            if #available(macOS 12, *) {
                ZStack {
                    ZStack {
                        Button(action: {
                            handleKeyPress("up")
                        }) {}.keyboardShortcut(.upArrow, modifiers: [])
                        Button(action: {
                            handleKeyPress("down")
                        }) {}.keyboardShortcut(.downArrow, modifiers: [])
                        Button(action: {
                            handleKeyPress("left")
                        }) {}.keyboardShortcut(.leftArrow, modifiers: [])
                        Button(action: {
                            handleKeyPress("right")
                        }) {}.keyboardShortcut(.rightArrow, modifiers: [])
                        Button(action: {
                            handleKeyPress("b")
                        }) {}.keyboardShortcut(.init("b"), modifiers: [])
                        Button(action: {
                            handleKeyPress("a")
                        }) {}.keyboardShortcut(.init("a"), modifiers: [])
                        Button(action: {
                            handleKeyPress("space")
                        }) {}.keyboardShortcut(.space, modifiers: [])
                    }
                    .opacity(0)
                    .onAppear {
                        currentKeyOrder = -1
                        showBootloopButton = false
                    }
                    GeometryReader { proxy1 in
                        ScrollViewReader { reader in
                            ScrollView {
                                Text(logger.logText)
                                    .id(logID)
                                    .font(Font.system(.body, design: .monospaced))
                                    .frame(minWidth: 0,
                                           maxWidth: .infinity,
                                           minHeight: 0,
                                           maxHeight: .infinity,
                                           alignment: .topLeading)
                                    .textSelection(.enabled)
                                    .onChange(of: logger.logText) { nv in
                                        reader.scrollTo(logID, anchor: .bottom)
                                    }
                                    .onAppear {
                                        reader.scrollTo(logID, anchor: .bottom)
                                    }
                            }
                        }
                    }
                }
                .frame(height: 250)
            } else {
                TextEditor(text: .constant(logger.logText))
                    .font(Font.system(.body, design: .monospaced))
                    .frame(height: 250)
                    .lineLimit(nil)
            }
        }.disabled(!dataSingleton.deviceAvailable)
            .hideSeparator()
    }
    
    struct MitigationBanner: View {
        var body: some View {
            HStack {
                VStack {
                    HStack {
                        Image(systemName: "info.circle")
                            .padding(.trailing, 5)
                            .foregroundColor(.blue)
                            .font(.title)
                        Text("Warning:")
                            .bold()
                        Text("Apple added new mitigations in iOS 17.2. Please read the following:")
                        Spacer()
                    }
                    .padding(.bottom, 2)
                    HStack {
                        Image(systemName: "info.circle")
                            .padding(.trailing, 5)
                            .font(.title)
                            .opacity(0)
                        Text("If you see a screen that says \"iPhone Partially Set Up\", DO NOT tap the big blue button. You must click \"Continue with Partial Setup\"")
                        Spacer()
                    }
                }
            }
        }
    }
    
    func handleKeyPress(_ k: String) {
        if !showBootloopButton {
            if currentKeyOrder + 1 >= 0 && currentKeyOrder + 1 < keyCombination.count && keyCombination[currentKeyOrder + 1] == k {
                currentKeyOrder = currentKeyOrder + 1
                if currentKeyOrder + 1 >= keyCombination.count {
                    showBootloopButton = true
                }
                return
            }
        }
        currentKeyOrder = -1
    }
}

struct ApplyView_Previews: PreviewProvider {
    static var previews: some View {
        ApplyView()
    }
}
