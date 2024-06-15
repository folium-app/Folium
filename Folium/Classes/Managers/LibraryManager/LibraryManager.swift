//
//  LibraryManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 15/5/2024.
//

#if canImport(Cytrus)
import Cytrus
#endif
import Foundation
import Grape

class LibraryManager {
    static let shared = LibraryManager()
    
#if canImport(Cytrus)
    var cytrusManager = CytrusManager.shared
#endif
    var grapeManager = GrapeManager.shared
    var kiwiManager = KiwiManager.shared
    
    func crawler(_ core: Core) throws -> (core: Core, urls: [URL]) {
        enum CrawlerError : Error {
            case enumeratorFailed
        }
        
        let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let coreDirectory = documentsDirectory.appendingPathComponent(core.rawValue, conformingTo: .folder)
        
        guard let enumerator = FileManager.default.enumerator(at: coreDirectory
            .appendingPathComponent("roms", conformingTo: .folder), includingPropertiesForKeys: [.isRegularFileKey]) else {
            throw CrawlerError.enumeratorFailed
        }
        
        return (core, try enumerator.reduce(into: [URL]()) { partialResult, element in
            switch element {
            case let url as URL:
                let attributes = try url.resourceValues(forKeys: [.isRegularFileKey])
                if let isRegularFile = attributes.isRegularFile, isRegularFile {
                    let pathExtension = url.pathExtension.lowercased()
                    switch core {
#if canImport(Cytrus)
                    case .cytrus:
                        if ["3ds", "3dsx", "app", "cci", "cxi"].contains(pathExtension) {
                            partialResult.append(url)
                        }
#endif
                    case .grape:
                        if ["gba", "nds"].contains(pathExtension) {
                            partialResult.append(url)
                        }
                    case .kiwi:
                        if ["nes"].contains(pathExtension) {
                            partialResult.append(url)
                        }
                    default:
                        break
                    }
                }
            default:
                break
            }
        })
    }
    
    // TODO: Add cores to populate additional game information such as the icon, publisher, region, size and title
    func games(_ core: Core, _ urls: [URL]) -> [AnyHashableSendable] {
        var gameArr: [AnyHashableSendable] = []
        
        urls.forEach { url in
            guard let nameWithoutExtension = url.lastPathComponent.components(separatedBy: ".").first else {
                return
            }
            
            switch core {
#if canImport(Cytrus)
            case .cytrus:
                let cytrus = Cytrus.shared
                if ["app", "cia"].contains(url.pathExtension.lowercased()) {
                    let title = cytrus.information(url).title
                    if !title.isEmpty {
                        let game: CytrusManager.Library.Game = .init(core: core, fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                                                    name: url.lastPathComponent,
                                                                                                    nameWithoutExtension: nameWithoutExtension,
                                                                                                    url: url), title: title)
                        
                        if !cytrusManager.library.games.contains(game) {
                            cytrusManager.library.add(game)
                            gameArr.append(game)
                        }
                    }
                } else {
                    let game: CytrusManager.Library.Game = .init(core: core, fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                                                name: url.lastPathComponent,
                                                                                                nameWithoutExtension: nameWithoutExtension,
                                                                                                url: url), title: nameWithoutExtension)
                    
                    if !cytrusManager.library.games.contains(game) {
                        cytrusManager.library.add(game)
                        gameArr.append(game)
                    }
                }
#endif
            case .grape:
                let game: GrapeManager.Library.Game = .init(core: core, fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                                           name: url.lastPathComponent,
                                                                                           nameWithoutExtension: nameWithoutExtension,
                                                                                           url: url), title: nameWithoutExtension)
                
                if !grapeManager.library.games.contains(game) {
                    grapeManager.library.add(game)
                    gameArr.append(game)
                }
            case .kiwi:
                let game: KiwiManager.Library.Game = .init(core: core, fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                                          name: url.lastPathComponent,
                                                                                          nameWithoutExtension: nameWithoutExtension,
                                                                                          url: url), title: nameWithoutExtension)
                if !kiwiManager.library.games.contains(game) {
                    kiwiManager.library.add(game)
                    gameArr.append(game)
                }
            default:
                break
            }
        }
        
        return gameArr
    }
    
    func skins(_ core: Core) throws {
        let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let coreDirectory = documentsDirectory.appendingPathComponent(core.rawValue, conformingTo: .folder)
        
        switch core {
#if canImport(Cytrus)
        case .cytrus:
            try cytrusManager.skinsManager.skins(for: .cytrus, root: coreDirectory)
#endif
        case .grape:
            try grapeManager.skinsManager.skins(for: .grape, root: coreDirectory)
        default:
            break
        }
    }
    
    func library() throws {
#if canImport(Cytrus)
        var cytrusCrawler = try crawler(.cytrus)
        cytrusCrawler.urls.append(contentsOf: Cytrus.shared.installed())
        cytrusCrawler.urls.append(contentsOf: Cytrus.shared.system())
        _ = games(cytrusCrawler.core, cytrusCrawler.urls)
        do {
            try skins(.cytrus)
        } catch { print(error, error.localizedDescription) }
#endif
        
        grapeManager.library.games.removeAll()
        let grapeCrawler = try crawler(.grape)
        _ = games(grapeCrawler.core, grapeCrawler.urls)
        do {
            try skins(.grape)
        } catch { print(error, error.localizedDescription) }
        
        kiwiManager.library.games.removeAll()
        let kiwiCrawler = try crawler(.kiwi)
        _ = games(kiwiCrawler.core, kiwiCrawler.urls)
    }
}
