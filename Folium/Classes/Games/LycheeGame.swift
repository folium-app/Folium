//
//  LycheeGame.swift
//  Folium
//
//  Created by Jarrod Norwell on 21/6/2026.
//

import Foundation
import Lychee

nonisolated
final class LycheeGame : Game, Comparable, @unchecked Sendable {
    let details: Details
    let lycheeSystem: LycheeSystem
    let system: System
    
    var boxartURLString: String? = nil
    
    init(details: Details, lycheeSystem: LycheeSystem, system: System, boxartURLString: String? = nil) {
        self.details = details
        self.lycheeSystem = lycheeSystem
        self.system = system
        
        self.boxartURLString = boxartURLString
        super.init()
    }
    
    required init(from decoder: any Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    var prefix: String {
        details.name.prefix(1).capitalized
    }
    
    static func < (lhs: borrowing LycheeGame, rhs: borrowing LycheeGame) -> Bool {
        lhs.details.name.localizedCaseInsensitiveCompare(rhs.details.name) == .orderedAscending
    }
}
