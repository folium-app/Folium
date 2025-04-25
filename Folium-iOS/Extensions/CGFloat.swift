//
//  CGFloat.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 1/8/2024.
//

import Foundation
import UIKit

extension CGFloat {
    var toPixels: Self {
        self * 1.333333
    }
    
    static var smallCornerRadius: Self {
        var configuration: UIButton.Configuration = .plain()
        configuration.buttonSize = .small
        configuration.cornerStyle = .capsule
        return configuration.background.cornerRadius
    }
    
    static var mediumCornerRadius: Self {
        var configuration: UIButton.Configuration = .plain()
        configuration.buttonSize = .medium
        configuration.cornerStyle = .capsule
        return configuration.background.cornerRadius
    }
    
    static var largeCornerRadius: Self {
        var configuration: UIButton.Configuration = .plain()
        configuration.buttonSize = .large
        configuration.cornerStyle = .capsule
        return configuration.background.cornerRadius
    }
}

extension Int {
    var toPixels: Self {
        self * Int(1.333333)
    }
}
