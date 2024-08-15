//
//  CGFloat.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 1/8/2024.
//

import Foundation

extension CGFloat {
    var toPixels: Self {
        self * 1.333333
    }
}

extension Int {
    var toPixels: Self {
        self * Int(1.333333)
    }
}
