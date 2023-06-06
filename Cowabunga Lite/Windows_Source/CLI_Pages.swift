//
//  CLI_Pages.swift
//  
//
//  Created by lemin on 6/6/23.
//

import Foundation

class CLI_Pages {
    struct Page: Identifiable {
        var id = UUID()
        var title: String
        var tweak: Tweak
    }
    
    public static let Pages: [Page] = [
        .init(title: "Springboard Options", tweak: .springboardOptions),
        .init(title: "Internal Options", tweak: .internalOptions),
        .init(title: "Setup Options", tweak: .skipSetup)
    ]
    
    public static func activatePage(_ page: Page) {
        var inPage: Bool = true
        while inPage {
            print("\u{001B}[2J")
            print()
            let tweakEnabled: Bool = DataSingleton.shared.isTweakEnabled(page.tweak)
            print("\(page.title) (\(tweakEnabled ? "Enabled" : "Disabled"))")
            print("Enter '\(tweakEnabled ? "D" : "E")' to \(tweakEnabled ? "Disable" : "Enable")")
            if page.tweak == .springboardOptions {
                inPage = springboardOptions()
            } else {
                inPage = false
            }
        }
    }
    
    // MARK: Page Presets
    public static func printToggle(for opt: MainUtils.ToggleOption, _ i: Int) {
        print("\(i). \(opt.value ? "✓" : "☐") \(opt.name): \(opt.value)")
    }
    
    
    // MARK: Page-Specific Functions
    
    // MARK: Springboard Options
    public static func springboardOptions() -> Bool {
        // Toggles
        var i = 1
        for opt in MainUtils.sbOptions {
            printToggle(for: opt, i)
            i += 1
        }
        print()
        print("\(i)) Back")
        print()
        if let choice = readLine() {
            if choice == "E" {
                if !DataSingleton.shared.isTweakEnabled(.springboardOptions) {
                    DataSingleton.shared.setTweakEnabled(.springboardOptions, isEnabled: true)
                }
            } else if choice == "D"{
                if DataSingleton.shared.isTweakEnabled(.springboardOptions) {
                    DataSingleton.shared.setTweakEnabled(.springboardOptions, isEnabled: false)
                }
            } else if let n = Int(choice) {
                if n == i {
                    return false
                } else {
                    if i <= MainUtils.sbOptions.count {
                        MainUtils.applyToggle(index: i-1, value: !MainUtils.sbOptions[i-1].value, tweak: .springboardOptions)
                    }
                }
            }
        }
        return true
    }
}
