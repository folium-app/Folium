//
//  TomatoSettings.swift
//  Folium
//
//  Created by Jarrod Norwell on 8/6/2026.
//

import Foundation
import SettingsKit

enum TomatoSettingsItems : String, CaseIterable {
    // General
    case skipBootScreen = "tomato.skipBootScreen"
    
    // Graphics (General)
    case adjustColours = "tomato.adjustColours"
    case blendFrames = "tomato.blendFrames"
    case frameSkipping = "tomato.frameSkipping"
    
    var title: String {
        switch self {
        case .skipBootScreen:
            "Skip Boot Screen"
            
        case .adjustColours:
            "Adjust Colours"
        case .blendFrames:
            "Blend Frames"
        case .frameSkipping:
            "Frame Skipping"
        }
    }
    
    var details: String? {
        nil
    }
    
    func setting(_ delegate: SettingDelegate? = nil) -> BaseSetting {
        switch self {
        case .skipBootScreen,
                .adjustColours,
                .blendFrames,
                .frameSkipping:
            BoolSetting(key: rawValue,
                        title: title,
                        details: details,
                        secondaryTitle: nil,
                        isEnabled: true,
                        value: UserDefaults.standard.bool(forKey: rawValue),
                        delegate: delegate)
        }
    }
    
    static func settings(_ header: SettingsHeaders) -> [TomatoSettingsItems] {
        switch header {
        case .general:
            [
                .skipBootScreen
            ]
        case .graphicsGeneral:
            [
                .adjustColours,
                .blendFrames,
                .frameSkipping
            ]
        default:
            []
        }
    }
}
