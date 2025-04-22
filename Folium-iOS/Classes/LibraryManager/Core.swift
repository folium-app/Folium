//
//  Core.swift
//  Folium
//
//  Created by Jarrod Norwell on 2/3/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Foundation
import UIKit

enum Core : String, Codable, Comparable, CaseIterable, CustomStringConvertible, Hashable, @unchecked Sendable {
    static func < (lhs: Core, rhs: Core) -> Bool { lhs.rawValue < rhs.rawValue }
    
    case cherry = "Cherry" // PS2
    case cytrus = "Cytrus" // 3DS
    case grape = "Grape" // NDS
    case guava = "Guava" // N64
    case kiwi = "Kiwi" // GB/GBC
    case lychee = "Lychee" // PS1
    case mango = "Mango" // SNES
    case peach = "Peach" // NES
    case tomato = "Tomato" // GBA
    
    var color: [Button.`Type` : UIColor] {
        switch self {
        case .cytrus, .grape, .mango:
            [
                .a : .systemRed,
                .b : .systemYellow,
                .x : .systemBlue,
                .y : .systemGreen
            ]
        case .cherry, .lychee:
            [
                .a : .systemOrange,
                .b : .systemBlue,
                .x : .systemGreen,
                .y : .systemPink
            ]
        default:
            [:]
        }
    }
    
    var colors: [Button.`Type` : (UIColor, UIColor)] {
        switch self {
        case .cytrus:
            let isNew3DS = UserDefaults.standard.bool(forKey: "cytrus.new3DS")
            
            return [
                .up : (.black, .white),
                .down : (.black, .white),
                .left : (.black, .white),
                .right : (.black, .white),
                .a : isNew3DS ? (.white, .systemRed) : (.black, .white),
                .b : isNew3DS ? (.white, .systemYellow) : (.black, .white),
                .x : isNew3DS ? (.white, .systemBlue) : (.black, .white),
                .y : isNew3DS ? (.white, .systemGreen) : (.black, .white)
            ]
        case .lychee:
            return [
                .a : (.systemOrange, .white),
                .b : (.systemBlue, .white),
                .x : (.systemGreen, .white),
                .y : (.systemPink, .white)
            ]
        default:
            return [
                :
            ]
        }
    }
    
    var console: String {
        switch self {
        case .cherry: "PlayStation 2"
        case .cytrus: "Nintendo 3DS, New Nintendo 3DS"
        case .grape: "Nintendo DS, Nintendo DSi"
        case .guava: "Nintendo 64"
        case .kiwi: "Game Boy, Game Boy Color"
        case .lychee: "PlayStation 1"
        case .mango: "Super Nintendo Entertainment System"
        case .peach: "Nintendo Entertainment System"
        case .tomato: "Game Boy Advance"
        }
    }
    
    var description: String { rawValue }
    
    var isBeta: Bool {
        switch self {
        case .cherry, .guava, .lychee, .mango, .peach, .tomato: true
        default: false
        }
    }
    
    var isNintendo: Bool { [.cytrus, .grape, .guava, .kiwi, .mango, .peach, .tomato].contains(self) }
}
