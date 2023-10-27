//
//  Version.swift
//  Cowabunga Lite
//
//  Created by lemin on 9/22/23.
//

import Foundation

class Version {
    let major: Int
    let minor: Int
    let patch: Int
    
    public var description: String {
        var ver = "\(major)"
        if minor > 0 || patch > 0 {
            ver = "\(ver).\(minor)"
            if patch > 0 {
                ver = "\(ver).\(patch)"
            }
        }
        return ver
    }
    
    init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    init(ver: String) {
        let splitted = ver.split(separator: ".")
        self.major = Int(splitted[0]) ?? 1
        self.minor = Int(splitted[1]) ?? 0
        self.patch = Int(splitted[2]) ?? 0
    }
    
    public func equals(_ other: Version) -> Bool {
        return (major == other.major) && (minor == other.major) && (patch == other.patch)
    }
    
    public func compareTo(_ other: Version) -> Int {
        // compare major first
        if major > other.major {
            return 1
        } else if major < other.major {
            return -1
        }
        // compare minor second
        if minor > other.minor {
            return 1
        } else if minor < other.minor {
            return -1
        }
        // compare patch last
        if patch > other.patch {
            return 1
        } else if patch < other.patch {
            return -1
        }
        return 0
    }
}
