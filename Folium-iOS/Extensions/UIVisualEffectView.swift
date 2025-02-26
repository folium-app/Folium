//
//  UIVisualEffectView.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 22/2/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Foundation
import UIKit

extension UIVisualEffectView {
    func mask(with image: UIImage? = nil) {
        guard let image, let cgImage = image.cgImage else { return }
        
        let width: Int = Int(bounds.width)
        let height: Int = Int(bounds.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: nil,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: width,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.none.rawValue)
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        
        guard let maskImage = context?.makeImage() else { return }
        
        let maskLayer = CALayer()
        maskLayer.contents = maskImage
        maskLayer.frame = bounds
        layer.mask = maskLayer
    }
    
    func letterMask(with text: String) {
        // Step 1: Create a UILabel to render the string as a mask.
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 40) // Set your desired font and size
        label.textColor = .black  // Text color, this will be used for the mask
        label.sizeToFit()  // Resize the label to fit the text
        
        // Step 2: Create a mask from the label using its alpha channel.
        let renderer = UIGraphicsImageRenderer(size: label.bounds.size)
        let textMaskImage = renderer.image { context in
            label.layer.render(in: context.cgContext)
        }
        
        // Step 3: Convert the text mask image to a CGImage to apply it as a mask.
        guard let cgImage = textMaskImage.cgImage else { return }
        
        // Step 4: Create a mask layer and apply it to the UIVisualEffectView's layer.
        let maskLayer = CALayer()
        maskLayer.contents = cgImage
        maskLayer.frame = bounds
        layer.mask = maskLayer
    }
}
