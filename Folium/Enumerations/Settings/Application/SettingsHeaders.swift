//
//  SettingsHeaders.swift
//  Folium
//
//  Created by Jarrod Norwell on 7/6/2026.
//

import Foundation
import SettingsKit

enum SettingsHeaders : String, CaseIterable {
    case general = "General"
    case graphicsGeneral = "Graphics.General"
    case graphicsResolution = "Graphics.Resolution"
    case soundGeneral = "Sound.General"
    case systemGeneral = "System.General"
    
    // Cytrus
    case coreGeneral = "Core.General"
    case debuggingGeneral = "Debugging.General"
    case graphics3D = "Graphics.3D"
    case graphicsShader = "Graphics.Shader"
    case systemRegion = "System.Region"
    
    // Tomato
    case cartridgeGeneral = "Cartridge.General"
    
    var header: SettingHeader {
        switch self {
        case .general:
            SettingHeader(text: rawValue)
        case .cartridgeGeneral,
                .coreGeneral,
                .debuggingGeneral,
                .graphics3D,
                .graphicsGeneral,
                .graphicsResolution,
                .graphicsShader,
                .soundGeneral,
                .systemGeneral,
                .systemRegion:
            SettingHeader(text: rawValue.components(separatedBy: ".").first,
                          secondaryText: rawValue.components(separatedBy: ".").last)
        }
    }
    
    static var allHeaders: [SettingHeader] { allCases.map { `case` in `case`.header } }
}
