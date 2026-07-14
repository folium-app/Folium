//
//  AspectRatioManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 3/7/2026.
//

import Foundation

typealias AspectRatio = (top: (portrait: CGFloat, landscape: CGFloat), bottom: (portrait: CGFloat, landscape: CGFloat))
struct AspectRatioManager {
    static let cytrus: AspectRatio = ((3.0 / 5.0, 5.0 / 3.0), (3.0 / 4.0, 4.0 / 3.0))
    static let grape: AspectRatio = ((3.0 / 4.0, 4.0 / 3.0), (3.0 / 4.0, 4.0 / 3.0))
    static let kiwi: AspectRatio = ((9.0 / 10.0, 10.0 / 9.0), (9.0 / 10.0, 10.0 / 9.0))
    static let mandarine: AspectRatio = ((3.0 / 4.0, 4.0 / 3.0), (3.0 / 4.0, 4.0 / 3.0))
    static let tomato: AspectRatio = ((3.0 / 4.0, 4.0 / 3.0), (3.0 / 4.0, 4.0 / 3.0))
    
    static func aspectRatio(for system: System) -> AspectRatio {
        switch system {
        case .cytrus:
            cytrus
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
