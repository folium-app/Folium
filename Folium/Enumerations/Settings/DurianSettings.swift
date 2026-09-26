//
//  DurianSettings.swift
//  Folium
//
//  Created by Jarrod Norwell on 8/6/2026.
//

import Foundation
import SettingsKit

enum DurianSettingsItems : String, CaseIterable {
    // Core (General)
    case consoleModel = "durian.consoleModel"
    
    // Graphics (General)
    case adjustColours = "durian.adjustColours"
    case blendFrames = "durian.blendFrames"
    case showIcons = "durian.showIcons"
    
    var title: String {
        switch self {
        case .consoleModel:
            "Console Model"
            
        case .adjustColours:
            "Adjust Colours"
        case .blendFrames:
            "Blend Frames"
        case .showIcons:
            "Show Icons"
        }
    }
    
    var details: String? {
        nil
    }
    
    func setting(_ delegate: SettingDelegate? = nil) -> BaseSetting {
        switch self {
        case .adjustColours,
                .blendFrames,
                .showIcons:
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
                             secondaryTitle: nil,
                             values: [
                                "Automatic" : 0,
                                "Monochrome" : 1,
                                "Color" : 2,
                                "Swan Crystal" : 3,
                                "Pocket Challenge" : 4
                             ],
                             selectedValue: UserDefaults.standard.integer(forKey: rawValue),
                             action: {},
                             delegate: delegate)
        }
    }
    
    static func settings(_ header: SettingsHeaders) -> [DurianSettingsItems] {
        switch header {
        case .coreGeneral:
            [
                .consoleModel
            ]
        case .graphicsGeneral:
            [
                .adjustColours,
                .blendFrames,
                .showIcons
            ]
        default:
            []
        }
    }
}
