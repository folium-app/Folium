//
//  SystemNames.swift
//  Folium
//
//  Created by Jarrod Norwell on 25/6/2026.
//

import Foundation

struct SystemNames {
    static let array: [System] = System.allCases.self
    static let arrayAsString: [String] = array.map(\.string)
}
