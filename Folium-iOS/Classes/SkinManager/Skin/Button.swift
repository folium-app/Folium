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
        
        case up = "up"
        case down = "down"
        case left = "left"
        case right = "right"
        
        case l = "l"
        case r = "r"
        
        case zl = "zl"
        case zr = "zr"
        
        case home = "home"
        case minus = "minus"
        case plus = "plus"
        
        case settings = "settings"
        
        case loadState = "loadState"
        case saveState = "saveState"
        
        init(rawValue: String) {
            switch rawValue {
            case "a", "circle": self = .a
            case "b", "cross": self = .b
            case "x", "triangle": self = .x
            case "y", "square": self = .y
                
            case "up", "dpadUp": self = .up
            case "down", "dpadDown": self = .down
            case "left", "dpadLeft": self = .left
            case "right", "dpadRight": self = .right
                
            case "l", "l1": self = .l
            case "r", "r1": self = .r
            case "zl", "l2": self = .zl
            case "zr", "r2": self = .zr
                
            case "home": self = .home
            case "minus", "select": self = .minus
            case "plus", "start": self = .plus
                
            case "settings": self = .settings
            case "loadState": self = .loadState
            case "saveState": self = .saveState
            default: self = .a
            }
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
            core.isNintendo ? "L" : "L1"
        case .r:
            core.isNintendo ? "R" : "R1"
        case .zl:
            core.isNintendo ? "ZL" : "L2"
        case .zr:
            core.isNintendo ? "ZR" : "R2"
        default:
            nil
        }
    }
    
    func image(for core: Core) -> UIImage? {
        switch type {
        case .a:
            return .init(systemName: core.isNintendo ? "a.circle.fill" : "circle.circle.fill")
        case .b:
            return .init(systemName: core.isNintendo ? "b.circle.fill" : "xmark.circle.fill")
        case .x:
            return .init(systemName: core.isNintendo ? "x.circle.fill" : "triangle.circle.fill")
        case .y:
            return .init(systemName: core.isNintendo ? "y.circle.fill" : "square.circle.fill")
            
        case .up:
            return .init(systemName: "arrowtriangle.up.circle.fill")
        case .down:
            return .init(systemName: "arrowtriangle.down.circle.fill")
        case .left:
            return .init(systemName: "arrowtriangle.left.circle.fill")
        case .right:
            return .init(systemName: "arrowtriangle.right.circle.fill")
            
        case .l: return nil
        case .r: return nil
            
        case .zl: return nil
        case .zr: return nil
            
        case .home:
            return .init(systemName: "house.circle.fill")
        case .minus:
            return .init(systemName: "minus.circle.fill")
        case .plus:
            return .init(systemName: "plus.circle.fill")
            
        case .settings:
            return .init(systemName: "gearshape.circle.fill")
            
        case .loadState:
            let string = if #available(iOS 18, *) { "arrow.up.document.fill" } else { "arrow.up.doc.fill" }
            return .init(systemName: string)
        case .saveState:
            let string = if #available(iOS 18, *) { "arrow.down.document.fill" } else { "arrow.down.doc.fill" }
            return .init(systemName: string)
        }
    }
}
