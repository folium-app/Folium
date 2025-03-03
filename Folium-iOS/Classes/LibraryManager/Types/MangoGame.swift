//
//  MangoGame.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 2/3/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Foundation
import Mango

class MangoGame : GameBase, @unchecked Sendable {
    var icon: URL? = nil
    var data: Data? = nil
    
    init(icon: URL? = nil, core: String, fileDetails: GameBase.FileDetails, skins: [Skin], title: String) {
        self.icon = icon
        super.init(core: core, fileDetails: fileDetails, skins: skins, title: title)
    }
    
    static func icon(for url: URL) throws -> URL? {
        let region = Mango.shared.regionForCartridge(at: url)
        let title = title(for: url, true)
        
        if region.isEmpty || region == "" {
            return nil
        } else {
            if let imageURL = URL(string: "https://raw.githubusercontent.com/libretro/libretro-thumbnails/refs/heads/master/Nintendo - Super Nintendo Entertainment System/Named_Boxarts/\(title) (\(region)).png") {
                return imageURL
            } else {
                return nil
            }
        }
    }
    
    static func title(for url: URL, _ fromFileName: Bool = false) -> String {
        if fromFileName {
            url.deletingPathExtension().lastPathComponent
        } else {
            Mango.shared.titleForCartridge(at: url)
        }
    }
}
