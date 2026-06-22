//
//  System.swift
//  Folium
//
//  Created by Jarrod Norwell on 17/6/2026.
//

import Foundation

enum System : String, CaseIterable, Hashable, Sendable {
    case mandarine = "Mandarine"
    case tomato = "Tomato"
    
    var console: String {
        switch self {
        case .mandarine:
            "PlayStation 1"
        case .tomato:
            "Game Boy Advance"
        }
    }
    
    var consoleShort: String {
        switch self {
        case .mandarine:
            "PS1"
        case .tomato:
            "GBA"
        }
    }
    
    nonisolated var extensions: [Extension] {
        switch self {
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
        case .mandarine,
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
        case .tomato:
            true
        }
    }
    
    var string: String { rawValue }
    
    static let systems: [System] = System.allCases
    static let systemsStrings: [String] = systems.map(\.string)
}
