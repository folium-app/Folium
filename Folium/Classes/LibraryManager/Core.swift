//
//  Core.swift
//  Folium
//
//  Created by Jarrod Norwell on 15/5/2024.
//

import Foundation

enum Core : String, Codable, Hashable {
    enum Console : String, Codable, Hashable {
        case gba = "Game Boy Advance"
        case n3ds = "Nintendo 3DS"
        case nds = "Nintendo DS"
        case nes = "Nintendo Entertainment System"
        
        var shortened: String {
            switch self {
            case .gba:
                "GBA"
            case .n3ds:
                "3DS"
            case .nds:
                "NDS"
            case .nes:
                "NES"
            }
        }
    }
    
    case cytrus = "Cytrus"
    case grape = "Grape"
    case kiwi = "Kiwi"
    
    var console: Console {
        switch self {
        case .cytrus:
            .n3ds
        case .grape:
            .nds
        case .kiwi:
            .nes
        }
    }
    
    static let cores: [Core] = [.cytrus, .grape, .kiwi]
}
