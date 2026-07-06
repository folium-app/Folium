//
//  GrapeGame.swift
//  Folium
//
//  Created by Jarrod Norwell on 21/6/2026.
//

import Foundation
import Grape

nonisolated
final class GrapeGame : Game, Comparable, @unchecked Sendable {
    let details: Details
    let grapeSystem: GrapeSystem
    let system: System
    
    var boxart: UnsafeMutablePointer<UInt32>
    
    init(details: Details, grapeSystem: GrapeSystem, system: System, boxart: UnsafeMutablePointer<UInt32>) {
        self.details = details
        self.grapeSystem = grapeSystem
        self.system = system
        
        self.boxart = boxart
        super.init()
    }
    
    required init(from decoder: any Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    var prefix: String {
        details.name.prefix(1).capitalized
    }
    
    static func < (lhs: borrowing GrapeGame, rhs: borrowing GrapeGame) -> Bool {
        lhs.details.name.localizedCaseInsensitiveCompare(rhs.details.name) == .orderedAscending
    }
}
