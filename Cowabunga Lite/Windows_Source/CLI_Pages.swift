//
//  CLI_Pages.swift
//  
//
//  Created by lemin on 6/6/23.
//

import Foundation

class CLI_Pages {
    // Configuration
    static let back: String = "0"
    
    struct Page: Identifiable {
        var id = UUID()
        var title: String
        var tweak: Tweak
    }
    
    public static let Pages: [Page] = [
        .init(title: "Control Center", tweak: .controlCenter),
        .init(title: "Springboard Options", tweak: .springboardOptions),
        .init(title: "Internal Options", tweak: .internalOptions),
        .init(title: "Setup Options", tweak: .skipSetup)
    ]

    public static func printLogo() {
        clearConsole()
        print("""
   ___                 _                          _    _ _          ___ _    ___ 
  / __|_____ __ ____ _| |__ _  _ _ _  __ _ __ _  | |  (_) |_ ___   / __| |  |_ _|
 | (__/ _ \\ V  V / _` | '_ \\ || | ' \\/ _` / _` | | |__| |  _/ -_) | (__| |__ | | 
  \\___\\___/\\_/\\_/\\__,_|_.__/\\_,_|_||_\\__, \\__,_| |____|_|\\__\\___|  \\___|____|___|
                                     |___/                                       

""")
    }
    
    public static func clearConsole() {
//        print("\u{001B}[2J") // doesn't work in Windows terminal
        print(" ", terminator: Array(repeating: "\n", count: 50).joined())
    }
    
    public static func activatePage(_ page: Page) {
        var inPage: Bool = true
        while inPage {
            printLogo()
            let tweakEnabled: Bool = DataSingleton.shared.isTweakEnabled(page.tweak)
            print("\(page.title) (\(tweakEnabled ? "Enabled" : "Disabled"))")
            print("Enter '\(tweakEnabled ? "D" : "E")' to \(tweakEnabled ? "Disable" : "Enable")")
            print()
            if page.tweak == .controlCenter {
                inPage = controlCenter()
            } else if page.tweak == .springboardOptions {
                inPage = springboardOptions()
            } else if page.tweak == .internalOptions {
                inPage = internalOptions()
            } else if page.tweak == .skipSetup {
                inPage = skipSetup()
            } else {
                inPage = false
            }
        }
    }
    
    // MARK: Page Presets
    // Toggles
    public static func printToggle(for opt: MainUtils.ToggleOption, _ i: Int) {
        print("(\(i)) \(opt.value ? "✓" : "☐") \(opt.name): \(opt.value)")
    }
    
    
    // MARK: Page-Specific Functions


    // MARK: TOOL PAGES
    
    // MARK: Control Center
    public static func controlCenter() -> Bool {
        // Toggles
        var i = 1
        for opt in MainUtils.moduleTypes {
            printToggle(for: opt, i)
            i += 1
        }
        print()
        print("(\(i)) Selected CC Preset: \(MainUtils.selectedCCPreset)")
        print()
        print("(\(back)) Back")
        print()
        if let choice = readLine() {
            if choice.uppercased() == "E" {
                if !DataSingleton.shared.isTweakEnabled(.controlCenter) {
                    DataSingleton.shared.setTweakEnabled(.controlCenter, isEnabled: true)
                }
            } else if choice.uppercased() == "D"{
                if DataSingleton.shared.isTweakEnabled(.controlCenter) {
                    DataSingleton.shared.setTweakEnabled(.controlCenter, isEnabled: false)
                }
            } else if choice.uppercased() == back {
                return false
            } else if let n = Int(choice) {
                if n == i {
                    print()
                    for (j, preset) in MainUtils.ccPresets.enumerated() {
                        print("(\(j+1)) \(MainUtils.selectedCCPreset == preset.identification ? "✓ " : "") \(preset.title)")
                    }
                    print("(\(back)) Cancel")
                    print()
                    print("Select new preset: ")
                    if let newPreset = readLine() {
                        if newPreset.uppercased() != back {
                            if let presetID = Int(newPreset) {
                                if presetID > 0 && presetID <= MainUtils.ccPresets.count {
                                    MainUtils.setCCPreset(MainUtils.ccPresets[presetID-1])
                                }
                            }
                        }
                    }
                } else if n <= MainUtils.sbOptions.count {
                    MainUtils.setModuleVisibility(key: n, !MainUtils.moduleTypes[n-1].value)
                }
            }
        }
        return true
    }
    
