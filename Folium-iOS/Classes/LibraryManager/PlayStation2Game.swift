//
//  PlayStation2Game.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 22/12/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Cherry
import Foundation

// MARK: Class for the PlayStation 2 core, Cherry
class PlayStation2Game : GameBase, @unchecked Sendable {
    var icon: URL?
    var iconData: Data? = nil
    
    init(icon: URL? = nil, core: String, fileDetails: GameBase.FileDetails, skins: [Skin], title: String) {
        self.icon = icon
        super.init(core: core, fileDetails: fileDetails, skins: skins, title: title)
    }
    
    static func iconFromHeader(for url: URL) throws -> URL? {
        let id = Cherry.shared.gameID(from: url)
        print(id)
        let data: URL? = if id.isEmpty || id == "" {
            nil
        } else {
            if let imageURL = URL(string: "https://raw.githubusercontent.com/xlenore/ps2-covers/refs/heads/main/covers/default/\(id).jpg") {
                imageURL
            } else {
                nil
            }
        }
        
        return data
    }
    
    static func titleFromHeader(for url: URL) throws -> String {
        url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: "")
    }
}
