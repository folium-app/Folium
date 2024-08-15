//
//  Data.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 17/7/2024.
//

import Accelerate
import Foundation

extension Data {
    static func upscaleRGB565Image(data: Data, width: Int, height: Int, scale: Int) -> Data? {
        let rgb565Buffer = Array(data) // Convert Data to byte array
        
        // Step 1: Convert RGB565 to RGBA8888
        var rgba8888Buffer = [UInt8](repeating: 0, count: width * height * 4)
        
        for i in 0..<(width * height) {
            let pixel = UInt16(rgb565Buffer[2 * i]) | (UInt16(rgb565Buffer[2 * i + 1]) << 8)
            let r = (pixel & 0xF800) >> 8
            let g = (pixel & 0x07E0) >> 3
            let b = (pixel & 0x001F) << 3
            
            rgba8888Buffer[4 * i] = UInt8(r)
            rgba8888Buffer[4 * i + 1] = UInt8(g)
            rgba8888Buffer[4 * i + 2] = UInt8(b)
            rgba8888Buffer[4 * i + 3] = 255 // Alpha channel
        }
        
        // Step 2: Create vImage_Buffer for the source image
        var sourceBuffer = rgba8888Buffer.withUnsafeMutableBytes { (ptr: UnsafeMutableRawBufferPointer) in
            return vImage_Buffer(
                data: ptr.baseAddress!,
                height: vImagePixelCount(height),
                width: vImagePixelCount(width),
                rowBytes: width * 4
            )
        }
        
        // Step 3: Create vImage_Buffer for the destination image
        let newWidth = width * scale
        let newHeight = height * scale
        let destinationBufferPointer = UnsafeMutableRawPointer.allocate(byteCount: newWidth * newHeight * 4, alignment: MemoryLayout<UInt8>.alignment)
        
        var destinationBuffer = vImage_Buffer(
            data: destinationBufferPointer,
            height: vImagePixelCount(newHeight),
            width: vImagePixelCount(newWidth),
            rowBytes: newWidth * 4
        )
        
        // Step 4: Perform the upscaling
        let error = vImageScale_ARGB8888(
            &sourceBuffer,
            &destinationBuffer,
            nil,
            vImage_Flags(kvImageHighQualityResampling)
        )
        
        if error != kvImageNoError {
            destinationBufferPointer.deallocate()
            return nil
        }
        
        // Convert the destination buffer to Data
        let resultData = Data(bytes: destinationBuffer.data, count: newWidth * newHeight * 4)
        
        // Free the destination buffer data
        destinationBufferPointer.deallocate()
        
        return resultData
    }
}
