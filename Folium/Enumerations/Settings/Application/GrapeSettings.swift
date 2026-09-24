//
//  GrapeSettings.swift
//  Folium
//
//  Created by Jarrod Norwell on 11/6/2026.
//

import Foundation
import SettingsKit

enum GrapeSettingsItems : String, CaseIterable {
    // General
    case skipBootScreen = "grape.skipBootScreen"
    
    // Core (General)
    case consoleModel = "grape.consoleModel"
    
    var title: String {
        switch self {
        case .skipBootScreen:
            "Skip Boot Screen"
        case .consoleModel:
            "Console Model"
        }
    }
    
    var secondaryTitle: String? {
        switch self {
        case .consoleModel:
            "DSi requires DSi system files"
        default:
            nil
        }
    }
    
    var details: String? {
        switch self {
        case .skipBootScreen:
            nil
            
        case .consoleModel:
            "Sets whether to emulate the Nintendo DS or DSi"
        }
    }
    
    func setting(_ delegate: SettingDelegate? = nil) -> BaseSetting {
        switch self {
        case .skipBootScreen:
            BoolSetting(key: rawValue,
                        title: title,
                        details: details,
                        secondaryTitle: nil,
                        isEnabled: true,
                        value: UserDefaults.standard.bool(forKey: rawValue),
                        delegate: delegate)
            
        case .consoleModel:
            SelectionSetting(key: rawValue,
                             title: title,
                             details: details,
                             secondaryTitle: secondaryTitle,
                             values: [
                                "DS" : 0,
                                "DSi" : 1
                             ],
                             selectedValue: UserDefaults.standard.integer(forKey: rawValue),
                             action: {},
                             delegate: delegate)
        }
    }
    
    static func settings(_ header: SettingsHeaders) -> [GrapeSettingsItems] {
        switch header {
        case .general:
            [
                .skipBootScreen
            ]
        case .coreGeneral:
            [
                .consoleModel
            ]
        default:
            []
        }
    }
}
