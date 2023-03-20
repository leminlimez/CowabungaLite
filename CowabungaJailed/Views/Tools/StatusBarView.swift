//
//  StatusBarView.swift
//  CowabungaJailed
//
//  Created by Rory Madden on 20/3/2023.
//

import SwiftUI

struct StatusBarView: View {
    @Environment(\.openURL) var openURL
    
    @State private var carrierText: String = ""
    @State private var carrierTextEnabled: Bool = false
    @State private var timeText: String = ""
    @State private var timeTextEnabled: Bool = false
    @State private var crumbText: String = ""
    @State private var crumbTextEnabled: Bool = false
    @State private var clockHidden: Bool = false
    @State private var DNDHidden: Bool = false
    @State private var airplaneHidden: Bool = false
    @State private var cellHidden: Bool = false
    @State private var wiFiHidden: Bool = false
    @State private var batteryHidden: Bool = false
    @State private var bluetoothHidden: Bool = false
    @State private var alarmHidden: Bool = false
    @State private var locationHidden: Bool = false
    @State private var rotationHidden: Bool = false
    @State private var airPlayHidden: Bool = false
    @State private var carPlayHidden: Bool = false
    @State private var VPNHidden: Bool = false
    
    var body: some View {
        List {
            Group {
                Toggle("Change Carrier Text", isOn: $carrierTextEnabled).onChange(of: carrierTextEnabled, perform: { nv in
                    if nv {
                    } else {
                    }
                })
                TextField("Carrier Text", text: $carrierText).onChange(of: carrierText, perform: { nv in
                    // This is important.
                    // Make sure the UTF-8 representation of the string does not exceed 100
                    // Otherwise the struct will overflow
                    var safeNv = nv
                    while safeNv.utf8CString.count > 100 {
                        safeNv = String(safeNv.prefix(safeNv.count - 1))
                    }
                    carrierText = safeNv
                    if carrierTextEnabled {
                    }
                })
                Toggle("Change Breadcrumb Text", isOn: $crumbTextEnabled).onChange(of: crumbTextEnabled, perform: { nv in
                    if nv {
                    } else {
                    }
                })
                TextField("Breadcrumb Text", text: $crumbText).onChange(of: crumbText, perform: { nv in
                    // This is important.
                    // Make sure the UTF-8 representation of the string does not exceed 256
                    // Otherwise the struct will overflow
                    var safeNv = nv
                    while (safeNv + " ▶").utf8CString.count > 256 {
                        safeNv = String(safeNv.prefix(safeNv.count - 1))
                    }
                    crumbText = safeNv
                    if crumbTextEnabled {
                    }
                })
                Toggle("Change Status Bar Time Text", isOn: $timeTextEnabled).onChange(of: timeTextEnabled, perform: { nv in
                    if nv {
                    } else {
                    }
                })
                TextField("Status Bar Time Text", text: $timeText).onChange(of: timeText, perform: { nv in
                    // This is important.
                    // Make sure the UTF-8 representation of the string does not exceed 64
                    // Otherwise the struct will overflow
                    var safeNv = nv
                    while safeNv.utf8CString.count > 64 {
                        safeNv = String(safeNv.prefix(safeNv.count - 1))
                    }
                    timeText = safeNv
                    if timeTextEnabled {
                    }
                })
                
                Text("When set to blank on notched devices, this will display the carrier name.")
            }
            
            Divider()
            
            Group {
                
                // bruh I had to add a group cause SwiftUI won't let you add more than 10 things to a view?? ok
                Toggle("Hide Do Not Disturb", isOn: $DNDHidden).onChange(of: DNDHidden, perform: { nv in
                })
                Toggle("Hide Airplane Mode", isOn: $airplaneHidden).onChange(of: airplaneHidden, perform: { nv in
                })
                Toggle("Hide Cellular*", isOn: $cellHidden).onChange(of: cellHidden, perform: { nv in
                })
            }
            Group {
                Toggle("Hide Wi-Fi^", isOn: $wiFiHidden).onChange(of: wiFiHidden, perform: { nv in
                })
                //                        if UIDevice.current.userInterfaceIdiom != .pad {
                Toggle("Hide Battery", isOn: $batteryHidden).onChange(of: batteryHidden, perform: { nv in
                })
                //                        }
                Toggle("Hide Bluetooth", isOn: $bluetoothHidden).onChange(of: bluetoothHidden, perform: { nv in
                })
                Toggle("Hide Alarm", isOn: $alarmHidden).onChange(of: alarmHidden, perform: { nv in
                })
                Toggle("Hide Location", isOn: $locationHidden).onChange(of: locationHidden, perform: { nv in
                })
                Toggle("Hide Rotation Lock", isOn: $rotationHidden).onChange(of: rotationHidden, perform: { nv in
                })
                Toggle("Hide AirPlay", isOn: $airPlayHidden).onChange(of: airPlayHidden, perform: { nv in
                })
                Toggle("Hide CarPlay", isOn: $carPlayHidden).onChange(of: carPlayHidden, perform: { nv in
                })
                Toggle("Hide VPN", isOn: $VPNHidden).onChange(of: VPNHidden, perform: { nv in
                })
                Text("*Will also hide carrier name\n^Will also hide cellular data indicator")
            }
        }
    }
}

struct StatusBarView_Previews: PreviewProvider {
    static var previews: some View {
        StatusBarView()
    }
}
