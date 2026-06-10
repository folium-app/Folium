//
//  ApplicationSettingsItems.swift
//  Folium
//
//  Created by Jarrod Norwell on 7/6/2026.
//

import Foundation
import SettingsKit

enum ApplicationSettingsItems : String, CaseIterable {
    // General
    case autoResumeOnForeground = "folium.autoResumeOnForeground"
    
    var title: String {
        switch self {
        case .autoResumeOnForeground:
            "Auto Resume Emulation"
        }
    }
    
    var details: String? {
        switch self {
        case .autoResumeOnForeground:
            "Automatically resumes emulation when the application enters the foreground"
        }
    }
    
    func setting(_ delegate: SettingDelegate? = nil) -> BaseSetting {
        switch self {
        case .autoResumeOnForeground:
            BoolSetting(key: rawValue,
                        title: title,
                        details: details,
                        secondaryTitle: nil,
                        isEnabled: true,
                        value: UserDefaults.standard.bool(forKey: rawValue),
                        delegate: delegate)
        }
    }
    
    static func settings(_ header: SettingsHeaders) -> [ApplicationSettingsItems] {
        switch header {
        case .general:
            [
                .autoResumeOnForeground
            ]
        default:
            []
        }
    }
}
