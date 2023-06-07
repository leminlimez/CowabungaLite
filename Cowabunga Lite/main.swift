//
//  CLI_Only.swift
//  CowabungaCLI
//
//  Created by lemin on 6/1/2023.
//

/* Page Keys:
- springboard
- internal
- setup
*/

/* Page-Specific keys:
- springboard:
    - LockScreenFootnote: string
    - AnimationSpeed: double
    - AirdropEveryone: bool
    - ShowWiFiDebugger: bool
*/

import Foundation

print()
CLI_Pages.printLogo()
print("Loading...")

let dataSingleton = DataSingleton.shared
var devices = getDevices()
var selectedDeviceIndex = 0

if devices.isEmpty {
    print("No device connected. Please connect your device and try again.")
    let _ = readLine()
    exit(1)
} else if dataSingleton.deviceAvailable, let index = devices.firstIndex(where: { $0.uuid == dataSingleton.getCurrentUUID() }) {
    selectedDeviceIndex = index
} else {
    DataSingleton.shared.setCurrentDevice(devices[0])
}

MainUtils.loadPreferences()

while true {
    print("\u{001B}[2J")
    CLI_Pages.printLogo()
    print("Version 1.0 beta 1")
    if dataSingleton.currentDevice?.name != nil {
        print("Current Device: \(dataSingleton.currentDevice?.name ?? "ERROR GETTING DEVICE NAME")")
        print("iOS \(dataSingleton.currentDevice?.version ?? "ERROR DETERMINING VERSION")")
        if (dataSingleton.currentDevice?.uuid != nil) {
            if (!DataSingleton.shared.deviceAvailable) {
                print("Not Supported.")
            } else {
                if (!DataSingleton.shared.deviceTested) {
                    print("Untested.")
                } else {
                    print("Supported!")
                }
            }
        }
    }

    print("")

    print("Pages:")
    print()
    var p = 1
    for page in CLI_Pages.Pages {
        print("(\(p)) \(DataSingleton.shared.isTweakEnabled(page.tweak) ? "✓ " : "")\(page.title)")
        p += 1
    }
    print()
    print("(\(p)) Apply")
    p += 1
    print("(\(p)) Quit")
    print()
    print("Enter a number to go to that page.")
    
    if let inp = readLine(), let n = Int(inp) {
        if n <= CLI_Pages.Pages.count {
            CLI_Pages.activatePage(CLI_Pages.Pages[n-1])
        } else if n == p-1 {
            // Apply
            print("\u{001B}[2J")
            CLI_Pages.printLogo()
            print("Enabled Tweaks:")
            for tweak in DataSingleton.shared.enabledTweaks {
                print("• \(tweak.rawValue)")
            }
            print()
            print("(Y) Confirm")
            print("(N) Cancel")
            if let choice = readLine() {
                if choice == "Y" {
                    applyTweaks()
                    let _ = readLine()
                    break
                }
            }
        } else if n == p {
            // Quit
            break
        }
    }
}
exit(0)
