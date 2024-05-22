//
//  CGImage.swift
//  Folium
//
//  Created by Jarrod Norwell on 16/5/2024.
//

import Foundation
import UIKit

extension CGImage {
    static func cgImage(_ buffer: UnsafeMutablePointer<UInt32>, _ width: Int, _ height: Int) -> CGImage? {
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue).union(.byteOrderDefault)
        guard let providerRef = CGDataProvider(dataInfo: nil, data: buffer, size: totalBytes,
            releaseData: { _, _, _  in }) else {
            return nil
        }
        
        var imageRef: CGImage? = nil
        imageRef = CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel,
            bytesPerRow: bytesPerRow, space: colorSpaceRef, bitmapInfo: bitmapInfo, provider: providerRef,
            decode: nil, shouldInterpolate: false, intent: .defaultIntent)
        
        return imageRef
    }
}
