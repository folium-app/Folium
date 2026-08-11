//
//  AspectRatioManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 3/7/2026.
//

import Foundation

typealias AspectRatio = (top: (portrait: CGFloat, landscape: CGFloat), bottom: (portrait: CGFloat, landscape: CGFloat))
struct AspectRatioManager {
    static let cherry: AspectRatio = ((3.0 / 4.0, 4.0 / 3.0), (3.0 / 4.0, 4.0 / 3.0))
    static let cytrus: AspectRatio = ((3.0 / 5.0, 5.0 / 3.0), (3.0 / 4.0, 4.0 / 3.0))
    static let grape: AspectRatio = ((3.0 / 4.0, 4.0 / 3.0), (3.0 / 4.0, 4.0 / 3.0))
    static let kiwi: AspectRatio = ((9.0 / 10.0, 10.0 / 9.0), (9.0 / 10.0, 10.0 / 9.0))
    static let mandarine: AspectRatio = ((3.0 / 4.0, 4.0 / 3.0), (3.0 / 4.0, 4.0 / 3.0))
    static let tomato: AspectRatio = ((3.0 / 4.0, 4.0 / 3.0), (3.0 / 4.0, 4.0 / 3.0))
    
    static func aspectRatio(for system: System) -> AspectRatio {
        switch system {
        case .cherry:
            AspectRatioManager.cherry
        case .cytrus:
            AspectRatioManager.cytrus
        case .grape:
            AspectRatioManager.grape
        case .kiwi:
            AspectRatioManager.kiwi
        case .mandarine:
            AspectRatioManager.mandarine
        case .tomato:
            AspectRatioManager.tomato
        }
    }
}
