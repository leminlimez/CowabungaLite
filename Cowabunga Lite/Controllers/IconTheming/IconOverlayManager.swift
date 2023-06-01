//
//  IconOverlayManager.swift
//  Cowabunga Lite
//
//  Created by lemin on 6/1/23.
//

import Foundation
import SwiftUI

class IconOverlayManager {
    public static func overlayIcon(_ icon: NSImage, _ overlay: NSImage) -> NSImage {
        let img = NSImage(size: icon.size)
        img.lockFocus()
        
        var newRect: CGRect = .zero
        newRect.size = img.size
        
        icon.draw(in: newRect)
        overlay.draw(in: newRect)

        img.unlockFocus()
        return img
    }
}
