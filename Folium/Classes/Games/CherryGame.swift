//
//  CherryGame.swift
//  Folium
//
//  Created by Jarrod Norwell on 9/8/2026.
//

import Cherry
import Foundation

nonisolated
final class CherryGame : Game, Comparable, @unchecked Sendable {
    let details: Details
    let cherrySystem: CherrySystem
    let system: System
    
    var boxartURLString: String? = nil
    
    init(details: Details, cherrySystem: CherrySystem, system: System, boxartURLString: String? = nil) {
        self.details = details
        self.cherrySystem = cherrySystem
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
    
    static func < (lhs: borrowing CherryGame, rhs: borrowing CherryGame) -> Bool {
        lhs.details.name.localizedCaseInsensitiveCompare(rhs.details.name) == .orderedAscending
    }
}
