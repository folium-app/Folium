//
//  GrapeSettings.swift
//  Folium
//
//  Created by Jarrod Norwell on 11/6/2026.
//

import Foundation
import SettingsKit

enum GrapeSettingsItems : String, CaseIterable {
    // Core (General)
    case consoleModel = "grape.consoleModel"
    
    var title: String {
        switch self {
        case .consoleModel:
            "Console Model"
        }
    }
    
    var details: String? {
        switch self {
        case .consoleModel:
            "Sets whether to emulate the Nintendo DS or DSi"
        }
    }
    
    func setting(_ delegate: SettingDelegate? = nil) -> BaseSetting {
        switch self {
        case .consoleModel:
            SegmentedSetting(key: rawValue,
                             title: title,
                             details: details,
                             values: [
                                "DS" : 0,
                                "DSi" : 1
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: { viewController in },
                             delegate: delegate)
        }
    }
    
    static func settings(_ header: SettingsHeaders) -> [GrapeSettingsItems] {
        switch header {
        case .coreGeneral:
            [
                .consoleModel
            ]
        default:
            []
        }
    }
}
