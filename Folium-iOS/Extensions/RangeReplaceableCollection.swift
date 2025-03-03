//
//  Array.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 2/3/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Foundation

extension RangeReplaceableCollection where Element == Core {
    mutating func appendUnique(_ element: Element) {
        if !contains(element) {
            append(element)
        }
    }
}
