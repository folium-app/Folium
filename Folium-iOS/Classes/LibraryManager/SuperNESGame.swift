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
    static func titleFromHeader(for url: URL) throws -> String {
        Mango.shared.titleForCartridge(at: url)
        
        /*
        let title = url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: "")
        
        let file = try FileHandle(forReadingFrom: url)
        try file.seek(toOffset: 0xFFC0)
        if var data = try file.read(upToCount: 0x15) {
            var pointer: UnsafeMutablePointer<UInt8> = .allocate(capacity: 0x15)
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
         */
    }
}
