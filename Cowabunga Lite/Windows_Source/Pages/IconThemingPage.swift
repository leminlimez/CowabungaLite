//
//  IconThemingPage.swift
//  
//
//  Created by lemin on 6/8/23.
//

import Foundation

class IconThemingPage {
    // Separate class for organization purposes

    // MARK: Variables
    static var themeManager = WindowsThemingManager.shared

    static var hideAppLabels: Bool = false
    static var themeAllApps: Bool = false

    // MARK: Load Toggle Selection
    public static func loadPreferences() {
        themeManager.getThemes()
        themeManager.currentTheme = themeManager.getCurrentAppliedTheme()

        hideAppLabels = themeManager.getThemeToggleSetting("HideDisplayNames")
        themeAllApps = themeManager.getThemeToggleSetting("ThemeAllApps")
    }

    // MARK: Import Folder of Icons
    public static func importFolderPrompt(_ fPath: String) throws {
        // remove quotes if it starts with them
        var folderPath: String = fPath
        if fPath.starts(with: "\"") {
            folderPath = String(String(fPath.dropFirst()).dropLast())
        }
        let folderURL = URL(fileURLWithPath: folderPath)
        if FileManager.default.fileExists(atPath: folderPath) {
            // Valid folder
            try themeManager.importTheme(from: folderURL)
        } else {
            throw "Folder does not exist at path \(folderPath)"
        }
    }

    // MARK: Main View
    public static func themes() -> Bool {
        // Toggles
        print("(1) \(hideAppLabels ? "✓" : "☐") Hide App Labels")
        print("(2) \(themeAllApps ? "✓" : "☐") Theme All Apps (Includes apps not included in the selected theme)")
        print()
        print("(3) Current Theme: \(themeManager.currentTheme ?? "None")")
        print()
        print("(\(CLI_Pages.back)) Back")
        print()
        if let choice = readLine() {
            if choice.uppercased() == "E" {
                if !DataSingleton.shared.isTweakEnabled(.themes) {
                    DataSingleton.shared.setTweakEnabled(.themes, isEnabled: true)
                }
            } else if choice.uppercased() == "D"{
                if DataSingleton.shared.isTweakEnabled(.themes) {
                    DataSingleton.shared.setTweakEnabled(.themes, isEnabled: false)
                }
            } else if choice.uppercased() == CLI_Pages.back {
                return false
            } else if let n = Int(choice) {
                if n == 1 {
                    hideAppLabels = !hideAppLabels
                    try? themeManager.setThemeSettings(hideDisplayNames: hideAppLabels)
                } else if n == 2 {
                    themeAllApps = !themeAllApps
                    try? themeManager.setThemeSettings(themeAllApps: themeAllApps)
                } else if n == 3 {
                    // Icon Theming Select/Import
                    // TODO: Needs a page system and to show only 8 themes per page
                    print()
                    print("(1) Import Theme")
                    print()
                    if themeManager.themes.isEmpty {
                        print("No themes found! Please start by importing them.")
                    } else {
                        for (i, theme) in themeManager.themes.enumerated() {
                            print("(\(i+2)) \(themeManager.currentTheme == theme.name ? "✓ " : "")\(theme.name) · \(theme.iconCount)")
                        }
                    }
                    print()
                    print("(\(CLI_Pages.back)) Cancel")
                    print()
                    if let newChoice = readLine() {
                        if newChoice != CLI_Pages.back, let opt = Int(newChoice) {
                            if opt == 1 {
                                // Import Theme
                                // Probably a way to launch the explore window but idk how so ig here is this
                                print()
                                print("Enter path to folder of icons to import: ")
                                if let folderPath = readLine() {
                                    print("Importing...")
                                    do {
                                        try importFolderPrompt(folderPath)
                                    } catch {
                                        print("An error occurred while trying to import icons:")
                                        print(error.localizedDescription)
                                        print("Press enter to return to the themes page.")
                                        let _ = readLine()
                                    }
                                }
                            } else if opt > 1 && opt <= themeManager.themes.count + 1 {
                                // Select (or Deselect) That Theme
                                if themeManager.currentTheme == themeManager.themes[opt-2].name {
                                    // Remove Theme
                                    try? themeManager.setThemeSettings(deletingTheme: true)
                                } else {
                                    // Set Current Theme
                                    do {
                                        try themeManager.setThemeSettings(themeName: themeManager.themes[opt-2].name)
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return true
    }
}