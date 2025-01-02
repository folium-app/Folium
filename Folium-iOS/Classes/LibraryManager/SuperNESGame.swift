//
//  SuperNESGame.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 24/8/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation
import Mango

// MARK: Class for the Game Boy Advance core, Tomato
class SuperNESGame : GameBase, @unchecked Sendable {
    var icon: URL?
    var iconData: Data? = nil
    
    init(icon: URL? = nil, core: String, fileDetails: GameBase.FileDetails, skins: [Skin], title: String) {
        self.icon = icon
        super.init(core: core, fileDetails: fileDetails, skins: skins, title: title)
    }
    
    static func iconFromHeader(for url: URL) throws -> URL? {
        let region = Mango.shared.regionForCartridge(at: url)
        let title = try titleFromHeader(for: url, true)
        
        print(region, title)
        
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
    
    static func titleFromHeader(for url: URL, _ fromFileName: Bool = false) throws -> String {
        return if fromFileName {
            url.lastPathComponent
                .replacingOccurrences(of: ".\(url.pathExtension)", with: "")
        } else {
            Mango.shared.titleForCartridge(at: url)
        }
    }
}
