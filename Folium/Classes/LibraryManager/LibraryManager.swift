//
//  LibraryManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 15/5/2024.
//

import Cytrus
import Foundation
import Grape

class LibraryManager {
    static let shared = LibraryManager()
    
    var cytrusManager = CytrusManager.shared
    var grapeManager = GrapeManager.shared
    var kiwiManager = KiwiManager.shared
    
    func crawler(_ core: Core) throws -> (core: Core, urls: [URL]) {
        enum CrawlerError : Error {
            case enumeratorFailed
        }
        
        let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        guard let enumerator = FileManager.default.enumerator(at: documentsDirectory.appendingPathComponent(core.rawValue, conformingTo: .folder)
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
                    case .cytrus:
                        if ["3ds", "3dsx", "app", "cci", "cxi"].contains(pathExtension) {
                            partialResult.append(url)
                        }
                    case .grape:
                        if ["gba", "nds"].contains(pathExtension) {
                            partialResult.append(url)
                        }
                    case .kiwi:
                        if ["nes"].contains(pathExtension) {
                            partialResult.append(url)
                        }
                    }
                }
            default:
                break
            }
        })
    }
    
    // TODO: Add cores to populate additional game information such as the icon, publisher, region, size and title
    func games(_ core: Core, _ urls: [URL]) {
        urls.forEach { url in
            guard let nameWithoutExtension = url.lastPathComponent.components(separatedBy: ".").first else {
                return
            }
            
            switch core {
            case .cytrus:
                let cytrus = Cytrus.shared
                if ["app", "cia"].contains(url.pathExtension.lowercased()) {
                    let title = cytrus.information(url).title
                    if !title.isEmpty {
                        cytrusManager.library.add(.init(core: core, fileDetails: .init(extension: url.pathExtension.lowercased(), name: url.lastPathComponent,
                            nameWithoutExtension: nameWithoutExtension, url: url), title: title))
                    }
                } else {
                    cytrusManager.library.add(.init(core: core, fileDetails: .init(extension: url.pathExtension.lowercased(), name: url.lastPathComponent,
                                                                                   nameWithoutExtension: nameWithoutExtension, url: url), title: nameWithoutExtension))
                }
            case .grape:
                grapeManager.library.add(.init(core: core, fileDetails: .init(extension: url.pathExtension.lowercased(), name: url.lastPathComponent,
                    nameWithoutExtension: nameWithoutExtension,
                    url: url), title: nameWithoutExtension))
            case .kiwi:
                kiwiManager.library.add(.init(core: core, fileDetails: .init(extension: url.pathExtension.lowercased(), name: url.lastPathComponent,
                    nameWithoutExtension: nameWithoutExtension,
                    url: url), title: nameWithoutExtension))
            }
        }
    }
    
    func library() throws {
        cytrusManager.library.games.removeAll()
        var cytrusCrawler = try crawler(.cytrus)
        cytrusCrawler.urls.append(contentsOf: Cytrus.shared.installed())
        cytrusCrawler.urls.append(contentsOf: Cytrus.shared.system())
        games(cytrusCrawler.core, cytrusCrawler.urls)
        
        grapeManager.library.games.removeAll()
        let grapeCrawler = try crawler(.grape)
        games(grapeCrawler.core, grapeCrawler.urls)
        
        kiwiManager.library.games.removeAll()
        let kiwiCrawler = try crawler(.kiwi)
        games(kiwiCrawler.core, kiwiCrawler.urls)
    }
}
