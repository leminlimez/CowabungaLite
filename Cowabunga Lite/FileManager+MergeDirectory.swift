//
//  FileManager+MergeDirectory.swift
//  CowabungaJailed
//
//  Created by Lauren Woo on 21/4/2023.
//

import Foundation

extension FileManager {
    func mergeDirectory(at sourceURL: URL, to destinationURL: URL) throws {
        try createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
        let contents = try contentsOfDirectory(at: sourceURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        for item in contents {
            let newItemURL = destinationURL.appendingPathComponent(item.lastPathComponent)
            var isDirectory: ObjCBool = false
            if fileExists(atPath: newItemURL.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    try mergeDirectory(at: item, to: newItemURL)
                } else {
                    let newFileAttributes = try fm.attributesOfItem(atPath: newItemURL.path)
                    let oldFileAttributes = try fm.attributesOfItem(atPath: item.path)
                    if let newModifiedTime = newFileAttributes[.modificationDate] as? Date,
                       let oldModifiedTime = oldFileAttributes[.modificationDate] as? Date,
                       newModifiedTime.compare(oldModifiedTime) == .orderedAscending {
                            try removeItem(at: newItemURL)
                            try copyItem(at: item, to: newItemURL)
                    }
                }
            } else {
                try copyItem(at: item, to: newItemURL)
            }
        }
    }
}
