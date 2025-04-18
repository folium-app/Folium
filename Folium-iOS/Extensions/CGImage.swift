//
//  CGImage.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 8/7/2024.
//

import CoreGraphics
import Foundation

extension CGImage {
    static func genericRGBA8888(_ buffer: UnsafeMutablePointer<UInt32>, _ width: Int, _ height: Int) -> CGImage? {
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
    
    static func ds_dsi(_ buffer: UnsafeMutablePointer<UInt32>, _ width: Int, _ height: Int) -> CGImage? {
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
                
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue).union(CGBitmapInfo.byteOrder32Little)
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
    
    static func gba(_ buffer: UnsafeMutablePointer<UInt32>, _ width: Int, _ height: Int) -> CGImage? { nes(buffer, width, height) }
    static func nes(_ buffer: UnsafeMutablePointer<UInt32>, _ width: Int, _ height: Int) -> CGImage? {
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
    
    static func psx_bgr555(_ pointer: UnsafeMutableRawPointer, _ width: Int, _ height: Int) -> CGImage? {
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
    
    static func psx_rgb888(_ pointer: UnsafeMutableRawPointer, _ width: Int, _ height: Int) -> CGImage? {
        let bytesPerPixel = 3
        let bytesPerRow = width * bytesPerPixel
        let totalBytes = bytesPerRow * height
        
        let data: NSData = .init(bytesNoCopy: pointer, length: totalBytes, freeWhenDone: false)
        guard let provider: CGDataProvider = .init(data: data) else { return nil }
        
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
    
    static func snes(_ pointer: UnsafeMutablePointer<UInt8>, _ width: Int, _ height: Int) -> CGImage? {
        let bitsPerComponent = 8
        let bytesPerPixel = 4
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
}
