//
//  DiskPersonalizationHandler.swift
//  Cowabunga Lite
//
//  Created by lemin on 9/23/23.
//

import Foundation
import CryptoKit

class DiskPersonalizationHandler {
    static let shared = DiskPersonalizationHandler()
    
    // MARK: Query Personalization Manifest
    func queryPersonalizationIdentifiers(propListServiceHandle: PropertyListServiceClientHandle) throws -> [String: Any] {
        let plist = LibiMobileDevice.Instance.Plist
        let plistHandle = plist.plist_new_dict()
        
        do {
            plist.plist_dict_set_item(plistHandle, "Command", plist.plist_new_string("QueryPersonalizationIdentifiers"))
            return try sendRecvPlist(propListServiceHandle: propListServiceHandle, plist: plistHandle)
        } finally {
            plistHandle.close()
        }
    }
    
    // MARK: Obtain/Request Manifest
    public func obtainManifest(url: URL) throws {
        var manifest: [String: Any]
        do {
            // first try to obtain it
            let imageStream = try FileHandle(forReadingFrom: url.appendingPathComponent("Image.dmg"))
            let hash = SHA384.hash(data: imageStream.readDataToEndOfFile())
            manifest = try QueryPersonalizationManifest(propListServiceHandle, "DeveloperDiskImage", hash)
        } catch {
            // does not exist, request it
        }
    }
}
