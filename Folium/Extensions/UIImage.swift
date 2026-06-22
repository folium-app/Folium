//
//  UIImage.swift
//  Folium
//
//  Created by Jarrod Norwell on 22/6/2026.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

extension UIImage {
    func averageColorBottomRight(sampleSize: CGFloat = 50) -> UIColor? {
        guard let cgImage = self.cgImage else { return nil }
        
        // Work in pixel space
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        // Clamp sampleSize to image bounds
        let size = max(1, min(sampleSize, min(width, height)))
        
        // Core Image uses a coordinate system with origin at bottom-left.
        // Define a rect at the bottom-right corner.
        let rect = CGRect(
            x: width - size,
            y: 0,              // bottom edge
            width: size,
            height: size
        )
        
        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext(options: [.workingColorSpace: NSNull(), .outputColorSpace: NSNull()])
        
        // Use CIAreaAverage to average the specified region
        let filter = CIFilter.areaAverage()
        filter.inputImage = ciImage
        filter.extent = rect
        
        guard let outputImage = filter.outputImage else { return nil }
        
        // Render the 1x1 result into a buffer
        var bitmap = [UInt8](repeating: 0, count: 4)
        let outRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: outRect,
                       format: .RGBA8,
                       colorSpace: nil)
        
        let r = CGFloat(bitmap[0]) / 255.0
        let g = CGFloat(bitmap[1]) / 255.0
        let b = CGFloat(bitmap[2]) / 255.0
        let a = CGFloat(bitmap[3]) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
