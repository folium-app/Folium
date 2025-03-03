// The Swift Programming Language
// https://docs.swift.org/swift-book

import Cytrus
import Foundation
import UIKit

struct LibraryManager : @unchecked Sendable {
    static var shared = LibraryManager()
    
    var cores: [Core] { [.cytrus, .grape, .lychee, .mango, .peach, .tomato] }
    var coresWithGames: any RangeReplaceableCollection<Core> = []
    
    mutating func games() throws -> Result<[GameBase], Error> {
        let skinManager = SkinManager.shared
        do {
            try skinManager.getSkins()
        } catch {
            print(#function, error, error.localizedDescription)
        }
        
        coresWithGames.removeAll()
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var games: [GameBase] = []
        
        for url in Cytrus.shared.installed() {
            coresWithGames.appendUnique(.cytrus)
            
            if try CytrusGame.title(for: url).isEmpty { break }
            
            games.append(try generateCytrusGame(.cytrus, url, skinManager))
        }
        
        for url in Cytrus.shared.system() {
            coresWithGames.appendUnique(.cytrus)
            
            if try CytrusGame.title(for: url).isEmpty { break }
            
            games.append(try generateCytrusGame(.cytrus, url, skinManager))
        }
        
        try cores.forEach { core in
            let romsDirectory = if #available(iOS 16, *) {
                documentsDirectory.appending(component: core.rawValue).appending(component: "roms")
            } else {
                documentsDirectory.appendingPathComponent(core.rawValue).appendingPathComponent("roms")
            }
            
            if let enumerator = FileManager.default.enumerator(at: romsDirectory,
                                                               includingPropertiesForKeys: [.isRegularFileKey],
                                                               options: [.skipsHiddenFiles]) {
                games.append(contentsOf: try enumerator.reduce(into: [GameBase]()) { partialResult, element in
                    switch element {
                    case let url as URL:
                        let attributes = try url.resourceValues(forKeys: [.isRegularFileKey])
                        if let isRegularFile = attributes.isRegularFile, isRegularFile {
                            let nameWithoutExtension = url.deletingLastPathComponent().lastPathComponent
                            switch url.pathExtension.lowercased() {
                            case "cue":
                                if try LycheeGame.title(for: url).isEmpty { break }
                                
                                coresWithGames.appendUnique(.lychee)
                                
                                partialResult.append(try generateLycheeGame(.lychee, url, skinManager))
                            case "iso":
                                let title = try PlayStation2Game.titleFromHeader(for: url)
                                if title.isEmpty {
                                    break
                                }
                                
                                coresWithGames.appendUnique(.cherry)
                                
                                partialResult.append(PlayStation2Game(icon: try PlayStation2Game.iconFromHeader(for: url),
                                                                      core: "Cherry",
                                                                      fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                                         name: url.lastPathComponent,
                                                                                         nameWithoutExtension: nameWithoutExtension,
                                                                                         url: url),
                                                                      skins: skinManager.skins(for: .cherry),
                                                                      title: title))
                            case "3ds", "cci", "cxi":
                                if try CytrusGame.title(for: url).isEmpty { break }
                                
                                coresWithGames.appendUnique(.cytrus)
                                
                                partialResult.append(try generateCytrusGame(.cytrus, url, skinManager))
                            case "ds", "nds":
                                coresWithGames.appendUnique(.grape)
                                
                                partialResult.append(generateGrapeGame(.grape, url, skinManager))
                            case "sfc", "smc":
                                coresWithGames.appendUnique(.mango)
                                
                                partialResult.append(try generateMangoGame(.mango, url, skinManager))
                            case "nes":
                                coresWithGames.appendUnique(.peach)
                                
                                partialResult.append(generatePeachGame(.peach, url, skinManager))
                            case "gba":
                                coresWithGames.appendUnique(.tomato)
                                
                                partialResult.append(try generateTomatoGame(.tomato, url, skinManager))
                            default:
                                break
                            }
                        }
                    default:
                        break
                    }
                })
            }
        }
        
        if !UserDefaults.standard.bool(forKey: "folium.showBetaConsoles") {
            coresWithGames.removeAll(where: { $0.isBeta == true })
        }
        
        return .success(games)
    }
    
    
    func generateCytrusGame(_ core: Core, _ url: URL, _ skinManager: SkinManager) throws -> CytrusGame {
        .init(icon: try CytrusGame.icon(for: url),
              identifier: try CytrusGame.identifier(for: url),
              core: core.rawValue,
              fileDetails: .init(extension: url.pathExtension.lowercased(),
                                 name: url.lastPathComponent,
                                 nameWithoutExtension: url.deletingPathExtension().lastPathComponent,
                                 url: url),
              skins: skinManager.skins(for: core),
              title: try CytrusGame.title(for: url))
    }
    
    func generateGrapeGame(_ core: Core, _ url: URL, _ skinManager: SkinManager) -> GrapeGame {
        .init(icon: GrapeGame.icon(for: url),
              core: core.rawValue,
              fileDetails: .init(extension: url.pathExtension.lowercased(),
                                 name: url.lastPathComponent,
                                 nameWithoutExtension: url.deletingPathExtension().lastPathComponent,
                                 url: url),
              skins: skinManager.skins(for: core),
              title: GrapeGame.title(for: url))
    }
    
    func generateLycheeGame(_ core: Core, _ url: URL, _ skinManager: SkinManager) throws -> LycheeGame {
        .init(icon: try LycheeGame.icon(for: url),
              core: core.rawValue,
              fileDetails: .init(extension: url.pathExtension.lowercased(),
                                 name: url.lastPathComponent,
                                 nameWithoutExtension: url.deletingPathExtension().lastPathComponent,
                                 url: url),
              skins: skinManager.skins(for: core),
              title: try LycheeGame.title(for: url))
    }
    
    func generateMangoGame(_ core: Core, _ url: URL, _ skinManager: SkinManager) throws -> MangoGame {
        .init(icon: try MangoGame.icon(for: url),
              core: core.rawValue,
              fileDetails: .init(extension: url.pathExtension.lowercased(),
                                 name: url.lastPathComponent,
                                 nameWithoutExtension: url.deletingPathExtension().lastPathComponent,
                                 url: url),
              skins: skinManager.skins(for: core),
              title: MangoGame.title(for: url))
    }
    
    func generatePeachGame(_ core: Core, _ url: URL, _ skinManager: SkinManager) -> PeachGame {
        .init(core: core.rawValue,
              fileDetails: .init(extension: url.pathExtension.lowercased(),
                                 name: url.lastPathComponent,
                                 nameWithoutExtension: url.deletingPathExtension().lastPathComponent,
                                 url: url),
              skins: skinManager.skins(for: core),
              title: PeachGame.title(for: url))
    }
    
    func generateTomatoGame(_ core: Core, _ url: URL, _ skinManager: SkinManager) throws -> TomatoGame {
        .init(icon: try TomatoGame.icon(for: url),
              core: core.rawValue,
              fileDetails: .init(extension: url.pathExtension.lowercased(),
                                 name: url.lastPathComponent,
                                 nameWithoutExtension: url.deletingPathExtension().lastPathComponent,
                                 url: url),
              skins: skinManager.skins(for: core),
              title: try TomatoGame.title(for: url))
    }
}
