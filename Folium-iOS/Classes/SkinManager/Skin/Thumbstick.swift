//
//  Thumbstick.swift
//  Folium
//
//  Created by Jarrod Norwell on 13/6/2024.
//

import Foundation

struct Thumbstick : Codable, Hashable {
    enum `Type` : String, Codable, Hashable {
        case left = "left"
        case right = "right"
    }
    
    var backgroundImageName: String? = nil
    let x, y: Double
    let width, height: Double
    let type: `Type`
}
