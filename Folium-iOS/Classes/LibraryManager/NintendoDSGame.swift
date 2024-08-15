//
//  NintendoDSGame.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 18/7/2024.
//

import Foundation
import Grape

// MARK: Class for the Nintendo DS core, Grape
class NintendoDSGame : GameBase, @unchecked Sendable {
    let icon: UnsafeMutablePointer<UInt32>
    
    init(icon: UnsafeMutablePointer<UInt32>, core: String, fileDetails: GameBase.FileDetails, title: String) {
        self.icon = icon
        super.init(core: core, fileDetails: fileDetails, title: title)
    }
    
    static func iconFromHeader(for url: URL) throws -> UnsafeMutablePointer<UInt32> {
        Grape.shared.informationForGame(at: url).icon
    }
    
    static func titleFromHeader(for url: URL) throws -> String {
        Grape.shared.informationForGame(at: url).title
    }
}
