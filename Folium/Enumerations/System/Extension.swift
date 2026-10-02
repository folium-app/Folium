//
//  Extension.swift
//  Folium
//
//  Created by Jarrod Norwell on 17/6/2026.
//

import Foundation

enum Extension : String {
    // Common
    case chd = "chd"
    case cue = "cue"
    case img = "img"
    case iso = "iso"
    nonisolated static let mandarine: [Extension] = [.chd, .cue, .img, .iso]
    
    // Cherry (Coleco - ColecoVision)
    case col = "col"
    case rom = "rom"
    nonisolated static let cherry: [Extension] = [.col, .rom]
    
    // Cytrus (Nintendo - Nintendo 3DS)
    case `3ds` = "3ds"
    case cci = "cci"
    case cxi = "cxi"
    nonisolated static let cytrus: [Extension] = [.`3ds`, .cci, .cxi]
    
    // Durian (Bandai - WonderSwan, Bandai - WonderSwan Color)
    case ws = "ws"
    case wsc = "wsc"
    nonisolated static let durian: [Extension] = [.ws, .wsc]
    
    // Grape (Nintendo - Nintendo DS)
    case dsi = "dsi"
    case nds = "nds"
    nonisolated static let grape: [Extension] = [.dsi, .nds]
    
    // Kiwi - (Nintendo - Game Boy, Nintendo - Game Boy Color)
    case gb = "gb"
    case gbc = "gbc"
    nonisolated static let kiwi: [Extension] = [.gb, .gbc]
    
    // Lychee (Nintendo - Super Nintendo Entertainment System)
    case sfc = "sfc"
    case smc = "smc"
    nonisolated static let lychee: [Extension] = [.sfc, .smc]
    
    // Mango (Nintendo - Nintendo Entertainment System)
    case nes = "nes"
    nonisolated static let mango: [Extension] = [.nes]
    
    // Plum (SEGA - SEGA Genesis, SEGA - SEGA Mega Drive)
    case gen = "gen"
    case md = "md"
    nonisolated static let plum: [Extension] = [.gen, .md]
    
    // Tomato (Nintendo - Game Boy Advance)
    case gba = "gba"
    nonisolated static let tomato: [Extension] = [.gba]
    
    nonisolated var string: String { rawValue }
}
