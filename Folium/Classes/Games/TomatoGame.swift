//
//  TomatoGame.swift
//  Folium
//
//  Created by Jarrod Norwell on 21/6/2026.
//

import Foundation
import Tomato

nonisolated
final class TomatoGame : Game, Comparable, @unchecked Sendable {
    let details: Details
    let tomatoSystem: TomatoSystem
    let system: System
    
    var boxartURLString: String? = nil
    
    init(details: Details, tomatoSystem: TomatoSystem, system: System, boxartURLString: String? = nil) {
        self.details = details
        self.tomatoSystem = tomatoSystem
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
    
    static func < (lhs: borrowing TomatoGame, rhs: borrowing TomatoGame) -> Bool {
        lhs.details.name.localizedCaseInsensitiveCompare(rhs.details.name) == .orderedAscending
    }
}
