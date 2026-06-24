//
//  SystemFileType.swift
//  Folium
//
//  Created by Jarrod Norwell on 19/6/2026.
//

import ColourKit
import UIKit

enum SystemFileType : Int {
    case optional = 0,
         required = 1
    
    var string: String {
        switch self {
        case .optional:
            "Optional"
        case .required:
            "Required"
        }
    }
    
    var tintColor: UIColour {
        switch self {
        case .optional:
            UIColour.systemOrange
        case .required:
            UIColour.systemRed
        }
    }
}
