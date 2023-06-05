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

while true {
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
    print("""

    1) Springboard Options
    2) Internal Options
    3) Setup Options
    4) Apply
    5) Quit

    Type in a number to go to that page.
    """)
    break
    if let inp = readLine() {
        if inp == "5" {
            break
        }
        else if inp == "1" {
            // MARK: Springboard Options Page
            var i = 1
            for opt in MainUtils.sbOptions {
                print("\(i). \(opt.name): \(opt.value)")
                i += 1
            }
            print("\(i). Back")
            if let choice = readLine() {
                if Int(choice) ?? -1 == i {
                    exit(0)
                }
            }
        }
    }
}
exit(0)