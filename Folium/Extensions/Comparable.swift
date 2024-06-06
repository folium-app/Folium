//
//  Comparable.swift
//  Folium
//
//  Created by Jarrod Norwell on 5/6/2024.
//

import Foundation

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
