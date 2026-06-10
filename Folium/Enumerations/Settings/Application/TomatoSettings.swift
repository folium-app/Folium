//
//  TomatoSettings.swift
//  Folium
//
//  Created by Jarrod Norwell on 8/6/2026.
//

import Foundation
import SettingsKit

enum TomatoSettingsItems : String, CaseIterable {
    // Cartridge (General)
    case backupType = "tomato.backupType"
    case forceRTC = "tomato.forceRTC"
    case forceSolarSensor = "tomato.forceSolarSensor"
    case solarSensorLevel = "tomato.solarSensorLevel"
    
    // General
    case skipBIOS = "tomato.skipBIOS"
    
    // Graphics (General)
    case colourCorrection = "tomato.colourCorrection"
    case filter = "tomato.filter"
    case lcdGhosting = "tomato.lcdGhosting"
    
    // Sound (General)
    case interpolation = "tomato.interpolation"
    case volume = "tomato.volume"
    
    var title: String {
        switch self {
        case .backupType:
            "Backup Type"
        case .forceRTC:
            "Force RTC"
        case .forceSolarSensor:
            "Force Solar Sensor"
        case .solarSensorLevel:
            "Solar Sensor Level"
            
        case .skipBIOS:
            "Skip BIOS"
            
        case .colourCorrection:
            "Colour Correction"
        case .filter:
            "Filter"
        case .lcdGhosting:
            "LCD Ghosting"
            
        case .interpolation:
            "Interpolation"
        case .volume:
            "Volume"
        }
    }
    
    var details: String? {
        nil
    }
    
    func setting(_ delegate: SettingDelegate? = nil) -> BaseSetting {
        switch self {
        case .skipBIOS,
                .forceRTC,
                .forceSolarSensor,
                .lcdGhosting:
            BoolSetting(key: rawValue,
                        title: title,
                        details: details,
                        secondaryTitle: nil,
                        isEnabled: true,
                        value: UserDefaults.standard.bool(forKey: rawValue),
                        delegate: delegate)
            
        case .volume,
                .solarSensorLevel:
            InputNumberSetting(key: rawValue,
                               title: title,
                               details: details,
                               secondaryTitle: nil,
                               isEnabled: true,
                               min: 0,
                               max: 100,
                               value: UserDefaults.standard.double(forKey: rawValue),
                               delegate: delegate)
            
        case .colourCorrection:
            SelectionSetting(key: rawValue,
                             title: title,
                             details: details,
                             values: [
                                "None" : 0,
                                "higan" : 1,
                                "AGB" : 2
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
            
        case .filter:
            SelectionSetting(key: rawValue,
                             title: title,
                             details: details,
                             values: [
                                "Nearest" : 0,
                                "Linear" : 1,
                                "Sharp" : 2,
                                "xBRZ" : 3,
                                "LCD1x" : 4
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
            
        case .interpolation:
            SelectionSetting(key: rawValue,
                             title: title,
                             details: details,
                             values: [
                                "Cosine" : 0,
                                "Cubic" : 1,
                                "Sinc 64" : 2,
                                "Sinc 128" : 3,
                                "Sinc 256" : 4
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
            
        case .backupType:
            SelectionSetting(key: rawValue,
                             title: title,
                             details: details,
                             values: [
                                "Detect" : 0,
                                "None" : 1,
                                "SRAM" : 2,
                                "FLASH 64" : 3,
                                "FLASH 128" : 4,
                                "EEPROM 4" : 5,
                                "EEPROM 64" : 6
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
        }
    }
    
    static func settings(_ header: SettingsHeaders) -> [TomatoSettingsItems] {
        switch header {
        case .cartridgeGeneral:
            [
                .backupType,
                .forceRTC,
                .forceSolarSensor,
                .solarSensorLevel
            ]
        case .general:
            [
                .skipBIOS
            ]
        case .graphicsGeneral:
            [
                .colourCorrection,
                .filter,
                .lcdGhosting
            ]
        case .soundGeneral:
            [
                .interpolation,
                .volume
            ]
        default:
            []
        }
    }
}
