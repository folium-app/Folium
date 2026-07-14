//
//  CytrusGame.swift
//  Folium
//
//  Created by Jarrod Norwell on 13/7/2026.
//

import Foundation
import Cytrus

nonisolated
final class CytrusGame : Game, Comparable, @unchecked Sendable {
    let details: Details
    let cytrusSystem: CytrusSystem
    let system: System
    
    var boxart: NSData
    
    init(details: Details, cytrusSystem: CytrusSystem, system: System, boxart: NSData) {
        self.details = details
        self.cytrusSystem = cytrusSystem
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
    
    static func < (lhs: borrowing CytrusGame, rhs: borrowing CytrusGame) -> Bool {
        lhs.details.name.localizedCaseInsensitiveCompare(rhs.details.name) == .orderedAscending
    }
}
