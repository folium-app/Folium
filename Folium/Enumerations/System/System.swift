//
//  System.swift
//  Folium
//
//  Created by Jarrod Norwell on 17/6/2026.
//

import Foundation

enum System : String, CaseIterable, Codable, Hashable, Sendable {
    case cherry = "Cherry"
    case cytrus = "Cytrus"
    case durian = "Durian"
    case grape = "Grape"
    case kiwi = "Kiwi"
    case lychee = "Lychee"
    case mandarine = "Mandarine"
    case mango = "Mango"
    case plum = "Plum"
    case tomato = "Tomato"
    
    var console: String {
        switch self {
        case .cherry:
            "ColecoVision"
        case .cytrus:
            "Nintendo 3DS"
        case .durian:
            "WonderSwan"
        case .grape:
            "Nintendo DS"
        case .kiwi:
            "Game Boy"
        case .lychee:
            "Super Nintendo Entertainment System"
        case .mandarine:
            "PlayStation 1"
        case .mango:
            "Nintendo Entertainment System"
        case .plum:
            "SEGA Genesis"
        case .tomato:
            "Game Boy Advance"
        }
    }
    
    var consoleShort: String {
        switch self {
        case .cherry:
            "CV"
        case .cytrus:
            "3DS"
        case .durian:
            "WS"
        case .grape:
            "DS"
        case .kiwi:
            "GB"
        case .lychee:
            "SNES"
        case .mandarine:
            "PS1"
        case .mango:
            "NES"
        case .plum:
            "GEN"
        case .tomato:
            "GBA"
        }
    }
    
    nonisolated var extensions: [Extension] {
        switch self {
        case .cherry:
            Extension.cherry
        case .cytrus:
            Extension.cytrus
        case .durian:
            Extension.durian
        case .grape:
            Extension.grape
        case .kiwi:
            Extension.kiwi
        case .lychee:
            Extension.lychee
        case .mandarine:
            Extension.mandarine
        case .mango:
            Extension.mango
        case .plum:
            Extension.plum
        case .tomato:
            Extension.tomato
        }
    }
    
    var features: [Feature] {
        switch self {
        case  .cherry,
                .cytrus,
                .durian,
                .grape,
                .kiwi,
                .lychee,
                .mandarine,
                .mango,
                .plum,
                .tomato:
            [
                .gameController
            ]
        }
    }
    
    var isNintendo: Bool {
        switch self {
        case .cherry,
                .durian,
                .mandarine,
                .plum:
            false
        case .cytrus,
                .grape,
                .kiwi,
                .lychee,
                .mango,
                .tomato:
            true
        }
    }
    
    var string: String { rawValue }
    
    static let systems: [System] = System.allCases
    static let systemsStrings: [String] = systems.map(\.string)
}
