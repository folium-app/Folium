//
//  CGImage.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 8/7/2024.
//

import CoreGraphics
import Foundation

extension CGImage {
    static func sectionRGB565(from pointer: UnsafeMutablePointer<UInt16>, width: Int, x: Int, y: Int, sectionWidth: Int, sectionHeight: Int) -> CGImage? {
        // Check if the section is within bounds
        guard x + sectionWidth <= width else {
            print("Section exceeds image width.")
            return nil
        }
        
        // Create an array to hold the section's pixel data in ARGB format
        var sectionData = [UInt8](repeating: 0, count: sectionWidth * sectionHeight * 4)
        
        // Extract the section and convert from RGB565 to ARGB
        for row in 0..<sectionHeight {
            for col in 0..<sectionWidth {
                let rowOffset = (y + row) * width + (x + col)
                let pixel = pointer[rowOffset]
                
                // Convert RGB565 to ARGB (5 bits red, 6 bits green, 5 bits blue)
                let red = UInt8((pixel & 0xF800) >> 8)   // 5-bit red, shift to 8 bits
                let green = UInt8((pixel & 0x07E0) >> 3) // 6-bit green, shift to 8 bits
                let blue = UInt8((pixel & 0x001F) << 3)  // 5-bit blue, shift to 8 bits
                let alpha: UInt8 = 255 // Fully opaque
                
                // Store in ARGB format (index 0: alpha, index 1: red, index 2: green, index 3: blue)
                let offset = (row * sectionWidth + col) * 4
                sectionData[offset] = alpha
                sectionData[offset + 1] = red
                sectionData[offset + 2] = green
                sectionData[offset + 3] = blue
            }
        }
        
        // Create a CGDataProvider with the section data
        let dataProvider = CGDataProvider(data: Data(sectionData) as CFData)
        
        // Create a CGImage from the section data
        let cgImage = CGImage(width: sectionWidth,
                              height: sectionHeight,
                              bitsPerComponent: 8,
                              bitsPerPixel: 32,
                              bytesPerRow: sectionWidth * 4,
                              space: CGColorSpaceCreateDeviceRGB(),
                              bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).union(.byteOrder32Big),
                              provider: dataProvider!,
                              decode: nil,
                              shouldInterpolate: false,
                              intent: .defaultIntent)
        
        return cgImage
    }
    
    static func sectionBGR555(from pointer: UnsafeMutablePointer<UInt16>, width: Int, x: Int, y: Int, sectionWidth: Int, sectionHeight: Int) -> CGImage? {
        // Check if the section is within bounds
        guard x + sectionWidth <= width else {
            print("Section exceeds image width.")
            return nil
        }
        
        // Create an array to hold the section's pixel data in ARGB format
        var sectionData = [UInt8](repeating: 0, count: sectionWidth * sectionHeight * 4)
        
        // Extract the section and convert from BGR555 to ARGB
        for row in 0..<sectionHeight {
            for col in 0..<sectionWidth {
                let rowOffset = (y + row) * width + (x + col)
                let pixel = pointer[rowOffset]
                
                // Convert BGR555 to ARGB (we're assuming 5 bits per channel in BGR555)
                let blue = UInt8((pixel & 0x001F) << 3)
                let green = UInt8((pixel & 0x03E0) >> 2)
                let red = UInt8((pixel & 0x7C00) >> 7)
                let alpha: UInt8 = 255 // Fully opaque

                // Store in ARGB format (index 0: alpha, index 1: red, index 2: green, index 3: blue)
                let offset = (row * sectionWidth + col) * 4
                sectionData[offset] = blue
                sectionData[offset + 1] = green
                sectionData[offset + 2] = red
                sectionData[offset + 3] = alpha
            }
        }
        
        // Create a CGDataProvider with the section data
        let dataProvider = CGDataProvider(data: Data(sectionData) as CFData)
        
        // Create a CGImage from the section data
        let cgImage = CGImage(width: sectionWidth,
                              height: sectionHeight,
                              bitsPerComponent: 8,
                              bitsPerPixel: 32,
                              bytesPerRow: sectionWidth * 4,
                              space: CGColorSpaceCreateDeviceRGB(),
                              bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue).union(.byteOrder32Big),
                              provider: dataProvider!,
                              decode: nil,
                              shouldInterpolate: false,
                              intent: .defaultIntent)
        
        return cgImage
    }
    
    static func cgImage16(_ buffer: UnsafeMutablePointer<UInt16>, _ width: Int, _ height: Int) -> CGImage? {
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
                
        let bitsPerComponent = 8
        let bytesPerPixel = 3
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).union(.byteOrderDefault)
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
    
    static func rgb32CGImage(_ buffer: UnsafeMutablePointer<UInt32>, _ width: Int = 1024, _ height: Int = 512) -> CGImage? {
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        
        let bitsPerComponent = 8
        let bytesPerPixel = 4 // 32 bits per pixel (RGB32)
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow
        
        // Bitmap info for RGB32 with no alpha, skipping the last 8 bits (often unused alpha or padding)
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue).union(.byteOrder32Little)
        
        guard let providerRef = CGDataProvider(dataInfo: nil, data: buffer, size: totalBytes, releaseData: { _, _, _ in }) else {
            return nil
        }
        
        // Create the CGImage with RGB32 data
        let imageRef = CGImage(
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
        )
        
        return imageRef
    }
    
    static func bgr32CGImage(_ buffer: UnsafeMutablePointer<UInt32>, _ width: Int = 1024, _ height: Int = 512) -> CGImage? {
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        
        let bitsPerComponent = 8
        let bytesPerPixel = 4 // 32 bits per pixel (RGB32)
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow
        
        // Bitmap info for RGB32 with no alpha, skipping the last 8 bits (often unused alpha or padding)
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue).union(.byteOrderDefault)
        
        guard let providerRef = CGDataProvider(dataInfo: nil, data: buffer, size: totalBytes, releaseData: { _, _, _ in }) else {
            return nil
        }
        
        // Create the CGImage with RGB32 data
        let imageRef = CGImage(
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
        )
        
        return imageRef
    }
    
    static func cgImage(buffer8: UnsafeMutablePointer<UInt8>, _ width: Int, _ height: Int) -> CGImage? {
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue).union(.byteOrder32Little)
        guard let providerRef = CGDataProvider(dataInfo: nil, data: buffer8, size: totalBytes,
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
    
    
    static func gambatteImage(from videoBuffer: [UInt32]) -> CGImage? {
        var videoBuffer = videoBuffer
        let data = Data(bytesNoCopy: &videoBuffer, count: 4 * videoBuffer.count, deallocator: .none) as CFData
        
        let provider = CGDataProvider(data: data)
        guard let provider else {
            return nil
        }
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue).union([.byteOrder32Little])
        return CGImage(width: 160, height: 144, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: 4 * 160, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo, provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
    }
}
