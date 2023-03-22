//
//  StatusBarView.swift
//  CowabungaJailed
//
//  Created by Rory Madden on 20/3/2023.
//

import SwiftUI

struct StatusBarView: View {
    @State private var carrierText: String = ""
    @State private var carrierTextEnabled: Bool = false
    @State private var timeText: String = ""
    @State private var timeTextEnabled: Bool = false
    @State private var crumbText: String = ""
    @State private var crumbTextEnabled: Bool = false
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
    
    @State private var enableTweak = false
    @StateObject private var dataSingleton = DataSingleton.shared
    
    var body: some View {
        List {
            Group {
                HStack {
                    Image(systemName: "wifi")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                    VStack {
                        HStack {
                            Text("Status Bar")
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Toggle("Enable", isOn: $enableTweak).onChange(of: enableTweak, perform: {nv in
                                DataSingleton.shared.setTweakEnabled(.statusBar, isEnabled: nv)
                            }).onAppear(perform: {
                                enableTweak = DataSingleton.shared.isTweakEnabled(.statusBar)
                            })
                            Spacer()
                        }
                    }
                }
                Divider()
            }
            if dataSingleton.deviceAvailable {
                Group {
                    Group {
                        Toggle("Change Carrier Text", isOn: $carrierTextEnabled).onChange(of: carrierTextEnabled, perform: { nv in
                            if nv {
                                StatusManager.sharedInstance().setCarrier(carrierText)
                            } else {
                                StatusManager.sharedInstance().unsetCarrier()
                            }
                        }).onAppear(perform: {
                            carrierTextEnabled = StatusManager.sharedInstance().isCarrierOverridden()
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
                                StatusManager.sharedInstance().setCarrier(safeNv)
                            }
                        }).onAppear(perform: {
                            carrierText = StatusManager.sharedInstance().getCarrierOverride()
                        })
                        Toggle("Change Breadcrumb Text", isOn: $crumbTextEnabled).onChange(of: crumbTextEnabled, perform: { nv in
                            if nv {
                                StatusManager.sharedInstance().setCrumb(crumbText)
                            } else {
                                StatusManager.sharedInstance().unsetCrumb()
                            }
                        }).onAppear(perform: {
                            crumbTextEnabled = StatusManager.sharedInstance().isCrumbOverridden()
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
                                StatusManager.sharedInstance().setCrumb(safeNv)
                            }
                        }).onAppear(perform: {
                            crumbText = StatusManager.sharedInstance().getCrumbOverride()
                        })
                        Toggle("Change Status Bar Time Text", isOn: $timeTextEnabled).onChange(of: timeTextEnabled, perform: { nv in
                            if nv {
                                StatusManager.sharedInstance().setTime(timeText)
                            } else {
                                StatusManager.sharedInstance().unsetTime()
                            }
                        }).onAppear(perform: {
                            timeTextEnabled = StatusManager.sharedInstance().isTimeOverridden()
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
                                StatusManager.sharedInstance().setTime(safeNv)
                            }
                        }).onAppear(perform: {
                            timeText = StatusManager.sharedInstance().getTimeOverride()
                        })
                        Text("When set to blank on notched devices, this will display the carrier name.")
                    }
                    
                    Divider()
                    
                    Group {
                        
                        // bruh I had to add a group cause SwiftUI won't let you add more than 10 things to a view?? ok
                        Toggle("Hide Do Not Disturb", isOn: $DNDHidden).onChange(of: DNDHidden, perform: { nv in
                            StatusManager.sharedInstance().hideDND(nv)
                        }).onAppear(perform: {
                            DNDHidden = StatusManager.sharedInstance().isDNDHidden()
                        })
                        Toggle("Hide Airplane Mode", isOn: $airplaneHidden).onChange(of: airplaneHidden, perform: { nv in
                            StatusManager.sharedInstance().hideAirplane(nv)
                        }).onAppear(perform: {
                            airplaneHidden = StatusManager.sharedInstance().isAirplaneHidden()
                        })
                        Toggle("Hide Cellular*", isOn: $cellHidden).onChange(of: cellHidden, perform: { nv in
                            StatusManager.sharedInstance().hideCell(nv)
                        }).onAppear(perform: {
                            cellHidden = StatusManager.sharedInstance().isCellHidden()
                        })
                    }
                    Group {
                        Toggle("Hide Wi-Fi^", isOn: $wiFiHidden).onChange(of: wiFiHidden, perform: { nv in
                            StatusManager.sharedInstance().hideWiFi(nv)
                        }).onAppear(perform: {
                            wiFiHidden = StatusManager.sharedInstance().isWiFiHidden()
                        })
                        //                if UIDevice.current.userInterfaceIdiom != .pad {
                        Toggle("Hide Battery", isOn: $batteryHidden).onChange(of: batteryHidden, perform: { nv in
                            StatusManager.sharedInstance().hideBattery(nv)
                        }).onAppear(perform: {
                            batteryHidden = StatusManager.sharedInstance().isBatteryHidden()
                        })
                        //                }
                        Toggle("Hide Bluetooth", isOn: $bluetoothHidden).onChange(of: bluetoothHidden, perform: { nv in
                            StatusManager.sharedInstance().hideBluetooth(nv)
                        }).onAppear(perform: {
                            bluetoothHidden = StatusManager.sharedInstance().isBluetoothHidden()
                        })
                        Toggle("Hide Alarm", isOn: $alarmHidden).onChange(of: alarmHidden, perform: { nv in
                            StatusManager.sharedInstance().hideAlarm(nv)
                        }).onAppear(perform: {
                            alarmHidden = StatusManager.sharedInstance().isAlarmHidden()
                        })
                        Toggle("Hide Location", isOn: $locationHidden).onChange(of: locationHidden, perform: { nv in
                            StatusManager.sharedInstance().hideLocation(nv)
                        }).onAppear(perform: {
                            locationHidden = StatusManager.sharedInstance().isLocationHidden()
                        })
                        Toggle("Hide Rotation Lock", isOn: $rotationHidden).onChange(of: rotationHidden, perform: { nv in
                            StatusManager.sharedInstance().hideRotation(nv)
                        }).onAppear(perform: {
                            rotationHidden = StatusManager.sharedInstance().isRotationHidden()
                        })
                        Toggle("Hide AirPlay", isOn: $airPlayHidden).onChange(of: airPlayHidden, perform: { nv in
                            StatusManager.sharedInstance().hideAirPlay(nv)
                        }).onAppear(perform: {
                            airPlayHidden = StatusManager.sharedInstance().isAirPlayHidden()
                        })
                        Toggle("Hide CarPlay", isOn: $carPlayHidden).onChange(of: carPlayHidden, perform: { nv in
                            StatusManager.sharedInstance().hideCarPlay(nv)
                        }).onAppear(perform: {
                            carPlayHidden = StatusManager.sharedInstance().isCarPlayHidden()
                        })
                        Toggle("Hide VPN", isOn: $VPNHidden).onChange(of: VPNHidden, perform: { nv in
                            StatusManager.sharedInstance().hideVPN(nv)
                        }).onAppear(perform: {
                            VPNHidden = StatusManager.sharedInstance().isVPNHidden()
                        })
                        Text("*Will also hide carrier name\n^Will also hide cellular data indicator")
                    }
                }.disabled(!enableTweak)
            }
        }.disabled(!dataSingleton.deviceAvailable)
    }
}

struct StatusBarView_Previews: PreviewProvider {
    static var previews: some View {
        StatusBarView()
    }
}
