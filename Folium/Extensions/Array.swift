//
//  Array.swift
//  Folium
//
//  Created by Jarrod Norwell on 20/6/2026.
//

import Foundation

extension Array {
    mutating func prepend(element: Element) {
        insert(element, at: 0)
    }
}
