//
//  DataSingleton.swift
//  CowabungaJailed
//
//  Created by Lauren Woo on 21/4/2023.
//

import Foundation

@objc class DataSingleton: NSObject, ObservableObject {
    let lastTestedVersion: String = "17.3.9"
    
    @objc static let shared = DataSingleton()
    @Published var currentDevice: Device?
    private var currentWorkspace: URL?
    @Published var enabledTweaks: Set<Tweak> = []
    @Published var deviceAvailable = false
    @Published var deviceTested = false
    
    func setTweakEnabled(_ tweak: Tweak, isEnabled: Bool) {
        if isEnabled {
            enabledTweaks.insert(tweak)
        } else {
            enabledTweaks.remove(tweak)
        }
    }
    
    func isTweakEnabled(_ tweak: Tweak) -> Bool {
        return enabledTweaks.contains(tweak)
    }
    
    func allEnabledTweaks() -> Set<Tweak> {
        return enabledTweaks
    }
    
    func isDeviceTested(_ device: Device) -> Bool {
        return lastTestedVersion.compare(device.version, options: .numeric) == .orderedDescending || lastTestedVersion.compare(device.version, options: .numeric) == .orderedSame
    }
    
    func setCurrentDevice(_ device: Device) {
        currentDevice = device
        print("set to \(device)")
        if Int(device.version.split(separator: ".")[0])! < 15 {
            deviceAvailable = false
        } else {
            if isDeviceTested(device) {
                deviceTested = true
            }
            setupWorkspaceForUUID(device.uuid)
            deviceAvailable = true
        }
        enabledTweaks.insert(.skipSetup)
    }
    
    func resetCurrentDevice() {
        currentDevice = nil
        currentWorkspace = nil
        deviceAvailable = false
        enabledTweaks.removeAll()
    }
    
    @objc func getCurrentUUID() -> String? {
        return currentDevice?.uuid
    }
    
    @objc func getCurrentVersion() -> String? {
        return currentDevice?.version
    }
    
    @objc func getCurrentName() -> String? {
        return currentDevice?.name
    }
    
    func setCurrentWorkspace(_ workspaceURL: URL) {
        currentWorkspace = workspaceURL
    }
    
    @objc func getCurrentWorkspace() -> URL? {
        return currentWorkspace
    }
}
