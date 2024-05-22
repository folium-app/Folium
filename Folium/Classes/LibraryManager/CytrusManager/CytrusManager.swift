//
//  CytrusManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 15/5/2024.
//

import Foundation

class CytrusManager {
    struct Library {
        struct FileDetails : Codable, Hashable {
            let `extension`: String
            let name: String
            let nameWithoutExtension: String
            let url: URL
        }
        
        struct Game : Codable, Comparable, Hashable {
            static func < (lhs: Game, rhs: Game) -> Bool {
                lhs.title < rhs.title
            }
            
            static func == (lhs: Game, rhs: Game) -> Bool {
                lhs.title == rhs.title
            }
            
            let core: Core
            let fileDetails: FileDetails
            let title: String
        }
        
        var games: [Game]
        var missingFiles: [MissingFile]
        
        mutating func add(_ game: Game) {
            games.append(game)
            games.sort(by: <)
        }
        
        mutating func add(_ missingFile: MissingFile) {
            missingFiles.append(missingFile)
            missingFiles.sort(by: <)
        }
    }
    
    static let shared = CytrusManager()
    
    var library: Library
    init() {
        library = .init(games: [], missingFiles: [])
    }
}
