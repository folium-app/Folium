//
//  GameBoyGame.swift
//
//
//  Created by Jarrod Norwell on 4/7/2024.
//

import Foundation

// MARK: Class for the Game Boy core, Kiwi
class GameBoyGame : GameBase, @unchecked Sendable {
    static func titleFromHeader(for url: URL) throws -> String {
        let title = url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: "")
        
        let file = try FileHandle(forReadingFrom: url)
        try file.seek(toOffset: 0x134)
        if var data = try file.read(upToCount: 0xF) {
            var pointer: UnsafeMutablePointer<UInt8> = .allocate(capacity: 0xF)
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
