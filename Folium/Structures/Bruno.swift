//
//  Bruno.swift
//  Bruno
//
//  Created by Emil Wojtaszek on 03/04/2018.
//  Copyright © 2018 AppUnite.com. All rights reserved.
//

import Accelerate
import UIKit

protocol Bufferable {
    var buffer: vImage_Buffer { get }
    var height: Int { get }
    var width: Int { get }
    var rowBytes: Int { get }
}

class RawBuffer: Bufferable {
    private(set) var bytes: Data
    
    let width: Int
    let height: Int
    let rowBytes: Int

    init(data: Data, width: Int, height: Int, rowBytes: Int) {
        self.bytes = data
        self.width = width
        self.height = height
        self.rowBytes = rowBytes
    }

    var buffer: vImage_Buffer {
        let ptr = bytes.withUnsafeBytes { (rawBufferPointer: UnsafeRawBufferPointer) -> UnsafeMutablePointer<UInt8>? in
            guard let baseAddress = rawBufferPointer.baseAddress else {
                return nil
            }
            
            return UnsafeMutablePointer<UInt8>(mutating: baseAddress.assumingMemoryBound(to: UInt8.self))
        }

        return vImage_Buffer(data: ptr, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: rowBytes)
    }
}

struct Bruno {
    static func decode(srcBuffer: Bufferable) -> Bufferable? {
        let width = srcBuffer.width
        let height = srcBuffer.height

        let rowBytes = width * 3
        let dstData = Data(count: height * rowBytes)
        let dstBuffer = RawBuffer(data: dstData, width: width, height: height, rowBytes: rowBytes)

        var buffer565 = srcBuffer.buffer
        var buffer888 = dstBuffer.buffer

        let error = vImageConvert_RGB565toRGB888(&buffer565, &buffer888, vImage_Flags(kvImageNoFlags))
        guard error == kvImageNoError else {
            return nil
        }

        return dstBuffer
    }

    static func encode(srcBuffer: Bufferable) -> Bufferable? {
        let width = srcBuffer.width
        let height = srcBuffer.height

        let rowBytes = width * 2
        let dstData = Data(count: height * rowBytes)
        let dstBuffer = RawBuffer(data: dstData, width: width, height: height, rowBytes: rowBytes)

        var buffer565 = dstBuffer.buffer
        var buffer8888 = srcBuffer.buffer

        let error = vImageConvert_RGBA8888toRGB565(&buffer8888, &buffer565, vImage_Flags(kvImageNoFlags))
        guard error == kvImageNoError else {
            return nil
        }
        
        return dstBuffer
    }
}

extension UIImage {
    func encodeRGB565(width: Int, height: Int) -> Data? {
        guard let srcBytes = self.buffer(width: width, height: height)
            else { return nil }

        guard let dstBuffer = Bruno.encode(srcBuffer: srcBytes)
            else { return nil }

        return Data(bytes: dstBuffer.buffer.data, count: dstBuffer.buffer.rowBytes * Int(dstBuffer.buffer.height))
    }
}

extension Data {
    func decodeRGB565(width: Int, height: Int) -> UIImage? {
        let srcBuffer = RawBuffer(data: self, width: width, height: height, rowBytes: width * 2)

        guard let dstBuffer = Bruno.decode(srcBuffer: srcBuffer)
            else { return nil }

        var format = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 24, colorSpace: nil, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue), version: 0, decode: nil, renderingIntent: .defaultIntent)

        var buffer888 = dstBuffer.buffer
        var error: vImage_Error = 0
        let vImage = vImageCreateCGImageFromBuffer(&buffer888, &format, nil, nil, vImage_Flags(kvImageNoFlags), &error)
        guard error == kvImageNoError else { return nil }

        return vImage.flatMap {
            UIImage(cgImage: $0.takeRetainedValue(), scale: 1.0, orientation: .up)
        }
    }
}

internal extension UIImage {
    func buffer(width: Int, height: Int) -> RawBuffer? {
        guard let cgImage = self.cgImage
            else { return nil }

        let rowBytes = 4 * width
        var bytes = Array<UInt8>.init(repeating: 0, count: rowBytes * height)

        guard let context = CGContext(data: &bytes, width: width, height: height, bitsPerComponent: 8, bytesPerRow: rowBytes, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
            else { return nil }

        context.interpolationQuality = .high
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        let data = bytes.withUnsafeBufferPointer { bufferPointer -> Data in
            return Data(buffer: bufferPointer)
        }
        
        return RawBuffer(data: data, width: width, height: height, rowBytes: rowBytes)
    }
}
