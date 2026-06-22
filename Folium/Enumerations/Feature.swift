//
//  Feature.swift
//  Folium
//
//  Created by Jarrod Norwell on 17/6/2026.
//

import UIKit

@MainActor
enum Feature : String, @unchecked Sendable {
    case gameController = "Game Controller"
    
    var image: UIImage? {
        switch self {
        case .gameController:
            UIImage(systemName: "gamecontroller.fill")
        }
    }
    
    var string: String { rawValue }
}
