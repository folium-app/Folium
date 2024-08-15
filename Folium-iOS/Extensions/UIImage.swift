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
}
