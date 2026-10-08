//
//  SettingsHeaders.swift
//  Folium
//
//  Created by Jarrod Norwell on 7/6/2026.
//

import Foundation
import SettingsKit

enum SettingsHeaders : String, CaseIterable {
    case debuggingGeneral = "Debugging.General"
    case general = "General"
    case graphicsGeneral = "Graphics.General"
    case graphicsResolution = "Graphics.Resolution"
    case libraryGeneral = "Library.General"
    case premiumExtraFeatures = "Premium.Extra Features"
    case soundGeneral = "Sound.General"
    case systemGeneral = "System.General"
    
    // Cytrus
    case coreGeneral = "Core.General"
    case graphics3D = "Graphics.3D"
    case graphicsShader = "Graphics.Shader"
    case graphicsTexture = "Graphics.Texture"
    case graphicsTimingSimulation = "Graphics.Simulation & Timing"
    case systemRegion = "System.Region"
    case webAPI = "Web API"
    
    var header: SettingHeader {
        switch self {
        case .general,
                .webAPI:
            SettingHeader(text: rawValue)
        case .coreGeneral,
                .debuggingGeneral,
                .graphics3D,
                .graphicsGeneral,
                .graphicsResolution,
                .graphicsShader,
                .graphicsTexture,
                .graphicsTimingSimulation,
                .libraryGeneral,
                .premiumExtraFeatures,
                .soundGeneral,
                .systemGeneral,
                .systemRegion:
            SettingHeader(text: rawValue.components(separatedBy: ".").first,
                          secondaryText: rawValue.components(separatedBy: ".").last)
        }
    }
    
    static var allHeaders: [SettingHeader] { allCases.map { `case` in `case`.header } }
    
    static var cytrusHeaders: [SettingsHeaders] {
        [
            .coreGeneral,
            .debuggingGeneral,
            .graphics3D,
            .graphicsGeneral,
            .graphicsResolution,
            .graphicsShader,
            .graphicsTexture,
            .graphicsTimingSimulation,
            .soundGeneral,
            .systemGeneral,
            .systemRegion,
            .webAPI
        ]
    }
    
    static var durianHeaders: [SettingsHeaders] {
        [
            .coreGeneral,
            .graphicsGeneral
        ]
    }
    
    static var grapeHeaders: [SettingsHeaders] {
        [
            .general,
            .coreGeneral
        ]
    }
    
    static var kiwiHeaders: [SettingsHeaders] {
        [
            .graphicsGeneral
        ]
    }
    
    static var mandarineHeaders: [SettingsHeaders] {
        [
            .debuggingGeneral,
            .graphicsGeneral,
            .graphicsResolution,
            .soundGeneral,
            .systemGeneral
        ]
    }
    
    static var tomatoHeaders: [SettingsHeaders] {
        [
            .general,
            .graphicsGeneral
        ]
    }
}
