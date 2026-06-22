//
//  Extension.swift
//  Folium
//
//  Created by Jarrod Norwell on 17/6/2026.
//

import Foundation

enum Extension : String, @unchecked Sendable {
    case cue = "cue"
    case gba = "gba"
    
    nonisolated var string: String { rawValue }
}
