//
//  Nintendo3DSGame.swift
//
//
//  Created by Jarrod Norwell on 17/7/2024.
//

import Cytrus
import Foundation

// MARK: Class for the Nintendo 3DS core, Cytrus
class Nintendo3DSGame : GameBase, @unchecked Sendable {
    let icon: Data
    
    init(icon: Data, core: String, fileDetails: GameBase.FileDetails, title: String) {
        self.icon = icon
        super.init(core: core, fileDetails: fileDetails, title: title)
    }
    
    static func iconFromHeader(for url: URL) throws -> Data {
        Cytrus.shared.informationForGame(at: url).icon
    }
    
    static func titleFromHeader(for url: URL) throws -> String {
        Cytrus.shared.informationForGame(at: url).title
    }
}
