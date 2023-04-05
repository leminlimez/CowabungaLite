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
    
    @State private var batteryDetailText: String = ""
    @State private var batteryDetailEnabled: Bool = false
    
    @State private var crumbText: String = ""
    @State private var crumbTextEnabled: Bool = false
    
    @State private var batteryCapacity: Double = 0
    @State private var batteryCapacityEnabled: Bool = false
    
    @State private var wiFiStrengthBars: Double = 0
    @State private var wiFiStrengthBarsEnabled: Bool = false
    
    @State private var gsmStrengthBars: Double = 0
    @State private var gsmStrengthBarsEnabled: Bool = false
    
    @State private var displayingRawWiFiStrength: Bool = false
    @State private var displayingRawGSMStrength: Bool = false
    
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
    @State private var easterEgg = false
    @StateObject private var dataSingleton = DataSingleton.shared
    
    var body: some View {
        List {
            Group {
                HStack {
                    Image(systemName: easterEgg ? "wand.and.stars" : "wifi")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35).onTapGesture(perform: { easterEgg = !easterEgg})
                    VStack {
                        HStack {
                            Text(easterEgg ? "StatusMagic" : "Status Bar")
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
                Text("Currently only tested on iOS 15 - 16.1.2 and iOS 16.3.* - other versions, use with caution. Betas, use with caution. Have a backup.")
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
                        Toggle("Change Battery Detail Text", isOn: $batteryDetailEnabled).onChange(of: batteryDetailEnabled, perform: { nv in
                            if nv {
                                StatusManager.sharedInstance().setBatteryDetail(batteryDetailText)
                            } else {
                                StatusManager.sharedInstance().unsetBatteryDetail()
                            }
                        }).onAppear(perform: {
                            batteryDetailEnabled = StatusManager.sharedInstance().isBatteryDetailOverridden()
                        })
                        TextField("Battery Detail Text", text: $batteryDetailText).onChange(of: batteryDetailText, perform: { nv in
                            // This is important.
                            // Make sure the UTF-8 representation of the string does not exceed 150
                            // Otherwise the struct will overflow
                            var safeNv = nv
                            while safeNv.utf8CString.count > 150 {
                                safeNv = String(safeNv.prefix(safeNv.count - 1))
                            }
                            batteryDetailText = safeNv
                            if batteryDetailEnabled {
                                StatusManager.sharedInstance().setBatteryDetail(safeNv)
                            }
                        }).onAppear(perform: {
                            batteryDetailText = StatusManager.sharedInstance().getBatteryDetailOverride()
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
                    
//                    Divider()
//                    
//                    Group {
//                        Toggle("Change Battery Icon Capacity", isOn: $batteryCapacityEnabled).onChange(of: batteryCapacityEnabled, perform: { nv in
//                            if nv {
//                                StatusManager.sharedInstance().setBatteryCapacity(Int32(batteryCapacity))
//                            } else {
//                                StatusManager.sharedInstance().unsetBatteryCapacity()
//                            }
//                        }).onAppear(perform: {
//                            batteryCapacityEnabled = StatusManager.sharedInstance().isBatteryCapacityOverridden()
//                        })
//                        HStack {
//                            Text("\(Int(batteryCapacity))%")
//                                .frame(width: 125)
//                            Spacer()
//                            Slider(value: $batteryCapacity, in: 0...100, step: 1.0)
//                                .padding(.horizontal)
//                                .onChange(of: batteryCapacity) { nv in
//                                    StatusManager.sharedInstance().setBatteryCapacity(Int32(nv))
//                                }
////                                .onAppear(perform: {
////                                    batteryCapacity = StatusManager.sharedInstance().getBatteryCapacityOverride()
////                                })
//                        }
//                        
//                        Toggle("Change Wi-Fi Signal Strength Bars", isOn: $wiFiStrengthBarsEnabled).onChange(of: wiFiStrengthBarsEnabled, perform: { nv in
//                            if nv {
//                                StatusManager.sharedInstance().setWiFiSignalStrengthBars(Int32(wiFiStrengthBars))
//                            } else {
//                                StatusManager.sharedInstance().unsetWiFiSignalStrengthBars()
//                            }
//                        }).onAppear(perform: {
//                            wiFiStrengthBarsEnabled = StatusManager.sharedInstance().isWiFiSignalStrengthBarsOverridden()
//                        })
//                        HStack {
//                            Text("\(Int(wiFiStrengthBars))")
//                                .frame(width: 125)
//                            Spacer()
//                            Slider(value: $wiFiStrengthBars, in: 0...3, step: 1.0)
//                                .padding(.horizontal)
//                                .onChange(of: wiFiStrengthBars) { nv in
//                                    StatusManager.sharedInstance().setWiFiSignalStrengthBars(Int32(nv))
//                                }
////                                .onAppear(perform: {
////                                    wiFiStrengthBars = StatusManager.sharedInstance().getWiFiSignalStrengthBarsOverride()
////                                })
//                        }
//                        
//                        Toggle("Change Cellular Signal Strength Bars", isOn: $gsmStrengthBarsEnabled).onChange(of: gsmStrengthBarsEnabled, perform: { nv in
//                            if nv {
//                                StatusManager.sharedInstance().setGsmSignalStrengthBars(Int32(gsmStrengthBars))
//                            } else {
//                                StatusManager.sharedInstance().unsetGsmSignalStrengthBars()
//                            }
//                        }).onAppear(perform: {
//                            gsmStrengthBarsEnabled = StatusManager.sharedInstance().isGsmSignalStrengthBarsOverridden()
//                        })
//                        HStack {
//                            Text("\(Int(gsmStrengthBars))")
//                                .frame(width: 125)
//                            Spacer()
//                            Slider(value: $gsmStrengthBars, in: 0...4, step: 1.0)
//                                .padding(.horizontal)
//                                .onChange(of: gsmStrengthBars) { nv in
//                                    StatusManager.sharedInstance().setGsmSignalStrengthBars(Int32(nv))
//                                }
////                                .onAppear(perform: {
////                                    gsmStrengthBars = StatusManager.sharedInstance().getGsmSignalStrengthBarsOverride()
////                                })
//                        }
//                    }
                    
                    Divider()
                    
                    Group {
                        Toggle("Show Numeric Wi-Fi Strength", isOn: $displayingRawWiFiStrength).onChange(of: displayingRawWiFiStrength, perform: { nv in
                            StatusManager.sharedInstance().displayRawWifiSignal(nv)
                        }).onAppear(perform: {
                            displayingRawWiFiStrength = StatusManager.sharedInstance().isDisplayingRawWiFiSignal()
                        })
                        Toggle("Show Numeric Cellular Strength", isOn: $displayingRawGSMStrength).onChange(of: displayingRawGSMStrength, perform: { nv in
                            StatusManager.sharedInstance().displayRawGSMSignal(nv)
                        }).onAppear(perform: {
                            displayingRawGSMStrength = StatusManager.sharedInstance().isDisplayingRawGSMSignal()
                        })
                    }
                    
                    Divider()
                    
                    Group {
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
