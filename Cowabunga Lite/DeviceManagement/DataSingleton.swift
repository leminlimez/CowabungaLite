//
//  DataSingleton.swift
//  CowabungaJailed
//
//  Created by Lauren Woo on 21/4/2023.
//

import Foundation

#if CLI
class DataSingleton {
    static let shared = DataSingleton()
    public var currentDevice: Device?
    private var currentWorkspace: URL?
    public var enabledTweaks: Set<Tweak> = []
    public var deviceAvailable = false
    public var deviceTested = false

    private var lastTestedVersion: String = "16.7"

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

    func setCurrentDevice(_ device: Device) {
        currentDevice = device
        print("set to \(device)")
        if Int(device.version.split(separator: ".")[0])! < 15 {
            deviceAvailable = false
        } else {
            if lastTestedVersion.compare(device.version, options: .numeric) == .orderedDescending {
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

    func getCurrentUUID() -> String? {
        return currentDevice?.uuid
    }

    func getCurrentVersion() -> String? {
        return currentDevice?.version
    }

    func getCurrentName() -> String? {
        return currentDevice?.name
    }

    func setCurrentWorkspace(_ workspaceURL: URL) {
        currentWorkspace = workspaceURL
    }

    func getCurrentWorkspace() -> URL? {
        return currentWorkspace
    }
}
#else
@objc class DataSingleton: NSObject, ObservableObject {
    @objc static let shared = DataSingleton()
    @Published var currentDevice: Device?
    private var currentWorkspace: URL?
    @Published var enabledTweaks: Set<Tweak> = []
    @Published var deviceAvailable = false
    @Published var deviceTested = false
    
    private var lastTestedVersion: String = "16.7"
    
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
    
    func setCurrentDevice(_ device: Device) {
        currentDevice = device
        print("set to \(device)")
        if Int(device.version.split(separator: ".")[0])! < 15 {
            deviceAvailable = false
        } else {
            if lastTestedVersion.compare(device.version, options: .numeric) == .orderedDescending {
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
#endif
