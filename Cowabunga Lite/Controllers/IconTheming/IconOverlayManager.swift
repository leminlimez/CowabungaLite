//
//  IconOverlayManager.swift
//  Cowabunga Lite
//
//  Created by lemin on 6/1/23.
//

import Foundation
import SwiftUI

class IconOverlayManager {
    public static func scaleFilter(_ input: CIImage, aspectRatio : Double, scale : Double) -> CIImage
    {
        // taken from: https://developer.apple.com/documentation/coreimage/processing_an_image_using_built-in_filters
        let scaleFilter = CIFilter(name:"CILanczosScaleTransform")!
        scaleFilter.setValue(input, forKey: kCIInputImageKey)
        scaleFilter.setValue(scale, forKey: kCIInputScaleKey)
        scaleFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        return scaleFilter.outputImage!
    }
    
    public static func overlayIconOLD(_ icon: NSImage, _ overlay: NSImage) -> NSImage {
        let img = NSImage(size: icon.size)
        img.lockFocus()
        
        var newRect: CGRect = .zero
        newRect.size = img.size
        
        icon.draw(in: newRect)
        overlay.draw(in: newRect)

        img.unlockFocus()
        return img
    }
    
    public static func overlayIcon(_ icon: CIImage, _ overlay: CIImage) -> CIImage {
        let scale = min(icon.extent.size.width/overlay.extent.size.width, icon.extent.size.height/overlay.extent.size.height)
        let scaledCIImage = scaleFilter(overlay, aspectRatio: 1, scale: scale)
        return scaledCIImage.composited(over: icon)
    }
}
