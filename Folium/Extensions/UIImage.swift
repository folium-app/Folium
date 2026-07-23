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

extension UIImage {

    func dominantColors(count: Int = 12) -> [UIColor] {
        guard let cgImage = self.cgImage else { return [] }

        let width = 100
        let height = Int(CGFloat(width) * size.height / size.width)

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        var pixels = [UInt8](repeating: 0, count: width * height * 4)

        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return []
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var samples: [[Double]] = []

        for i in stride(from: 0, to: pixels.count, by: 4) {
            let a = pixels[i + 3]
            guard a > 0 else { continue }

            samples.append([
                Double(pixels[i]),
                Double(pixels[i + 1]),
                Double(pixels[i + 2])
            ])
        }

        let centroids = kMeans(points: samples, k: count)

        return centroids.map {
            UIColor(
                red: CGFloat($0[0] / 255),
                green: CGFloat($0[1] / 255),
                blue: CGFloat($0[2] / 255),
                alpha: 1
            )
        }
    }
}

private func kMeans(points: [[Double]], k: Int, iterations: Int = 15) -> [[Double]] {
    guard !points.isEmpty else { return [] }

    var centroids = Array(points.shuffled().prefix(k))

    for _ in 0..<iterations {

        var groups = Array(repeating: [[Double]](), count: centroids.count)

        for point in points {
            var best = 0
            var bestDistance = Double.infinity

            for (i, centroid) in centroids.enumerated() {
                let d =
                    pow(point[0] - centroid[0], 2) +
                    pow(point[1] - centroid[1], 2) +
                    pow(point[2] - centroid[2], 2)

                if d < bestDistance {
                    bestDistance = d
                    best = i
                }
            }

            groups[best].append(point)
        }

        for i in groups.indices where !groups[i].isEmpty {
            let r = groups[i].map{$0[0]}.reduce(0,+) / Double(groups[i].count)
            let g = groups[i].map{$0[1]}.reduce(0,+) / Double(groups[i].count)
            let b = groups[i].map{$0[2]}.reduce(0,+) / Double(groups[i].count)

            centroids[i] = [r, g, b]
        }
    }

    return centroids
}
