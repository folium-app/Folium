//
//  Button.swift
//  Folium
//
//  Created by Jarrod Norwell on 13/6/2024.
//

import Foundation
import UIKit

struct Button : Codable, Hashable {
    enum `Type` : String, Codable, Hashable {
        case a = "a"
        case b = "b"
        case x = "x"
        case y = "y"
        
        case dpadUp = "dpadUp"
        case dpadDown = "dpadDown"
        case dpadLeft = "dpadLeft"
        case dpadRight = "dpadRight"
        
        case l = "l"
        case r = "r"
        
        case zl = "zl"
        case zr = "zr"
        
        case home = "home"
        case minus = "minus"
        case plus = "plus"
        
        case fastForward = "fastForward"
        case settings = "settings"
        
        enum CodingKeys : String, CodingKey {
            case a = "circle"
            case b = "cross"
            case x = "triangle"
            case y = "square"
            
            case l = "l1"
            case r = "r1"
            
            case zl = "l2"
            case zr = "r2"
            
            case minus = "select"
            case plus = "start"
        }
    }
    
    var alpha: Double? = 1
    let x, y: Double
    let width, height: Double
    let type: `Type`
    
    var backgroundImageName: String? = nil
    var buttonClassName: String? = "defaultButton"
    var transparent: Bool? = false
    var vibrateOnTap: Bool? = true
    
    struct BorderedStyle : Codable, Hashable {
        let borderColor: String // hex
        let borderWidth: CGFloat
    }
    
    struct DefaultStyle : Codable, Hashable {
        let backgroundImageName: String
    }
    
    var borderedStyle: BorderedStyle? = nil
    var defaultStyle: DefaultStyle? = nil
    
    func letter(for core: Core) -> String? {
        switch type {
        case .a:
            core.isNintendo ? "A" : nil
        case .b:
            core.isNintendo ? "B" : nil
        case .x:
            core.isNintendo ? "X" : nil
        case .y:
            core.isNintendo ? "Y" : nil
        case .l:
            core.isNintendo ? "L" : nil
        case .r:
            core.isNintendo ? "R" : nil
        case .zl:
            core.isNintendo ? "ZL" : nil
        case .zr:
            core.isNintendo ? "ZR" : nil
        default:
            nil
        }
    }
    
    func image(for core: Core) -> UIImage? {
        switch type {
        case .a:
            .init(systemName: core.isNintendo ? "a.circle.fill" : "circle.circle.fill")
        case .b:
            .init(systemName: core.isNintendo ? "b.circle.fill" : "xmark.circle.fill")
        case .x:
            .init(systemName: core.isNintendo ? "x.circle.fill" : "triangle.circle.fill")
        case .y:
            .init(systemName: core.isNintendo ? "y.circle.fill" : "square.circle.fill")
            
        case .dpadUp:
            .init(systemName: "arrowtriangle.up.circle.fill")
        case .dpadDown:
            .init(systemName: "arrowtriangle.down.circle.fill")
        case .dpadLeft:
            .init(systemName: "arrowtriangle.left.circle.fill")
        case .dpadRight:
            .init(systemName: "arrowtriangle.right.circle.fill")
            
        case .l:
            if #available(iOS 17, *) {
                .init(systemName: core.isNintendo ? "l.button.roundedbottom.horizontal.fill" : "l1.button.roundedbottom.horizontal.fill")
            } else {
                .init(systemName: core.isNintendo ? "l.rectangle.roundedbottom.fill" : "l1.rectangle.roundedbottom.fill")
            }
        case .r:
            if #available(iOS 17, *) {
                .init(systemName: core.isNintendo ? "r.button.roundedbottom.horizontal.fill" : "r1.button.roundedbottom.horizontal.fill")
            } else {
                .init(systemName: core.isNintendo ? "r.rectangle.roundedbottom.fill" : "r1.rectangle.roundedbottom.fill")
            }
            
        case .zl:
            if #available(iOS 17, *) {
                .init(systemName: core.isNintendo ? "zl.button.roundedtop.horizontal.fill" : "l2.button.roundedtop.horizontal.fill")
            } else {
                .init(systemName: core.isNintendo ? "zl.rectangle.roundedtop.fill" :"l2.rectangle.roundedtop.fill")
            }
        case .zr:
            if #available(iOS 17, *) {
                .init(systemName: core.isNintendo ? "zr.button.roundedtop.horizontal.fill" : "r2.button.roundedtop.horizontal.fill")
            } else {
                .init(systemName: core.isNintendo ? "zr.rectangle.roundedtop.fill" :"r2.rectangle.roundedtop.fill")
            }
            
        case .home:
            .init(systemName: "house.circle.fill")
        case .minus:
            .init(systemName: "minus.circle.fill")
        case .plus:
            .init(systemName: "plus.circle.fill")
            
        case .fastForward:
            .init(systemName: "forward.fill")
        case .settings:
            .init(systemName: "gearshape.fill")
        }
    }
}
