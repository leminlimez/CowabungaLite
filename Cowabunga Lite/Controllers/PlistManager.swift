//
//  PlistManager.swift
//  CowabungaJailed
//
//  Created by lemin on 3/20/23.
//

import Foundation

class PlistManager {
    public static func setDictValue(_ dict: [String: Any], key: String, value: Any) -> [String: Any] {
        var newDict = dict
        for (k, v) in dict {
            if k == key {
                newDict[k] = value
            } else if let 🗿 = v as? [String: Any] {
                newDict[k] = setDictValue(🗿, key: key, value: value)
            }
        }
        return newDict
    }
    
    // MARK: Setting Plist Values
    
    // Set plist values from a dictionary (returns as dictionary)
    public static func setPlistValues(plist: [String: Any], values: [String: Any], replacing: Bool = false) -> [String: Any] {
        var newPlist = plist
        for (k, v) in values {
            if replacing == true {
                newPlist = setDictValue(plist, key: k, value: v)
            } else {
                newPlist[k] = v
            }
        }
        return newPlist
    }
    
    // Set plist values from data (returns as data)
    public static func setPlistValues(data: Data, values: [String: Any], replacing: Bool = false) throws -> Data {
        let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: Any]
        return try PropertyListSerialization.data(fromPropertyList: setPlistValues(plist: plist, values: values, replacing: replacing), format: .xml, options: 0)
    }
    
    // Set plist values from file url
    public static func setPlistValues(url: URL, values: [String: Any], replacing: Bool = false) throws {
        if var plist = NSDictionary(contentsOf: url) as? [String:Any] {
            plist = setPlistValues(plist: plist, values: values, replacing: replacing)
            (plist as NSDictionary).write(to: url, atomically: true)
        } else {
            var plist = try Data(contentsOf: url)
            plist = try setPlistValues(data: plist, values: values, replacing: replacing)
            try plist.write(to: url)
        }
    }
    
    // MARK: Getting Plist Values
    public static func getPlistValues(url: URL, key: String) throws -> Any? {
//        guard let plistURL = DataSingleton.shared.getCurrentWorkspace()?.appendingPathComponent(path) else {
//            throw "Error finding plist"
//        }
        if let plist = NSDictionary(contentsOf: url) as? [String:Any] {
            return plist[key]
        } else {
            let plistData = try Data(contentsOf: url)
            let plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
            return plist[key]
        }
        
    }
}
