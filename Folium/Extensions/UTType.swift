//
//  UTType.swift
//  Folium
//
//  Created by Jarrod Norwell on 24/6/2026.
//

import UniformTypeIdentifiers

extension UTType {
    // Common
    static let bin: UTType? = UTType(filenameExtension: "bin")
    static let chd: UTType? = UTType(filenameExtension: "chd")
    static let cue: UTType? = UTType(filenameExtension: "cue")
    static let img: UTType? = UTType(filenameExtension: "img")
    static let iso: UTType? = UTType(filenameExtension: "iso")
    
    // Cherry (Coleco - ColecoVision)
    static let col: UTType? = UTType(filenameExtension: "col")
    static let rom: UTType? = UTType(filenameExtension: "rom")
    
    // Cytrus (Nintendo - Nintendo 3DS)
    static let `3ds`: UTType? = UTType(filenameExtension: "3ds")
    static let cci: UTType? = UTType(filenameExtension: "cci")
    static let cxi: UTType? = UTType(filenameExtension: "cxi")
    
    // Durian (Bandai - WonderSwan, Bandai - WonderSwan Color)
    static let ws: UTType? = UTType(filenameExtension: "ws")
    static let wsc: UTType? = UTType(filenameExtension: "wsc")
    
    // Grape (Nintendo - Nintendo DS)
    static let dsi: UTType? = UTType(filenameExtension: "dsi")
    static let nds: UTType? = UTType(filenameExtension: "nds")
    
    // Kiwi - (Nintendo - Game Boy, Nintendo - Game Boy Color)
    static let gb: UTType? = UTType(filenameExtension: "gb")
    static let gbc: UTType? = UTType(filenameExtension: "gbc")
    
    // Lychee (Nintendo - Super Nintendo Entertainment System)
    static let sfc: UTType? = UTType(filenameExtension: "sfc")
    static let smc: UTType? = UTType(filenameExtension: "smc")
    
    // Mango (Nintendo - Nintendo Entertainment System)
    static let nes: UTType? = UTType(filenameExtension: "nes")
    
    // Plum (SEGA - SEGA Genesis, SEGA - SEGA Mega Drive)
    static let gen: UTType? = UTType(filenameExtension: "gen")
    static let md: UTType? = UTType(filenameExtension: "md")
    
    // Tomato (Nintendo - Game Boy Advance)
    static let gba: UTType? = UTType(filenameExtension: "gba")
}
