//
//  PlayStation1Game.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 29/7/2024.
//

import Foundation
import Lychee

// MARK: Class for the PlayStation 1 core, Lychee
class PlayStation1Game : GameBase, @unchecked Sendable {
    var icon: URL?
    var iconData: Data? = nil
    
    init(icon: URL? = nil, core: String, fileDetails: GameBase.FileDetails, skins: [Skin], title: String) {
        self.icon = icon
        super.init(core: core, fileDetails: fileDetails, skins: skins, title: title)
    }
    
    static func iconFromHeader(for url: URL) throws -> URL? {
        var data: URL? = nil
        for bin in try getBinFiles(from: url) {
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
    
    static func titleFromHeader(for url: URL) throws -> String {
        url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: "")
    }
    
    static func getBinFiles(from cue: URL) throws -> [String] {
        // Read the contents of the .cue file
        let cueFileContents = try String(contentsOfFile: cue.path, encoding: .utf8)
        
        // Split the contents into lines
        let lines = cueFileContents.split(separator: "\n")
        
        // Array to hold the .bin file paths
        var binFiles: [String] = []
        
        for line in lines {
            // Trim whitespace and check if the line contains a file reference
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Look for lines that start with FILE
            if trimmedLine.uppercased().starts(with: "FILE") {
                // Extract the .bin file path between quotes
                let components = trimmedLine.split(separator: "\"", omittingEmptySubsequences: false)
                if components.count >= 2 {
                    let binFilePath = String(components[1])
                    binFiles.append(binFilePath)
                }
            }
        }
        
        // Ensure we found at least one .bin file
        guard !binFiles.isEmpty else {
            throw NSError(domain: "CueParserError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No .bin files found in the .cue file."])
        }
        
        return binFiles
    }
}
