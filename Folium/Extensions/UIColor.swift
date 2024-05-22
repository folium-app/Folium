//
//  UIColor.swift
//  Folium
//
//  Created by Jarrod Norwell on 16/5/2024.
//

import Foundation
import UIKit

extension UIColor {
    private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
        max(0, min(1, toComponent + value))
    }
    
    private func makeColor(componentDelta: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return UIColor(red: add(componentDelta, toComponent: red), green: add(componentDelta, toComponent: green),
                       blue: add(componentDelta, toComponent: blue), alpha: alpha)
    }
    
    func lighter(componentDelta: CGFloat = 0.1) -> UIColor {
        makeColor(componentDelta: componentDelta)
    }
        
    func darker(componentDelta: CGFloat = 0.1) -> UIColor {
        makeColor(componentDelta: -1 * componentDelta)
    }
}
