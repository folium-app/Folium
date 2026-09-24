//
//  MandarineSettingsItems.swift
//  Folium
//
//  Created by Jarrod Norwell on 7/6/2026.
//

import Foundation
import SettingsKit

enum MandarineSettingsItems : String, CaseIterable {
    // Debugging (General)
    case logBios = "mandarine.logBios"
    case logCdrom = "mandarine.logCdrom"
    case logController = "mandarine.logController"
    case logDma = "mandarine.logDma"
    case logGpu = "mandarine.logGpu"
    case logGte = "mandarine.logGte"
    case logMdec = "mandarine.logMdec"
    case logMemoryCard = "mandarine.logMemoryCard"
    case logMemoryControl = "mandarine.logMemoryControl"
    case logSpu = "mandarine.logSpu"
    case logSystem = "mandarine.logSystem"
    
    // Graphics (General)
    case forceNTSC = "mandarine.forceNTSC"
    case forceWidescreen = "mandarine.forceWidescreen"
    case nativeTextureFormat = "mandarine.nativeTextureFormat"
    case vsync = "mandarine.vsync"
    case widescreen = "mandarine.widescreen"
    
    // Graphics (Resolution)
    case height = "mandarine.height"
    case width = "mandarine.width"
    
    // Sound (General)
    case soundEnabled = "mandarine.soundEnabled"
    
    // System (General)
    case extendedMemory = "mandarine.extendedMemory"
    case preserveState = "mandarine.preserveState"
    case timeTravel = "mandarine.timeTravel"
    
    var title: String {
        switch self {
        case .logBios:
            "Log BIOS"
        case .logCdrom:
            " Log CDROM"
        case .logController:
            "Log Controller"
        case .logDma:
            "Log DMA"
        case .logGpu:
            "Log GPU"
        case .logGte:
            "Log GTE"
        case .logMdec:
            "Log MDEC"
        case .logMemoryCard:
            "Log Memory Card"
        case .logMemoryControl:
            "Log Memory Control"
        case .logSpu:
            "Log SPU"
        case .logSystem:
            "Log System"
            
        case .forceNTSC:
            "Force NTSC"
        case .forceWidescreen:
            "Force Widescreen"
        case .nativeTextureFormat:
            "Native Texture Format"
        case .vsync:
            "Vertical Sync"
        case .widescreen:
            "Widescreen"
            
        case .height:
            "Height"
        case .width:
            "Width"
            
        case .soundEnabled:
            "Sound"
            
        case .extendedMemory:
            "Extended Memory"
        case .preserveState:
            "Preserve State"
        case .timeTravel:
            "Time Travel"
        }
    }
    
    var details: String? {
        switch self {
        case .logBios:
            ""
        case .logCdrom:
            ""
        case .logController:
            ""
        case .logDma:
            ""
        case .logGpu:
            ""
        case .logGte:
            ""
        case .logMdec:
            ""
        case .logMemoryCard:
            ""
        case .logMemoryControl:
            ""
        case .logSpu:
            ""
        case .logSystem:
            ""
            
        case .forceNTSC:
            "Force NTSC"
        case .forceWidescreen:
            "Force enable widescreen so the renderer outputs 16:9 in 3D"
        case .nativeTextureFormat:
            ""
        case .vsync:
            "Enable vertical sync so the renderer runs at the displays refresh rate"
        case .widescreen:
            "Enable widescreen so the renderer outputs 16:9 in 3D"
            
        case .height:
            "Sets the height at which the renderer will output to"
        case .width:
            "Sets the width at which the renderer will output to"
            
        case .soundEnabled:
            "Enable sound output"
            
        case .extendedMemory:
            "Extends the system memory to 8 MB"
        case .preserveState:
            ""
        case .timeTravel:
            ""
        }
    }
    
    func setting(_ delegate: SettingDelegate? = nil) -> BaseSetting {
        switch self {
        case .logBios,
                .logCdrom,
                .logController,
                .logDma,
                .logGpu,
                .logGte,
                .logMdec,
                .logMemoryCard,
                .logMemoryControl,
                .logSpu,
                .logSystem,
                .forceNTSC,
                .forceWidescreen,
                .nativeTextureFormat,
                .vsync,
                .widescreen,
                .soundEnabled,
                .extendedMemory,
                .preserveState,
                .timeTravel:
            BoolSetting(key: rawValue,
                        title: title,
                        details: details,
                        secondaryTitle: nil,
                        isEnabled: true,
                        value: UserDefaults.standard.bool(forKey: rawValue),
                        delegate: delegate)
        
        case .height,
                .width:
            InputNumberSetting(key: rawValue,
                               title: title,
                               details: details,
                               secondaryTitle: nil,
                               isEnabled: true,
                               min: self == .height ? 480 : 640,
                               max: self == .height ? 960 : 1280,
                               value: UserDefaults.standard.double(forKey: rawValue),
                               delegate: delegate)
        }
    }
    
    static func settings(_ header: SettingsHeaders) -> [MandarineSettingsItems] {
        switch header {
        case .debuggingGeneral:
            [
                .logBios,
                .logCdrom,
                .logController,
                .logDma,
                .logGpu,
                .logGte,
                .logMdec,
                .logMemoryCard,
                .logMemoryControl,
                .logSpu,
                .logSystem
            ]
        case .graphicsGeneral:
            [
                .forceNTSC,
                .forceWidescreen,
                .nativeTextureFormat,
                .vsync,
                .widescreen
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
                .extendedMemory,
                .preserveState,
                .timeTravel
            ]
        default:
            []
        }
    }
}
