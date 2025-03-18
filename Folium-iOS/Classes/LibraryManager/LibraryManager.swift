// The Swift Programming Language
// https://docs.swift.org/swift-book

import Cytrus
import Foundation
import UIKit

struct LibraryManager : @unchecked Sendable {
    static var shared = LibraryManager()
    
    var cores: [Core] { [.cytrus, .grape, .lychee, .mango, .peach, .tomato] }
    var coresWithGames: any RangeReplaceableCollection<Core> = []
    
    var allGames: [GameBase] = []
    
    mutating func games() throws -> Result<[GameBase], Error> {
        let skinManager = SkinManager.shared
        do {
            try skinManager.getSkins()
        } catch {
            print(#function, error, error.localizedDescription)
        }
        
        allGames.removeAll()
        coresWithGames.removeAll()
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var games: [GameBase] = []
        
        for url in Cytrus.shared.installed() {
            coresWithGames.appendUnique(.cytrus)
            
            if CytrusGame.title(for: url).isEmpty { break }
            
            games.append(generateCytrusGame(.cytrus, url, skinManager))
        }
        
        for url in Cytrus.shared.system() {
            coresWithGames.appendUnique(.cytrus)
            
            if CytrusGame.title(for: url).isEmpty { break }
            
            games.append(generateCytrusGame(.cytrus, url, skinManager))
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
                                if CytrusGame.title(for: url).isEmpty { break }
                                
                                coresWithGames.appendUnique(.cytrus)
                                
                                partialResult.append(generateCytrusGame(.cytrus, url, skinManager))
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
                            case "n64", "z64":
                                coresWithGames.appendUnique(.guava)
                                
                                partialResult.append(generateGuavaGame(.guava, url, skinManager))
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
        
        allGames.append(contentsOf: games)
        
        return .success(games)
    }
    
    
    func generateCytrusGame(_ core: Core, _ url: URL, _ skinManager: SkinManager) -> CytrusGame {
        let game = CytrusGame(for: url,
                              core: core.rawValue,
                              fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                 name: url.lastPathComponent,
                                                 nameWithoutExtension: url.deletingPathExtension().lastPathComponent,
                                                 url: url),
                              skins: skinManager.skins(for: core),
                              title: CytrusGame.title(for: url))
        //game.fileDetails.md5 = try GameBase.FileDetails.MD5(for: url)
        return game
    }
    
    func generateGrapeGame(_ core: Core, _ url: URL, _ skinManager: SkinManager) -> GrapeGame {
        let game = GrapeGame(icon: GrapeGame.icon(for: url),
                             core: core.rawValue,
                             fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                name: url.lastPathComponent,
                                                nameWithoutExtension: url.deletingPathExtension().lastPathComponent,
                                                url: url),
                             skins: skinManager.skins(for: core),
                             title: GrapeGame.title(for: url))
        //game.fileDetails.md5 = try GameBase.FileDetails.MD5(for: url)
        return game
    }
    
    func generateLycheeGame(_ core: Core, _ url: URL, _ skinManager: SkinManager) throws -> LycheeGame {
        let game = LycheeGame(icon: try LycheeGame.icon(for: url),
                              core: core.rawValue,
                              fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                 name: url.lastPathComponent,
                                                 nameWithoutExtension: url.deletingPathExtension().lastPathComponent,
                                                 url: url),
                              skins: skinManager.skins(for: core),
                              title: try LycheeGame.title(for: url))
        //game.fileDetails.md5 = try GameBase.FileDetails.MD5(for: url)
        return game
    }
    
    func generateMangoGame(_ core: Core, _ url: URL, _ skinManager: SkinManager) throws -> MangoGame {
        let game = MangoGame(icon: try MangoGame.icon(for: url),
                             core: core.rawValue,
                             fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                name: url.lastPathComponent,
                                                nameWithoutExtension: url.deletingPathExtension().lastPathComponent,
                                                url: url),
                             skins: skinManager.skins(for: core),
                             title: MangoGame.title(for: url))
        //game.fileDetails.md5 = try GameBase.FileDetails.MD5(for: url)
        return game
    }
    
    func generatePeachGame(_ core: Core, _ url: URL, _ skinManager: SkinManager) -> PeachGame {
        let game = PeachGame(core: core.rawValue,
                             fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                name: url.lastPathComponent,
                                                nameWithoutExtension: url.deletingPathExtension().lastPathComponent,
                                                url: url),
                             skins: skinManager.skins(for: core),
                             title: PeachGame.title(for: url))
        //game.fileDetails.md5 = try GameBase.FileDetails.MD5(for: url)
        return game
    }
    
    func generateTomatoGame(_ core: Core, _ url: URL, _ skinManager: SkinManager) throws -> TomatoGame {
        let game = TomatoGame(icon: try TomatoGame.icon(for: url),
                              core: core.rawValue,
                              fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                 name: url.lastPathComponent,
                                                 nameWithoutExtension: url.deletingPathExtension().lastPathComponent,
                                                 url: url),
                              skins: skinManager.skins(for: core),
                              title: try TomatoGame.title(for: url))
        //game.fileDetails.md5 = try GameBase.FileDetails.MD5(for: url)
        return game
    }
    
    func generateGuavaGame(_ core: Core, _ url: URL, _ skinManager: SkinManager) -> Nintendo64Game {
        let game = Nintendo64Game(core: core.rawValue,
                                  fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                     name: url.lastPathComponent,
                                                     nameWithoutExtension: url.deletingPathExtension().lastPathComponent,
                                                     url: url),
                                  skins: skinManager.skins(for: core),
                                  title: Nintendo64Game.title(for: url))
        //game.fileDetails.md5 = try GameBase.FileDetails.MD5(for: url)
        return game
    }
}
