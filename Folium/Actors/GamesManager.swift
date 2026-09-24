//
//  GamesManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 17/6/2026.
//

import Foundation.NSFileManager
import Foundation.NSURL

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

actor GamesManager {
    private let fileManager: FileManager = .default
    
    let cherrySystem: CherrySystem
    let cytrusSystem: CytrusSystem
    let durianSystem: DurianSystem
    let grapeSystem: GrapeSystem
    let kiwiSystem: KiwiSystem
    let lycheeSystem: LycheeSystem
    let mandarineSystem: MandarineSystem
    let mangoSystem: MangoSystem
    let plumSystem: PlumSystem
    let tomatoSystem: TomatoSystem
    
    init(cherrySystem: CherrySystem, cytrusSystem: CytrusSystem, durianSystem: DurianSystem,
         grapeSystem: GrapeSystem, kiwiSystem: KiwiSystem, lycheeSystem: LycheeSystem,
         mandarineSystem: MandarineSystem, mangoSystem: MangoSystem, plumSystem: PlumSystem,
         tomatoSystem: TomatoSystem) {
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
    
    func games<T>(for system: System, _ reinitialisingSystem: Bool = false) async -> [T] {
        let empty: [T] = []
        var games: [T] = []
        
        guard let documentDirectoryURL: URL = await .documentDirectoryURL else {
            return empty
        }
        
        let systemDirectoryURL: URL = documentDirectoryURL.appending(component: await system.string)
        let systemGamesDirectoryURL: URL = systemDirectoryURL.appending(component: "games")
        
        guard let directoryEnumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(at: systemGamesDirectoryURL,
                                                                                                includingPropertiesForKeys: [.fileSizeKey]) else {
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
            case is CherryGame.Type:
                let game: CherryGame = CherryGame(details: Details(url: url),
                                                  cherrySystem: cherrySystem,
                                                  system: system,
                                                  boxartURLString: cherrySystem.boxartURLString(for: url))
                
                if let game: T = game as? T {
                    games.append(game)
                }
                
                if reinitialisingSystem {
                    await cherrySystem.initializeSystem()
                }
            case is CytrusGame.Type:
                let game: CytrusGame = CytrusGame(details: Details(url: url),
                                                  cytrusSystem: cytrusSystem,
                                                  system: system,
                                                  boxart: await cytrusSystem.boxart(for: url).data)
                game.details.name = await cytrusSystem.title(for: url)
                
                if let game: T = game as? T {
                    games.append(game)
                }
            case is DurianGame.Type:
                let game: DurianGame = DurianGame(details: Details(url: url),
                                                  durianSystem: durianSystem,
                                                  system: system,
                                                  boxartURLString: durianSystem.boxartURLString(for: url))
                
                if let game: T = game as? T {
                    games.append(game)
                }
                
                if reinitialisingSystem {
                    await durianSystem.initializeSystem()
                }
            case is GrapeGame.Type:
                let game: GrapeGame = GrapeGame(details: Details(url: url),
                                                grapeSystem: grapeSystem,
                                                system: system,
                                                boxart: await grapeSystem.boxart(for: url).buffer)
                
                if let game: T = game as? T {
                    games.append(game)
                }
                
                if reinitialisingSystem {
                    await grapeSystem.initializeSystem()
                }
            case is KiwiGame.Type:
                let game: KiwiGame = KiwiGame(details: Details(url: url),
                                              kiwiSystem: kiwiSystem,
                                              system: system,
                                              boxartURLString: kiwiSystem.boxartURLString(for: url))
                
                if let game: T = game as? T {
                    games.append(game)
                }
                
                if reinitialisingSystem {
                    await kiwiSystem.initializeSystem()
                }
            case is LycheeGame.Type:
                let game: LycheeGame = LycheeGame(details: Details(url: url),
                                                  lycheeSystem: lycheeSystem,
                                                  system: system,
                                                  boxartURLString: lycheeSystem.boxartURLString(for: url))
                
                if let game: T = game as? T {
                    games.append(game)
                }
                
                if reinitialisingSystem {
                    await lycheeSystem.initializeSystem()
                }
            case is MandarineGame.Type:
                let game: MandarineGame = MandarineGame(details: Details(url: url),
                                                        mandarineSystem: mandarineSystem,
                                                        system: system,
                                                        boxartURLString: mandarineSystem.boxartURLString(for: url))
                if url.lowercasedPathExtension == "cue" {
                    game.details.updateSize(with: mandarineSystem.totalSizeOfFiles(for: url))
                }
                
                if let game: T = game as? T {
                    games.append(game)
                }
                
                if reinitialisingSystem {
                    await mandarineSystem.initializeSystem()
                }
            case is MangoGame.Type:
                let game: MangoGame = MangoGame(details: Details(url: url),
                                                mangoSystem: mangoSystem,
                                                system: system,
                                                boxartURLString: mangoSystem.boxartURLString(for: url))
                
                if let game: T = game as? T {
                    games.append(game)
                }
                
                if reinitialisingSystem {
                    await mangoSystem.initializeSystem()
                }
            case is PlumGame.Type:
                let game: PlumGame = PlumGame(details: Details(url: url),
                                              plumSystem: plumSystem,
                                              system: system,
                                              boxartURLString: plumSystem.boxartURLString(for: url))
                
                if let game: T = game as? T {
                    games.append(game)
                }
                
                if reinitialisingSystem {
                    await plumSystem.initializeSystem()
                }
            case is TomatoGame.Type:
                let game: TomatoGame = TomatoGame(details: Details(url: url),
                                                  tomatoSystem: tomatoSystem,
                                                  system: system,
                                                  boxartURLString: tomatoSystem.boxartURLString(for: url))
                
                if let game: T = game as? T {
                    games.append(game)
                }
                
                if reinitialisingSystem {
                    await tomatoSystem.initializeSystem()
                }
            default:
                break
            }
        }
        
        return games
    }
}
