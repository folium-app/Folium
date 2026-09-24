//
//  Feature.swift
//  Folium
//
//  Created by Jarrod Norwell on 17/6/2026.
//

import UIKit

enum Feature : String {
    case gameController = "Game Controller"
    
    var image: UIImage? {
        switch self {
        case .gameController:
            UIImage(systemName: "gamecontroller.fill")
        }
    }
    
    var string: String { rawValue }
}
