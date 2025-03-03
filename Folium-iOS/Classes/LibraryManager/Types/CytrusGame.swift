//
//  CytrusGame.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 2/3/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Cytrus
import Foundation

class CytrusGame : GameBase, @unchecked Sendable {
    var icon: Data? = nil
    var identifier: UInt64? = nil
    
    static fileprivate let cytrus = Cytrus.shared
    
    init(icon: Data? = nil, identifier: UInt64? = nil, core: String, fileDetails: GameBase.FileDetails, skins: [Skin], title: String) {
        self.icon = icon
        self.identifier = identifier
        super.init(core: core, fileDetails: fileDetails, skins: skins, title: title)
    }
    
    static func icon(for url: URL) throws -> Data? { cytrus.information(for: url).icon }
    static func identifier(for url: URL) throws -> UInt64 { cytrus.information(for: url).identifier }
    static func title(for url: URL) throws -> String { cytrus.information(for: url).title }
}
