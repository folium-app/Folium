//
//  MandarineGame.swift
//  Folium
//
//  Created by Jarrod Norwell on 17/6/2026.
//

import Foundation
import Mandarine

nonisolated
final class MandarineGame : Game, Comparable, @unchecked Sendable {
    let details: Details
    let mandarineSystem: MandarineSystem
    let system: System
    
    var boxartURLString: String? = nil
    
    init(details: Details, mandarineSystem: MandarineSystem, system: System, boxartURLString: String? = nil) {
        self.details = details
        self.mandarineSystem = mandarineSystem
        self.system = system
        
        self.boxartURLString = boxartURLString
    }
    
    var prefix: String {
        details.name.prefix(1).capitalized
    }
    
    static func < (lhs: borrowing MandarineGame, rhs: borrowing MandarineGame) -> Bool {
        lhs.details.name.localizedCaseInsensitiveCompare(rhs.details.name) == .orderedAscending
    }
}
