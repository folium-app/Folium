//
//  GrapeGame.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 2/3/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Foundation
import Grape

class GrapeGame : GameBase, @unchecked Sendable {
    let icon: UnsafeMutablePointer<UInt32>
    
    static fileprivate let grape = Grape.shared
    
    init(icon: UnsafeMutablePointer<UInt32>, core: String, fileDetails: GameBase.FileDetails, skins: [Skin], title: String) {
        self.icon = icon
        super.init(core: core, fileDetails: fileDetails, skins: skins, title: title)
    }
    
    static func icon(for url: URL) -> UnsafeMutablePointer<UInt32> { grape.information(for: url).icon }
    static func title(for url: URL) -> String { grape.information(for: url).title }
}