    // MARK: Springboard Options
    public static func springboardOptions() -> Bool {
        // Toggles
        var i = 1
        for opt in MainUtils.sbOptions {
            printToggle(for: opt, i)
            i += 1
        }
        print()
        print("(\(i)) UI Animation Speed: \(String(format: "%.2f", MainUtils.sbAnimationSpeed)) (\(MainUtils.sbAnimationSpeed == 1 ? "Default" : (MainUtils.sbAnimationSpeed < 1 ? "Fast" : "Slow")))")
        i += 1
        print("(\(i)) Lock Screen Footnote Text: \(MainUtils.sbLockScreenFootnote)")
        i += 1
        print()
        print("(\(back)) Back")
        print()
        if let choice = readLine() {
            if choice.uppercased() == "E" {
                if !DataSingleton.shared.isTweakEnabled(.springboardOptions) {
                    DataSingleton.shared.setTweakEnabled(.springboardOptions, isEnabled: true)
                }
            } else if choice.uppercased() == "D"{
                if DataSingleton.shared.isTweakEnabled(.springboardOptions) {
                    DataSingleton.shared.setTweakEnabled(.springboardOptions, isEnabled: false)
                }
            } else if choice.uppercased() == back {
                return false
            } else if let n = Int(choice) {
                if n == i-1 {
                    // Lock Screen Footnote
                    print()
                    print("Enter New Lock Screen Footnote Text: ")
                    if let nv = readLine() {
                        MainUtils.setLockScreenFootnote(nv)
                    }
                } else if n == i-2 {
                    // UI Animation Speed
                    print()
                    print("Enter New Animation Speed (0.1 to 2.0): ")
                    if let nv = readLine(), let ns = Double(nv) {
                        if ns >= 0.1 && ns <= 2 {
                            MainUtils.setAnimationSpeed(ns)
                        }
                    }
                } else {
                    if n <= MainUtils.sbOptions.count {
                        MainUtils.applyToggle(index: n-1, value: !MainUtils.sbOptions[n-1].value, tweak: .springboardOptions)
                    }
                }
            }
        }
        return true
    }

    // MARK: Internal Options
    public static func internalOptions() -> Bool {
        // Toggles
        var i = 1
        for opt in MainUtils.internalOptions {
            printToggle(for: opt, i)
            if opt.dividerBelow {
                print()
            }
            i += 1
        }
        print()
        print("(\(back)) Back")
        print()
        if let choice = readLine() {
            if choice.uppercased() == "E" {
                if !DataSingleton.shared.isTweakEnabled(.internalOptions) {
                    DataSingleton.shared.setTweakEnabled(.internalOptions, isEnabled: true)
                }
            } else if choice.uppercased() == "D"{
                if DataSingleton.shared.isTweakEnabled(.internalOptions) {
                    DataSingleton.shared.setTweakEnabled(.internalOptions, isEnabled: false)
                }
            } else if choice.uppercased() == back {
                return false
            } else if let n = Int(choice) {
                if n <= MainUtils.internalOptions.count {
                    MainUtils.applyToggle(index: n-1, value: !MainUtils.internalOptions[n-1].value, tweak: .internalOptions)
                }
            }
        }
        return true
    }

    // MARK: Setup Options
    public static func skipSetup() -> Bool {
        // Toggles
        var i = 1
        for opt in MainUtils.skipSetupOptions {
            printToggle(for: opt, i)
            i += 1
        }
        print("(\(i)) Organization Name: \(MainUtils.skipSetupOrganizationName)")
        i += 1
        print()
        print("(\(back)) Back")
        print()
        if let choice = readLine() {
            if choice.uppercased() == "E" {
                if !DataSingleton.shared.isTweakEnabled(.skipSetup) {
                    DataSingleton.shared.setTweakEnabled(.skipSetup, isEnabled: true)
                }
            } else if choice.uppercased() == "D"{
                if DataSingleton.shared.isTweakEnabled(.skipSetup) {
                    DataSingleton.shared.setTweakEnabled(.skipSetup, isEnabled: false)
                }
            } else if choice.uppercased() == back {
                return false
            } else if let n = Int(choice) {
                if n == i-1 {
                    print()
                    print("Enter New Organization Name: ")
                    if let nv = readLine() {
                        MainUtils.setOrganizationName(nv)
                    }
                } else {
                    if n <= MainUtils.skipSetupOptions.count {
                        let nv = !MainUtils.skipSetupOptions[n-1].value
                        MainUtils.skipSetupOptions[n-1].value = nv
                        let key = MainUtils.skipSetupOptions[n-1].key
                        if key == "Skip" {
                            MainUtils.setSkipSetup(nv)
                        } else if key == "OTA" {
                            MainUtils.setOTABlocked(nv)
                        } else if key == "Supervision" {
                            MainUtils.setSupervision(nv)
                        }
                    }
                }
            }
        }
        return true
    }
}
