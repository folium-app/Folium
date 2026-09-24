//
//  DurianGame.swift
//  Folium
//
//  Created by Jarrod Norwell on 21/6/2026.
//

import Foundation
import Durian

nonisolated
final class DurianGame : Game, Comparable, @unchecked Sendable {
    let details: Details
    let durianSystem: DurianSystem
    let system: System
    
    var boxartURLString: String? = nil
    
    init(details: Details, durianSystem: DurianSystem, system: System, boxartURLString: String? = nil) {
        self.details = details
        self.durianSystem = durianSystem
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
    
    static func < (lhs: borrowing DurianGame, rhs: borrowing DurianGame) -> Bool {
        lhs.details.name.localizedCaseInsensitiveCompare(rhs.details.name) == .orderedAscending
    }
}
