//
//  GradientView.swift
//  Folium
//
//  Created by Jarrod Norwell on 16/5/2024.
//

import Foundation
import UIKit

class GradientView : UIView {
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }
    
    func set(_ color: UIColor, _ locations: [NSNumber]? = nil, _ darker: Bool = true, componentDelta: CGFloat = 0.02) {
        guard let layer = layer as? CAGradientLayer else {
            return
        }
        
        layer.colors = [color.cgColor, darker ? color.darker(componentDelta: componentDelta).cgColor : color.cgColor]
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15
        layer.locations = locations
    }
    
    func set(_ colors: (UIColor, UIColor), _ locations: [NSNumber]? = nil, _ darker: Bool = true, componentDelta: CGFloat = 0.02) {
        guard let layer = layer as? CAGradientLayer else {
            return
        }
        
        layer.colors = [colors.0.cgColor, darker ? colors.1.darker(componentDelta: componentDelta).cgColor : colors.1.cgColor]
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15
        layer.locations = locations
    }
}
