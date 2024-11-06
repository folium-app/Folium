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
    let icon: Data?
    let titleIdentifier: UInt64
    
    init(icon: Data? = nil, core: String, fileDetails: GameBase.FileDetails, skins: [Skin], title: String, titleIdentifier: UInt64) {
        self.icon = icon
        self.titleIdentifier = titleIdentifier
        super.init(core: core, fileDetails: fileDetails, skins: skins, title: title)
    }
    
    static func iconFromHeader(for url: URL) throws -> Data? {
        Cytrus.shared.informationForGame(at: url).icon
    }
    
    static func titleFromHeader(for url: URL) throws -> String {
        Cytrus.shared.informationForGame(at: url).title
    }
    
    static func titleIdentifierFromHeader(for url: URL) throws -> UInt64 {
        Cytrus.shared.informationForGame(at: url).titleIdentifier
    }
}
