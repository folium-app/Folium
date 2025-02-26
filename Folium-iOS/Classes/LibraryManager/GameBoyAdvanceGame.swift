//
//  GameBoyAdvanceGame.swift
//
//
//  Created by Jarrod Norwell on 8/7/2024.
//

import Foundation

// MARK: Class for the Game Boy Advance core, Tomato
class GameBoyAdvanceGame : GameBase, @unchecked Sendable {
    var icon: URL?
    var iconData: Data? = nil
    
    init(icon: URL? = nil, core: String, fileDetails: GameBase.FileDetails, skins: [Skin], title: String) {
        self.icon = icon
        super.init(core: core, fileDetails: fileDetails, skins: skins, title: title)
    }
    
    static func iconFromHeader(for url: URL) throws -> URL? {
        let title = try titleFromHeader(for: url)
        
        // TODO: fix the region code
        if let imageURL = URL(string: "https://raw.githubusercontent.com/libretro/libretro-thumbnails/refs/heads/master/Nintendo - Game Boy Advance/Named_Boxarts/\(title) (USA).png") {
            return imageURL
        } else {
            return nil
        }
    }
    
    static func titleFromHeader(for url: URL) throws -> String {
        let title = url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: "")
        
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
