//
//  GamesManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 17/6/2026.
//

import Foundation.NSFileManager
import Foundation.NSURL

import Cytrus
import Grape
import Kiwi
import Mandarine
import Tomato

actor GamesManager {
    private let fileManager: FileManager = .default
    
    private let cytrusSystem: CytrusSystem
    private let grapeSystem: GrapeSystem
    private let kiwiSystem: KiwiSystem
    private let mandarineSystem: MandarineSystem
    private let tomatoSystem: TomatoSystem
    
    init(cytrusSystem: CytrusSystem, grapeSystem: GrapeSystem, kiwiSystem: KiwiSystem, mandarineSystem: MandarineSystem, tomatoSystem: TomatoSystem) {
        self.cytrusSystem = cytrusSystem
        self.grapeSystem = grapeSystem
        self.kiwiSystem = kiwiSystem
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
            case is CytrusGame.Type:
                let game: CytrusGame = CytrusGame(details: Details(url: url),
                                                  cytrusSystem: cytrusSystem,
                                                  system: system,
                                                  boxart: await cytrusSystem.boxart(for: url).data)
                
                if let game: T = game as? T {
                    games.append(game)
                }
            case is GrapeGame.Type:
                let game: GrapeGame = GrapeGame(details: Details(url: url),
                                                grapeSystem: grapeSystem,
                                                system: system,
                                                boxart: await grapeSystem.boxart(for: url).buffer)
                
                if let game: T = game as? T {
                    games.append(game)
                }
            case is KiwiGame.Type:
                let game: KiwiGame = KiwiGame(details: Details(url: url),
                                              kiwiSystem: kiwiSystem,
                                              system: system,
                                              boxartURLString: kiwiSystem.boxartURLString(for: url))
                
                if let game: T = game as? T {
                    games.append(game)
                }
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
