//
//  Game.swift
//  Folium
//
//  Created by Jarrod Norwell on 20/6/2026.
//

import Foundation

nonisolated
class Game : Codable, Equatable, Hashable, @unchecked Sendable {
    var id: UUID = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: borrowing Game, rhs: borrowing Game) -> Bool {
        lhs.id == rhs.id
    }
}
