//
//  GamesManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 17/6/2026.
//

import Foundation.NSFileManager
import Foundation.NSURL

import Mandarine
import Tomato

actor GamesManager {
    private let fileManager: FileManager = .default
    
    private let mandarineSystem: MandarineSystem
    private let tomatoSystem: TomatoSystem
    
    init(mandarineSystem: MandarineSystem, tomatoSystem: TomatoSystem) {
        self.mandarineSystem = mandarineSystem
        self.tomatoSystem = tomatoSystem
    }
    
    func games<T>(for system: System) async -> [T] {
        let empty: [T] = []
        var games: [T] = []
        
        guard let documentDirectoryURL: URL = await .documentDirectoryURL else {
            return empty
        }
        
        let systemDirectoryURL: URL = documentDirectoryURL.appending(component: await system.string)
        let systemGamesDirectoryURL: URL = systemDirectoryURL.appending(component: "games")
        
        guard let directoryEnumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(at: systemGamesDirectoryURL, includingPropertiesForKeys: [.fileSizeKey]) else {
            return empty
        }
        
        let filteredDirectoryEnumeration: [NSEnumerator.Element] = directoryEnumerator.filter { element in element is URL }
        guard let filteredAsURLs: [URL] = filteredDirectoryEnumeration as? [URL] else {
            return empty
        }
        
        let extensions: [Extension] = system.extensions
        let extensionsAsStrings: [String] = extensions.map(\.string)
        
        let filteredURLs: [URL] = filteredAsURLs.filter { element in extensionsAsStrings.contains(element.lowercasedPathExtension) }
        for url in filteredURLs {
            switch T.self {
            case is MandarineGame.Type:
                let game: MandarineGame = MandarineGame(details: Details(url: url),
                                                        mandarineSystem: mandarineSystem,
                                                        system: system,
                                                        boxartURLString: mandarineSystem.boxartURLString(for: url))
                game.details.updateSize(with: mandarineSystem.totalSizeOfFiles(for: url))
                
                if let game: T = game as? T {
                    games.append(game)
                }
            case is TomatoGame.Type:
                let game: TomatoGame = TomatoGame(details: Details(url: url),
                                                  tomatoSystem: tomatoSystem,
                                                  system: system,
                                                  boxartURLString: tomatoSystem.boxartURLString(for: url))
                
                if let game: T = game as? T {
                    games.append(game)
                }
            default:
                break
            }
        }
        
        return games
    }
}

/*
actor GamesManager {
    private let fileManager: FileManager = .default
    
    private var mandarineSystem: MandarineSystem
    private var tomatoSystem: TomatoSystem
    init(mandarineSystem: MandarineSystem, tomatoSystem: TomatoSystem) {
        self.mandarineSystem = mandarineSystem
        self.tomatoSystem = tomatoSystem
    }
    
    func games<T>(for system: System) async -> [T] {
        guard let documentDirectoryURL: URL = await .documentDirectoryURL else {
            return []
        }
        
        let gamesDirectoryURL: URL = documentDirectoryURL
            .appending(component: await system.string)
            .appending(component: "games")
        
        guard let directoryEnumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(at: gamesDirectoryURL,
                                                                                                includingPropertiesForKeys: [.fileSizeKey]) else {
            return []
        }
        
        let urls: [NSEnumerator.Element] = directoryEnumerator.filter { element in element is URL }
        guard let urls: [URL] = urls as? [URL] else {
            return []
        }
        
        let extensions: [Extension] = system.extensions
        let extensionsStrings: [String] = extensions.map(\.string)
        
        var games: [T] = []
        games.reserveCapacity(games.underestimatedCount)
        
        let filteredURLs: [URL] = urls.filter { url in extensionsStrings.contains(url.lowercasedPathExtension) }
        
        for url in filteredURLs {
            switch T.self {
            case is MandarineGame.Type:
                let game: MandarineGame = MandarineGame(details: Details(url: url),
                                                        mandarineSystem: mandarineSystem,
                                                        system: system,
                                                        boxartURLString: mandarineSystem.boxartURLString(for: url))
                game.details.updateSize(with: mandarineSystem.totalSizeOfFiles(for: url))
                
                if let game: T = game as? T {
                    games.append(game)
                }
            case is TomatoGame.Type:
                let game: TomatoGame = TomatoGame(details: Details(url: url),
                                                  tomatoSystem: tomatoSystem,
                                                  system: system,
                                                  boxartURLString: tomatoSystem.boxartURLString(for: url))
                
                if let game: T = game as? T {
                    games.append(game)
                }
            default:
                break
            }
        }
        
        return games
    }
}
*/
