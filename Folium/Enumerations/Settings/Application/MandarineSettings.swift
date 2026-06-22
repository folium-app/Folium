//
//  MandarineSettingsItems.swift
//  Folium
//
//  Created by Jarrod Norwell on 7/6/2026.
//

import Foundation
import SettingsKit

enum MandarineSettingsItems : String, CaseIterable {
    // Graphics (General)
    case widescreen = "mandarine.widescreen"
    case forceWidescreen = "mandarine.forceWidescreen"
    case vsync = "mandarine.vsync"
    case forceNTSC = "mandarine.forceNTSC"
    
    // Graphics (Resolution)
    case height = "mandarine.height"
    case width = "mandarine.width"
    
    // Sound (General)
    case soundEnabled = "mandarine.soundEnabled"
    
    // System (General)
    case extendedMemory = "mandarine.extendedMemory"
    
    var title: String {
        switch self {
        case .widescreen:
            "Widescreen"
        case .forceWidescreen:
            "Force Widescreen"
        case .vsync:
            "Vertical Sync"
        case .forceNTSC:
            "Force NTSC"
            
        case .height:
            "Height"
        case .width:
            "Width"
            
        case .soundEnabled:
            "Sound"
            
        case .extendedMemory:
            "Extended Memory"
        }
    }
    
    var details: String? {
        switch self {
        case .widescreen:
            "Enable widescreen so the renderer outputs 16:9 in 3D"
        case .forceWidescreen:
            "Force enable widescreen so the renderer outputs 16:9 in 3D"
        case .vsync:
            "Enable vertical sync so the renderer runs at the displays refresh rate"
        case .forceNTSC:
            "Force NTSC"
            
        case .height:
            "Sets the height at which the renderer will output to"
        case .width:
            "Sets the width at which the renderer will output to"
            
        case .soundEnabled:
            "Enable sound output"
            
        case .extendedMemory:
            "Extends the system memory to 8 MB"
        }
    }
    
    func setting(_ delegate: SettingDelegate? = nil) -> BaseSetting {
        switch self {
        case .widescreen,
                .forceWidescreen,
                .vsync,
                .forceNTSC,
                .soundEnabled,
                .extendedMemory:
            BoolSetting(key: rawValue,
                        title: title,
                        details: details,
                        secondaryTitle: self == .soundEnabled ? nil : "Unavailable for now",
                        isEnabled: self == .soundEnabled,
                        value: UserDefaults.standard.bool(forKey: rawValue),
                        delegate: delegate)
        
        case .height,
                .width:
            InputNumberSetting(key: rawValue,
                               title: title,
                               details: details,
                               secondaryTitle: self == .soundEnabled ? nil : "Unavailable for now",
                               isEnabled: false,
                               min: self == .height ? 480 : 640,
                               max: self == .height ? 960 : 1280,
                               value: UserDefaults.standard.double(forKey: rawValue),
                               delegate: delegate)
        }
    }
    
    static func settings(_ header: SettingsHeaders) -> [MandarineSettingsItems] {
        switch header {
        case .graphicsGeneral:
            [
                .widescreen,
                .forceWidescreen,
                .vsync,
                .forceNTSC
            ]
        case .graphicsResolution:
            [
                .height,
                .width
            ]
        case .soundGeneral:
            [
                .soundEnabled
            ]
        case .systemGeneral:
            [
                .extendedMemory
            ]
        default:
            []
        }
    }
}
