//
//  MangoGame.swift
//  Folium
//
//  Created by Jarrod Norwell on 21/6/2026.
//

import Foundation
import Mango

nonisolated
final class MangoGame : Game, Comparable, @unchecked Sendable {
    let details: Details
    let mangoSystem: MangoSystem
    let system: System
    
    var boxartURLString: String? = nil
    
    init(details: Details, mangoSystem: MangoSystem, system: System, boxartURLString: String? = nil) {
        self.details = details
        self.mangoSystem = mangoSystem
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
    
    static func < (lhs: borrowing MangoGame, rhs: borrowing MangoGame) -> Bool {
        lhs.details.name.localizedCaseInsensitiveCompare(rhs.details.name) == .orderedAscending
    }
}
