//
//  KiwiSettings.swift
//  Folium
//
//  Created by Jarrod Norwell on 8/6/2026.
//

import Foundation
import SettingsKit

enum KiwiSettingsItems : String, CaseIterable {
    // Graphics (General)
    case adjustColours = "kiwi.adjustColours"
    case blendFrames = "kiwi.blendFrames"
    
    var title: String {
        switch self {
        case .adjustColours:
            "Adjust Colours"
        case .blendFrames:
            "Blend Frames"
        }
    }
    
    var secondaryTitle: String? {
        switch self {
        case .adjustColours:
            "Game Boy Color only"
        default:
            nil
        }
    }
    
    var details: String? {
        nil
    }
    
    func setting(_ delegate: SettingDelegate? = nil) -> BaseSetting {
        switch self {
        case .adjustColours,
                .blendFrames:
            BoolSetting(key: rawValue,
                        title: title,
                        details: details,
                        secondaryTitle: secondaryTitle,
                        isEnabled: true,
                        value: UserDefaults.standard.bool(forKey: rawValue),
                        delegate: delegate)
        }
    }
    
    static func settings(_ header: SettingsHeaders) -> [KiwiSettingsItems] {
        switch header {
        case .graphicsGeneral:
            [
                .adjustColours,
                .blendFrames
            ]
        default:
            []
        }
    }
}
