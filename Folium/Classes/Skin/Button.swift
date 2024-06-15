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
        case north = "north", east = "east", south = "south", west = "west"
        case dpadUp = "dpadUp", dpadDown = "dpadDown", dpadLeft = "dpadLeft", dpadRight = "dpadRight"
        case l = "l", zl = "zl", r = "r", zr = "zr"
        
        case menu = "menu" // nds=menu, 3ds=home
        case select = "select", start = "start"
    }
    
    struct Customisation : Codable, Hashable {
        enum VibrationStrength : Int, Codable, Hashable {
            case light = 0, medium = 1, heavy = 2, soft = 3, rigid = 4
        }
        
        var backgroundImageName: String? = nil // nil or ""=transparent
        var tappedBackgroundImageName: String? = nil
        
        var vibrateOnTap: Bool? = true
        var vibrationStrength: VibrationStrength? = .heavy
    }
    
    var customisation: Customisation? = nil
    let x, y: Double
    let width, height: Double
    let type: `Type`
    
    func image(for core: Core) -> UIImage? {
        switch type {
        case .north: .init(systemName: core.isNintendo ? "x.circle.fill" : "triangle.circle.fill")
        case .east: .init(systemName: core.isNintendo ? "a.circle.fill" : "circle.circle.fill")
        case .south: .init(systemName: core.isNintendo ? "b.circle.fill" : "xmark.circle.fill")
        case .west: .init(systemName: core.isNintendo ? "y.circle.fill" : "square.circle.fill")
        case .select: .init(systemName: "minus.circle.fill")
        case .start: .init(systemName: "plus.circle.fill")
        case .menu: .init(systemName: "ellipsis.circle.fill")
        case .dpadUp: .init(systemName: "arrowtriangle.up.circle.fill")
        case .dpadDown: .init(systemName: "arrowtriangle.down.circle.fill")
        case .dpadLeft: .init(systemName: "arrowtriangle.left.circle.fill")
        case .dpadRight: .init(systemName: "arrowtriangle.right.circle.fill")
        case .l:
            if #available(iOS 17, *) {
                .init(systemName: core.isNintendo ? "l.button.roundedbottom.horizontal.fill" : "l1.button.roundedbottom.horizontal.fill")
            } else {
                .init(systemName: core.isNintendo ? "l.rectangle.roundedbottom.fill" : "l1.rectangle.roundedbottom.fill")
            }
        case .zl:
            if #available(iOS 17, *) {
                .init(systemName: core.isNintendo ? "zl.button.roundedbottom.horizontal.fill" : "l2.button.roundedbottom.horizontal.fill")
            } else {
                .init(systemName: core.isNintendo ? "zl.rectangle.roundedbottom.fill" :"l2.rectangle.roundedbottom.fill")
            }
        case .r:
            if #available(iOS 17, *) {
                .init(systemName: core.isNintendo ? "r.button.roundedbottom.horizontal.fill" : "r1.button.roundedbottom.horizontal.fill")
            } else {
                .init(systemName: core.isNintendo ? "r.rectangle.roundedbottom.fill" : "r1.rectangle.roundedbottom.fill")
            }
        case .zr:
            if #available(iOS 17, *) {
                .init(systemName: core.isNintendo ? "zr.button.roundedbottom.horizontal.fill" : "r2.button.roundedbottom.horizontal.fill")
            } else {
                .init(systemName: core.isNintendo ? "zr.rectangle.roundedbottom.fill" :"r2.rectangle.roundedbottom.fill")
            }
        }
    }
}
