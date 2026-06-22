//
//  Sequence.swift
//  Folium
//
//  Created by Jarrod Norwell on 17/6/2026.
//

import Foundation

extension Sequence {
    func asyncForEach(_ operation: (Element) async throws -> Void) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
    
    func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        var result: [T] = []
        result.reserveCapacity(underestimatedCount)

        for element in self {
            result.append(try await transform(element))
        }

        return result
    }
    
    @inlinable
    func mapUniqueBy<T, K: Hashable>(_ transform: (Element) throws -> T, key: (T) throws -> K) rethrows -> [T] {
        var seen = Set<K>()
        var result: [T] = []
        result.reserveCapacity(underestimatedCount)

        for element in self {
            let value = try transform(element)
            let k = try key(value)
            if seen.insert(k).inserted {
                result.append(value)
            }
        }
        return result
    }
}
