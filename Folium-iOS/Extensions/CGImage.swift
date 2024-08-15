//
//  CGImage.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 8/7/2024.
//

import CoreGraphics

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
    
    static func cgImage(rawPointer buffer: UnsafeMutableRawPointer, _ width: Int, _ height: Int) -> CGImage? {
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
            
            let bitsPerComponent = 8
            let bytesPerPixel = 4
            let bitsPerPixel = bytesPerPixel * bitsPerComponent
            let bytesPerRow = bytesPerPixel * width
            let totalBytes = height * bytesPerRow
            
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue).union(.byteOrderDefault)
            
            guard let providerRef = CGDataProvider(dataInfo: nil, data: buffer, size: totalBytes, releaseData: { _, _, _ in }) else {
                return nil
            }
            
            guard let imageRef = CGImage(
                width: width,
                height: height,
                bitsPerComponent: bitsPerComponent,
                bitsPerPixel: bitsPerPixel,
                bytesPerRow: bytesPerRow,
                space: colorSpaceRef,
                bitmapInfo: bitmapInfo,
                provider: providerRef,
                decode: nil,
                shouldInterpolate: false,
                intent: .defaultIntent
            ) else {
                return nil
            }
            
            return imageRef
        }
    
    static func cgImage24(from buffer: UnsafeMutableRawPointer, _ width: Int, _ height: Int) -> CGImage? {
        // Define the bits per component and bits per pixel for RGB24
        let bitsPerComponent = 8
        let bitsPerPixel = 24

        // Create a color space
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return nil
        }

        // Calculate the bytes per row
        let bytesPerRow = width * 3 // 3 bytes per pixel for RGB24

        // Create a CGDataProvider from the pointer
        let dataProvider = CGDataProvider(dataInfo: nil, data: buffer, size: bytesPerRow * height) { _, _, _ in
            // Deallocation code if needed
        }

        // Create a CGImage from the data provider
        guard let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
            provider: dataProvider!,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        ) else {
            return nil
        }

        // Create and return a UIImage from the CGImage
        return cgImage
    }
}
