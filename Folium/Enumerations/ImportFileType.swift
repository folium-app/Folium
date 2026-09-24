//
//  ImportFileType.swift
//  Folium
//
//  Created by Jarrod Norwell on 26/6/2026.
//

import Foundation

enum ImportFileType {
    case game,
         system
    
    var directory: String {
        switch self {
        case .game:
            "games"
        case .system:
            "system_data"
        }
    }
}
