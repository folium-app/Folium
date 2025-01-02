//
//  UIImage.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 17/7/2024.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation
import UIKit

extension UIImage {
    func blurMasked(radius: Float) -> UIImage {
        let context = CIContext(options: nil)
        guard let cgImage = cgImage else {
            return self
        }
        
        let inputImage = CIImage(cgImage: cgImage)
        
        let maskedVariableBlurFilter = CIFilter.maskedVariableBlur()
        maskedVariableBlurFilter.inputImage = inputImage
        maskedVariableBlurFilter.radius = radius
        
        let smoothLinearGradientFilter = CIFilter.smoothLinearGradient()
        smoothLinearGradientFilter.color0 = .white
        smoothLinearGradientFilter.color1 = .black
        smoothLinearGradientFilter.point0 = .zero
        smoothLinearGradientFilter.point1 = .init(x: 0, y: inputImage.extent.height)
        guard let slgfOutputImage = smoothLinearGradientFilter.outputImage else {
            return self
        }
        
        maskedVariableBlurFilter.mask = slgfOutputImage
        
        guard let mvbfOutputImage = maskedVariableBlurFilter.outputImage else {
            return self
        }
        
        guard let cgImage = context.createCGImage(mvbfOutputImage, from: inputImage.extent) else {
            return self
        }
        
        return .init(cgImage: cgImage)
    }
    
    func blurred(radius: Float) -> UIImage {
        let context = CIContext(options: nil)
        guard let cgImage = cgImage else {
            return self
        }
        
        let inputImage = CIImage(cgImage: cgImage)
        
        let gaussianBlurFilter = CIFilter.gaussianBlur()
        gaussianBlurFilter.inputImage = inputImage
        gaussianBlurFilter.radius = radius
        guard let gbfOutputImage = gaussianBlurFilter.outputImage else {
            return self
        }
        
        guard let cgImage = context.createCGImage(gbfOutputImage, from: inputImage.extent) else {
            return self
        }
        
        return .init(cgImage: cgImage)
    }
    
    
    static func lycheeBGRtoRGBImage(from buffer: [UInt32], with width: Int = 1024, and height: Int = 512) -> UIImage? {
        let bitsPerComponent = 8
        let bytesPerPixel = 4 // 32 bits per pixel (RGB32)
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow
        
        let buffer = Data(bytes: buffer, count: totalBytes)
        
        // Create a CGDataProvider from the Data object.
        guard let provider = CGDataProvider(data: buffer as CFData) else {
            return nil
        }
        
        // Define the color space. BGR555 is typically treated as RGB.
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Create a bitmap CGImage.
        guard let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        ) else {
            return nil
        }
        
        return .init(cgImage: cgImage)
    }
    
    static func expand5to8(_ color: UInt8) -> UInt8 {
        return (color << 3) | (color >> 2)
    }
    
    static func BGR555toRGB888(_ color: UInt16) -> UInt32 {
        let blue = UInt8(color & 0x1F)
        let green = UInt8((color >> 5) & 0x1F)
        let red = UInt8((color >> 10) & 0x1F)
        
        let expandedBlue = expand5to8(blue)
        let expandedGreen = expand5to8(green)
        let expandedRed = expand5to8(red)
        
        return (UInt32(expandedRed) << 16) | (UInt32(expandedGreen) << 8) | UInt32(expandedBlue)
    }
    
    static func BGRtoRGB(_ buffer: UnsafeMutablePointer<UInt16>, _ count: Int) -> [UInt32] {
        var data = [UInt32](repeating: 0, count: count)
        for idx in 0 ..< count {
            data[idx] = BGR555toRGB888(buffer[idx])
        }
        
        return data
    }
}
