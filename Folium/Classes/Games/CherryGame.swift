//
//  CherryGame.swift
//  Folium
//
//  Created by Jarrod Norwell on 9/8/2026.
//

import Cherry
import Foundation

nonisolated final class CherryGame : Game, Comparable, @unchecked Sendable {
    let cherrySystem: CherrySystem
    let details: Details
    let system: System
    
    var boxartURLString: String? = nil
    
    init(_ cherrySystem: CherrySystem, _ url: URL, _ system: System, _ boxartURLString: String? = nil) {
        self.cherrySystem = cherrySystem
        self.details = Details(url)
        self.system = system
        
        self.boxartURLString = boxartURLString
        super.init()
    }
    
    required init(from decoder: any Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    var prefix: String {
        details.fileName.prefix(1).capitalized
    }
    
    static func < (lhs: borrowing CherryGame, rhs: borrowing CherryGame) -> Bool {
        lhs.details.fileName.localizedCaseInsensitiveCompare(rhs.details.fileName) == .orderedAscending
    }
}
