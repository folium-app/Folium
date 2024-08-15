//
//  GameBoyAdvanceGame.swift
//
//
//  Created by Jarrod Norwell on 8/7/2024.
//

import Foundation

// MARK: Class for the Game Boy Advance core, Tomato
class GameBoyAdvanceGame : GameBase, @unchecked Sendable {
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
            
            return String(cString: pointer).capitalized
        } else {
            return title
        }
    }
}
