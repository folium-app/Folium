//
//  CIImage.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 4/7/2024.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation
import UIKit

extension CIImage : @unchecked Sendable {}

extension CIImage {
    @Sendable static func smoothGradientBackground(with colors: (first: CIColor, second: CIColor), for view: UIView) async -> CIImage? {
        let ciFilter = CIFilter.smoothLinearGradient()
        ciFilter.color0 = colors.first
        ciFilter.color1 = colors.second
        ciFilter.point0 = .init(x: 0, y: 0)
        ciFilter.point1 = await .init(x: 0, y: view.frame.size.height)
        return ciFilter.outputImage
    }
}
