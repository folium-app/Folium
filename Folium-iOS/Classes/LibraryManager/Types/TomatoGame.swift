//
//  TomatoGame.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 2/3/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Foundation

class TomatoGame : GameBase, @unchecked Sendable {
    var icon: URL? = nil
    var data: Data? = nil
    
    init(icon: URL? = nil, core: String, fileDetails: GameBase.FileDetails, skins: [Skin], title: String) {
        self.icon = icon
        super.init(core: core, fileDetails: fileDetails, skins: skins, title: title)
    }
    
    static func icon(for url: URL) throws -> URL? {
        // TODO: Force region to USA as auto detection isn't done yet
        if let imageURL = URL(string: "https://raw.githubusercontent.com/libretro/libretro-thumbnails/refs/heads/master/Nintendo - Game Boy Advance/Named_Boxarts/\(try title(for: url)) (USA).png") {
            imageURL
        } else {
            nil
        }
    }
    
    static func title(for url: URL) throws -> String {
        let title = url.deletingPathExtension().lastPathComponent
        
        let file = try FileHandle(forReadingFrom: url)
        try file.seek(toOffset: 0x80000A0)
        if var data = try file.read(upToCount: 0x0C) {
            var pointer: UnsafeMutablePointer<UInt8> = .allocate(capacity: 0x0C)
            data.withUnsafeMutableBytes {
                guard let bytes = $0.bindMemory(to: UInt8.self).baseAddress else {
                    return
                }

                pointer = bytes
            }
            
            try file.close()
            return String(cString: pointer).capitalized
        } else {
            return title
        }
    }
}
