//
//  System.swift
//  Folium
//
//  Created by Jarrod Norwell on 17/6/2026.
//

import Foundation

enum System : String, CaseIterable, Hashable, Sendable {
    case grape = "Grape"
    case kiwi = "Kiwi"
    case mandarine = "Mandarine"
    case tomato = "Tomato"
    
    var console: String {
        switch self {
        case .grape:
            "Nintendo DS/DSi"
        case .kiwi:
            "Game Boy/Game Boy Color"
        case .mandarine:
            "PlayStation 1"
        case .tomato:
            "Game Boy Advance"
        }
    }
    
    var consoleShort: String {
        switch self {
        case .grape:
            "DS/DSi"
        case .kiwi:
            "GB/GBC"
        case .mandarine:
            "PS1"
        case .tomato:
            "GBA"
        }
    }
    
    nonisolated var extensions: [Extension] {
        switch self {
        case .grape:
            [
                .nds
            ]
        case .kiwi:
            [
                .gb,
                .gbc
            ]
        case .mandarine:
            [
                .cue
            ]
        case .tomato:
            [
                .gba
            ]
        }
    }
    
    var features: [Feature] {
        switch self {
        case .grape,
                .kiwi,
                .mandarine,
                .tomato:
            [
                .gameController
            ]
        }
    }
    
    var isNintendo: Bool {
        switch self {
        case .mandarine:
            false
        case .grape,
                .kiwi,
                .tomato:
            true
        }
    }
    
    var string: String { rawValue }
    
    static let systems: [System] = System.allCases
    static let systemsStrings: [String] = systems.map(\.string)
}
