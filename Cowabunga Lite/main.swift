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

// Configuration
let version = "1.2.0"
let build = 0

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
    CLI_Pages.printLogo()
    print("Version \(version) (\(build == 0 ? "Release" : "Beta \(build)"))")
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
    print()
    print("(0) Quit")
    print()
    print("Enter a number to go to that page.")
    
    if let inp = readLine(), let n = Int(inp) {
        if n > 0 && n <= CLI_Pages.Pages.count {
            CLI_Pages.activatePage(CLI_Pages.Pages[n-1])
        } else if n == p-1 {
            // Apply
            CLI_Pages.printLogo()
            print("Enabled Tweaks:")
            for tweak in DataSingleton.shared.enabledTweaks {
                print("• \(tweak.rawValue)")
            }
            print()
            print("(Y) Confirm")
            print("(N) Cancel")
            if let choice = readLine() {
                if choice.uppercased() == "Y" {
                    applyTweaks()
                    let _ = readLine()
                    break
                }
            }
        } else if n == 0 {
            // Quit
            break
        }
    }
}
exit(0)
