//
//  LycheeGame.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 2/3/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Foundation
import Lychee

class LycheeGame : GameBase, @unchecked Sendable {
    var icon: URL? = nil
    var data: Data? = nil
    
    init(icon: URL? = nil, core: String, fileDetails: GameBase.FileDetails, skins: [Skin], title: String) {
        self.icon = icon
        super.init(core: core, fileDetails: fileDetails, skins: skins, title: title)
    }
    
    static func icon(for url: URL) throws -> URL? {
        var data: URL? = nil
        for bin in try files(from: url) {
            let file = url.deletingLastPathComponent().appending(path: bin)
            let id = Lychee.shared.gameID(from: file)
            data = if id.isEmpty || id == "" {
                nil
            } else {
                if let imageURL = URL(string: "https://raw.githubusercontent.com/xlenore/psx-covers/refs/heads/main/covers/default/\(id).jpg") {
                    imageURL
                } else {
                    nil
                }
            }
            
            if let data {
                return data
            } else {
                return nil
            }
        }
        
        return data
    }
    
    static func title(for url: URL) throws -> String { url.deletingPathExtension().lastPathComponent }
    
    static func files(from cue: URL) throws -> [String] {
        let cueFileContents = try String(contentsOfFile: cue.path, encoding: .utf8)
        
        let lines = cueFileContents.split(separator: "\n")
        
        var binFiles: [String] = []
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.uppercased().starts(with: "FILE") {
                let components = trimmedLine.split(separator: "\"", omittingEmptySubsequences: false)
                if components.count >= 2 {
                    let binFilePath = String(components[1])
                    binFiles.append(binFilePath)
                }
            }
        }
        
        guard !binFiles.isEmpty else {
            throw NSError(domain: "CueParserError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No .bin files found in the .cue file."])
        }
        
        return binFiles
    }
}
