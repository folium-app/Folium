//
//  KiwiGame.swift
//  Folium
//
//  Created by Jarrod Norwell on 21/6/2026.
//

import Foundation
import Kiwi

nonisolated
final class KiwiGame : Game, Comparable, @unchecked Sendable {
    enum ConsoleType {
        case gb, gbc
    }
    
    var consoleType: ConsoleType = .gb
    let details: Details
    let kiwiSystem: KiwiSystem
    let system: System
    
    var boxartURLString: String? = nil
    
    init(details: Details, kiwiSystem: KiwiSystem, system: System, boxartURLString: String? = nil) {
        self.consoleType = details.extension == "gb" ? .gb : .gbc
        self.details = details
        self.kiwiSystem = kiwiSystem
        self.system = system
        
        self.boxartURLString = boxartURLString
    }
    
    var prefix: String {
        details.name.prefix(1).capitalized
    }
    
    static func < (lhs: borrowing KiwiGame, rhs: borrowing KiwiGame) -> Bool {
        lhs.details.name.localizedCaseInsensitiveCompare(rhs.details.name) == .orderedAscending
    }
}
