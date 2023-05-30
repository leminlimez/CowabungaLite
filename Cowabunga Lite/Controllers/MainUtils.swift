//
//  MainUtils.swift
//  Cowabunga Lite
//
//  Created by lemin on 5/29/23.
//

import Foundation

class MainUtils {
    enum FileLocation: String {
        // Springboard Options
        case springboard = "SpringboardOptions/ManagedPreferencesDomain/mobile/com.apple.springboard.plist"
        case footnote = "SpringboardOptions/SysSharedContainerDomain-systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/SharedDeviceConfiguration.plist"
        case wifi = "SpringboardOptions/SystemPreferencesDomain/SystemConfiguration/com.apple.wifi.plist"
        case uikit = "SpringboardOptions/HomeDomain/Library/Preferences/com.apple.UIKit.plist"
        case accessibility = "SpringboardOptions/HomeDomain/Library/Preferences/com.apple.Accessibility.plist"
        case wifiDebug = "SpringboardOptions/ManagedPreferencesDomain/mobile/com.apple.MobileWiFi.debug.plist"
        
        // Internal Options
        case globalPreferences = "InternalOptions/ManagedPreferencesDomain/mobile/hiddendotGlobalPreferences.plist"
        case appStore = "InternalOptions/HomeDomain/Library/Preferences/com.apple.AppStore.plist"
        case notes = "InternalOptions/HomeDomain/Library/Preferences/com.apple.mobilenotes.plist"
        case maps = "InternalOptions/AppDomain-com.apple.Maps/Library/Preferences/com.apple.Maps.plist"
        case weather = "InternalOptions/AppDomain-com.apple.weather/Library/Preferences/com.apple.weather.plist"
    }
}
