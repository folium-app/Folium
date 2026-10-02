//
//  UIImage.swift
//  Folium
//
//  Created by Jarrod Norwell on 22/6/2026.
//

import UIKit

extension UIImage {
    var valid: Bool { !cgImage.isNil || !ciImage.isNil && size != .zero }
}
