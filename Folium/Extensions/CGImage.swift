//
//  CGImage.swift
//  Folium
//
//  Created by Jarrod Norwell on 19/6/2026.
//

import CoreGraphics
import Foundation

extension CGImage {
    static func grape(_ pointer: UnsafeMutablePointer<UInt32>, _ width: Int, _ height: Int) -> CGImage? {
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
                
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue).union(CGBitmapInfo.byteOrder32Little)
        guard let providerRef = CGDataProvider(dataInfo: nil, data: pointer, size: totalBytes,
            releaseData: { _, _, _  in }) else {
            return nil
        }
        
        var imageRef: CGImage? = nil
        imageRef = CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel,
            bytesPerRow: bytesPerRow, space: colorSpaceRef, bitmapInfo: bitmapInfo, provider: providerRef,
            decode: nil, shouldInterpolate: false, intent: .defaultIntent)
        
        return imageRef
    }
    
    static func grapeIcon(_ pointer: UnsafeMutablePointer<UInt32>, _ width: Int, _ height: Int) -> CGImage? {
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
                
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue).union(.byteOrderDefault)
        guard let providerRef = CGDataProvider(dataInfo: nil, data: pointer, size: totalBytes,
            releaseData: { _, _, _  in }) else {
            return nil
        }
        
        var imageRef: CGImage? = nil
        imageRef = CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel,
            bytesPerRow: bytesPerRow, space: colorSpaceRef, bitmapInfo: bitmapInfo, provider: providerRef,
            decode: nil, shouldInterpolate: false, intent: .defaultIntent)
        
        return imageRef
    }
    
    static func kiwi(_ pointer: UnsafeMutablePointer<UInt8>, _ width: Int, _ height: Int) -> CGImage? {
        let bitsPerComponent = 8
        let bytesPerPixel = 1
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let bytesPerRow = bytesPerPixel * width
        let size = height * bytesPerRow
        
        guard let provider: CGDataProvider = .init(dataInfo: nil, data: pointer, size: size, releaseData: { _, data, _ in
            data.deallocate()
        }) else {
            return nil
        }
        
        return .init(width: width,
                     height: height,
                     bitsPerComponent: bitsPerComponent,
                     bitsPerPixel: bitsPerPixel,
                     bytesPerRow: bytesPerRow,
                     space: CGColorSpaceCreateDeviceRGB(),
                     bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue).union(.byteOrder32Little),
                     provider: provider,
                     decode: nil,
                     shouldInterpolate: false,
                     intent: .defaultIntent)
    }
    
    static func mandarine15Bit(_ pointer: UnsafeMutableRawPointer, _ width: Int, _ height: Int) -> CGImage? {
        let pixelCount = width * height
        let pixels = pointer.bindMemory(to: UInt16.self, capacity: pixelCount)

        let bytesPerPixel = 3
        let bytesPerRow = bytesPerPixel * width
        let size = bytesPerRow * height
        let data: UnsafeMutablePointer<UInt8> = .allocate(capacity: size)

        for i in 0 ..< pixelCount {
            let pixel = pixels[i]
            let blue: UInt8 = .init((pixel & 0x1F) << 3 | (pixel & 0x1F) >> 2)
            let green: UInt8 = .init(((pixel >> 5) & 0x1F) << 3 | ((pixel >> 5) & 0x1F) >> 2)
            let red: UInt8 = .init(((pixel >> 10) & 0x1F) << 3 | ((pixel >> 10) & 0x1F) >> 2)

            let offset = i * 3
            data[offset + 0] = blue
            data[offset + 1] = green
            data[offset + 2] = red
        }

        guard let provider: CGDataProvider = .init(dataInfo: nil, data: data, size: size, releaseData: { _, data, _ in
            data.deallocate()
        }) else {
            data.deallocate()
            return nil
        }

        return .init(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 24,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )
    }
    
    static func mandarine24Bit(_ pointer: UnsafeMutablePointer<UInt16>, _ width: Int, _ height: Int) -> CGImage? {
        let bytesPerPixel = 3
        let bytesPerRow = width * bytesPerPixel
        let totalBytes = bytesPerRow * height
        
        // Allocate buffer for tightly packed RGB24
        let data = UnsafeMutablePointer<UInt8>.allocate(capacity: totalBytes)
        
        var texOffset = 0
        
        for y in 0..<height {
            var gpuOffset = y * width
            var x = 0
            
            while x < width {
                // PSX 24-bit: 3 words = 2 pixels
                let c1 = pointer[gpuOffset]; gpuOffset += 1
                let c2 = pointer[gpuOffset]; gpuOffset += 1
                let c3 = pointer[gpuOffset]; gpuOffset += 1
                
                // Pixel 0
                data[texOffset + 0] = UInt8(c1 & 0xFF)           // R0
                data[texOffset + 1] = UInt8((c1 >> 8) & 0xFF)    // G0
                data[texOffset + 2] = UInt8(c2 & 0xFF)           // B0
                
                // Pixel 1
                data[texOffset + 3] = UInt8((c2 >> 8) & 0xFF)    // R1
                data[texOffset + 4] = UInt8(c3 & 0xFF)           // G1
                data[texOffset + 5] = UInt8((c3 >> 8) & 0xFF)    // B1
                
                texOffset += 6
                x += 2
            }
        }
        
        // Wrap buffer in NSData for CGDataProvider
        let nsData = NSData(bytesNoCopy: data, length: totalBytes, freeWhenDone: true)
        guard let provider = CGDataProvider(data: nsData) else {
            data.deallocate()
            return nil
        }
        
        return CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 24,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )
    }
    
    static func tomato(_ buffer: UnsafeMutablePointer<UInt32>, _ width: Int, _ height: Int) -> CGImage? {
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
                
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue).union(.byteOrder32Little)
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
