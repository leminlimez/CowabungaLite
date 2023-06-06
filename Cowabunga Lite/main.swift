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
print("""
   ___                 _                          _    _ _          ___ _    ___ 
  / __|_____ __ ____ _| |__ _  _ _ _  __ _ __ _  | |  (_) |_ ___   / __| |  |_ _|
 | (__/ _ \\ V  V / _` | '_ \\ || | ' \\/ _` / _` | | |__| |  _/ -_) | (__| |__ | | 
  \\___\\___/\\_/\\_/\\__,_|_.__/\\_,_|_||_\\__, \\__,_| |____|_|\\__\\___|  \\___|____|___|
                                     |___/                                       

""")
print("Loading...")

let dataSingleton = DataSingleton.shared
var devices = getDevices()
var selectedDeviceIndex = 0

if devices.isEmpty {
    print("No device connected. Please connect your device and try again.")
    exit(1)
} else if dataSingleton.deviceAvailable, let index = devices.firstIndex(where: { $0.uuid == dataSingleton.getCurrentUUID() }) {
    selectedDeviceIndex = index
} else {
    DataSingleton.shared.setCurrentDevice(devices[0])
}

MainUtils.loadPreferences()

while true {
    print("\u{001B}[2J")
    print("""
       ___                 _                          _    _ _          ___ _    ___
      / __|_____ __ ____ _| |__ _  _ _ _  __ _ __ _  | |  (_) |_ ___   / __| |  |_ _|
     | (__/ _ \\ V  V / _` | '_ \\ || | ' \\/ _` / _` | | |__| |  _/ -_) | (__| |__ | |
      \\___\\___/\\_/\\_/\\__,_|_.__/\\_,_|_||_\\__, \\__,_| |____|_|\\__\\___|  \\___|____|___|
                                         |___/

    """)
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
        print("\(p)) \(DataSingleton.shared.isTweakEnabled(page.tweak) ? "✓ " : "")\(page.title)")
        p += 1
    }
    print()
    print("\(p)) Apply")
    p += 1
    print("\(p)) Quit")
    print()
    print("Enter a number to go to that page.")
    
    if let inp = readLine(), let n = Int(inp) {
        if n <= CLI_Pages.Pages.count {
            CLI_Pages.activatePage(CLI_Pages.Pages[n-1])
        } else if n == p-1 {
            // Apply
        } else if n == p {
            // Quit
            break
        }
    }
}
exit(0)
