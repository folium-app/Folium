//
//  AspectRatioManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 3/7/2026.
//

import Foundation

typealias AspectRatio = (portrait: CGFloat, landscape: CGFloat)
struct AspectRatioManager {
    static let grape: AspectRatio = (3.0 / 4.0, 4.0 / 3.0)
    static let kiwi: AspectRatio = (9.0 / 10.0, 10.0 / 9.0)
    static let mandarine: AspectRatio = (3.0 / 4.0, 4.0 / 3.0)
    static let tomato: AspectRatio = (3.0 / 4.0, 4.0 / 3.0)
    
    static func aspectRatio(for system: System) -> AspectRatio {
        switch system {
        case .grape:
            grape
        case .kiwi:
            kiwi
        case .mandarine:
            mandarine
        case .tomato:
            tomato
        }
    }
}
