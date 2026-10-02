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
        self.consoleType = details.fileExtension == "gb" ? .gb : .gbc
        self.details = details
        self.kiwiSystem = kiwiSystem
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
    
    static func < (lhs: borrowing KiwiGame, rhs: borrowing KiwiGame) -> Bool {
        lhs.details.fileName.localizedCaseInsensitiveCompare(rhs.details.fileName) == .orderedAscending
    }
}
