//
//  GamePopulationManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 17/6/2026.
//

import Foundation.NSFileManager

import Cherry
import Cytrus
import Durian
import Grape
import Kiwi
import Lychee
import Mandarine
import Mango
import Plum
import Tomato

// MARK: Finished (3/10/2026)

actor GamePopulationManager {
    private let fileManager = FileManager.default
    
    var cherrySystem: CherrySystem
    var cytrusSystem: CytrusSystem
    var durianSystem: DurianSystem
    var grapeSystem: GrapeSystem
    var kiwiSystem: KiwiSystem
    var lycheeSystem: LycheeSystem
    var mandarineSystem: MandarineSystem
    var mangoSystem: MangoSystem
    var plumSystem: PlumSystem
    var tomatoSystem: TomatoSystem
    
    init(_ cherrySystem: CherrySystem, _ cytrusSystem: CytrusSystem, _ durianSystem: DurianSystem, _ grapeSystem: GrapeSystem,
         _ kiwiSystem: KiwiSystem, _ lycheeSystem: LycheeSystem, _ mandarineSystem: MandarineSystem, _ mangoSystem: MangoSystem,
         _ plumSystem: PlumSystem, _ tomatoSystem: TomatoSystem) {
        self.cherrySystem = cherrySystem
        self.cytrusSystem = cytrusSystem
        self.durianSystem = durianSystem
        self.grapeSystem = grapeSystem
        self.kiwiSystem = kiwiSystem
        self.lycheeSystem = lycheeSystem
        self.mandarineSystem = mandarineSystem
        self.mangoSystem = mangoSystem
        self.plumSystem = plumSystem
        self.tomatoSystem = tomatoSystem
    }
    
    func retrieveGames<T>(_ system: System, _ reinitializeSystem: Bool = false) async -> [T] {
        let empty: [T] = []
        var games: [T] = []
        
        guard let documentDirectoryURL = await URL.documentDirectoryURL else {
            return empty
        }
        
        let systemDirectoryURL = documentDirectoryURL.appending(component: await system.string)
        let gamesDirectoryURL = systemDirectoryURL.appending(component: "games")
        
        guard let directoryEnumerator = fileManager.enumerator(at: gamesDirectoryURL, includingPropertiesForKeys: [.fileSizeKey]) else {
            return empty
        }
        
        let filteredDirectoryEnumeration = directoryEnumerator.filter {
            element in element is URL
        }
        
        guard let filteredAsURLs = filteredDirectoryEnumeration as? [URL] else {
            return empty
        }
        
        let extensions = system.extensions
        let extensionsAsStrings = extensions.map(\.string)
        
        let filteredURLs = filteredAsURLs.filter {
            element in extensionsAsStrings.contains(element.lowercasedPathExtension)
        }
        
        for url in filteredURLs {
            switch T.self {
            case is CherryGame.Type:
                if let game = CherryGame(cherrySystem, url, system, cherrySystem.boxartURLString(for: url)) as? T {
                    games.append(game)
                }
                
                if reinitializeSystem {
                    await cherrySystem.initializeSystem()
                }
            case is CytrusGame.Type:
                let game: CytrusGame = CytrusGame(details: Details(url),
                                                  cytrusSystem: cytrusSystem,
                                                  system: system,
                                                  boxart: await cytrusSystem.boxart(for: url).data)
                game.details.fileName = await cytrusSystem.title(for: url)
                
                if let game: T = game as? T {
                    games.append(game)
                }
            case is DurianGame.Type:
                let game: DurianGame = DurianGame(details: Details(url),
                                                  durianSystem: durianSystem,
                                                  system: system,
                                                  boxartURLString: durianSystem.boxartURLString(for: url))
                
                if let game: T = game as? T {
                    games.append(game)
                }
                
                if reinitializeSystem {
                    await durianSystem.initializeSystem()
                }
            case is GrapeGame.Type:
                let game: GrapeGame = GrapeGame(details: Details(url),
                                                grapeSystem: grapeSystem,
                                                system: system,
                                                boxart: await grapeSystem.boxart(for: url).buffer)
                
                if let game: T = game as? T {
                    games.append(game)
                }
                
                if reinitializeSystem {
                    await grapeSystem.initializeSystem()
                }
            case is KiwiGame.Type:
                let game: KiwiGame = KiwiGame(details: Details(url),
                                              kiwiSystem: kiwiSystem,
                                              system: system,
                                              boxartURLString: kiwiSystem.boxartURLString(for: url))
                
                if let game: T = game as? T {
                    games.append(game)
                }
                
                if reinitializeSystem {
                    await kiwiSystem.initializeSystem()
                }
            case is LycheeGame.Type:
                let game: LycheeGame = LycheeGame(details: Details(url),
                                                  lycheeSystem: lycheeSystem,
                                                  system: system,
                                                  boxartURLString: lycheeSystem.boxartURLString(for: url))
                
                if let game: T = game as? T {
                    games.append(game)
                }
                
                if reinitializeSystem {
                    await lycheeSystem.initializeSystem()
                }
            case is MandarineGame.Type:
                let game: MandarineGame = MandarineGame(details: Details(url),
                                                        mandarineSystem: mandarineSystem,
                                                        system: system,
                                                        boxartURLString: mandarineSystem.boxartURLString(for: url))
                if url.lowercasedPathExtension == "cue" {
                    game.details.updateSize(mandarineSystem.totalSizeOfFiles(for: url))
                }
                
                if let game: T = game as? T {
                    games.append(game)
                }
                
                if reinitializeSystem {
                    await mandarineSystem.initializeSystem()
                }
            case is MangoGame.Type:
                let game: MangoGame = MangoGame(details: Details(url),
                                                mangoSystem: mangoSystem,
                                                system: system,
                                                boxartURLString: mangoSystem.boxartURLString(for: url))
                
                if let game: T = game as? T {
                    games.append(game)
                }
                
                if reinitializeSystem {
                    await mangoSystem.initializeSystem()
                }
            case is PlumGame.Type:
                let game: PlumGame = PlumGame(details: Details(url),
                                              plumSystem: plumSystem,
                                              system: system,
                                              boxartURLString: plumSystem.boxartURLString(for: url))
                
                if let game: T = game as? T {
                    games.append(game)
                }
                
                if reinitializeSystem {
                    await plumSystem.initializeSystem()
                }
            case is TomatoGame.Type:
                let game: TomatoGame = TomatoGame(details: Details(url),
                                                  tomatoSystem: tomatoSystem,
                                                  system: system,
                                                  boxartURLString: tomatoSystem.boxartURLString(for: url))
                
                if let game: T = game as? T {
                    games.append(game)
                }
                
                if reinitializeSystem {
                    await tomatoSystem.initializeSystem()
                }
            default:
                break
            }
        }
        
        return games
    }
}
