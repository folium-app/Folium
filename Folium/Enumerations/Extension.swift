//
//  Extension.swift
//  Folium
//
//  Created by Jarrod Norwell on 17/6/2026.
//

import Foundation

enum Extension : String, @unchecked Sendable {
    case cue = "cue"
    case gb = "gb"
    case gbc = "gbc"
    case gba = "gba"
    case nds = "nds"
    
    nonisolated var string: String { rawValue }
}
