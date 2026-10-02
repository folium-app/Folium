//
//  DirectoryManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 11/6/2026.
//

import Foundation.NSURL

actor DirectoryManager {
    private let fileManager = FileManager.default
    
    var unavailableSystemFiles: [SystemFile] = []
    func removeUnavailableSystemFile(_ fileName: String) {
        unavailableSystemFiles.removeAll(where: { systemFile in systemFile.fileName == fileName })
    }
    
    func initializeSystemDirectoriesForInitialLaunch() async throws {
        guard let documentDirectoryURL = await URL.documentDirectoryURL else {
            return
        }
        
        let subfoldersForSystems: [System : [String : [String : SystemFile]]] = [
            .cherry: [
                "artworks" : [:],
                "games" : [:],
                "system_data": [
                    "bios.col" : SystemFile(fileName: "bios.col",
                                            path: "system_data",
                                            priority: .required,
                                            system: .cherry)
                ]
            ],
            .cytrus: [
                "artworks" : [:],
                "cache": [:],
                "cheats": [:],
                "config": [:],
                "dump": [:],
                "external_dlls": [:],
                "games" : [:],
                "icons": [:],
                "load": [:],
                "log": [:],
                "nand": [:],
                "save_states": [:],
                "sdmc": [:],
                "shaders": [:],
                "system_data": [
                    "aes_keys.txt" : SystemFile(fileName: "aes_keys.txt",
                                                path: "system_data",
                                                priority: .required,
                                                system: .cytrus)
                ]
            ],
            .durian : [
                "artworks" : [:],
                "debugger" : [:],
                "firmware" : [:],
                "games" : [:],
                "hd_packs" : [:],
                "recent_games" : [:],
                "saves" : [:],
                "save_states" : [:],
                "screenshots" : [:],
                "system_data" : [:]
            ],
            .grape : [
                "artworks" : [:],
                "games" : [:],
                "save_states" : [:],
                "system_data" : [
                    "gba_bios.bin" : SystemFile(fileName: "gba_bios.bin",
                                                path: "system_data",
                                                priority: .optional,
                                                system: .grape),
                    "bios7.bin" : SystemFile(fileName: "bios7.bin",
                                             path: "system_data",
                                             priority: .required,
                                             system: .grape),
                    "bios9.bin" : SystemFile(fileName: "bios9.bin",
                                             path: "system_data",
                                             priority: .required,
                                             system: .grape),
                    "firmware.bin" : SystemFile(fileName: "firmware.bin",
                                                path: "system_data",
                                                priority: .required,
                                                system: .grape),
                    "bios7i.bin" : SystemFile(fileName: "bios7i.bin",
                                              path: "system_data",
                                              priority: .optional,
                                              system: .grape),
                    "bios9i.bin" : SystemFile(fileName: "bios9i.bin",
                                              path: "system_data",
                                              priority: .optional,
                                              system: .grape),
                    "firmwarei.bin" : SystemFile(fileName: "firmwarei.bin",
                                                 path: "system_data",
                                                 priority: .optional,
                                                 system: .grape),
                    "nandi.bin" : SystemFile(fileName: "nandi.bin",
                                             path: "system_data",
                                             priority: .optional,
                                             system: .grape)
                ]
            ],
            .kiwi : [
                "artworks" : [:],
                "debugger" : [:],
                "firmware" : [:],
                "games" : [:],
                "hd_packs" : [:],
                "recent_games" : [:],
                "saves" : [:],
                "save_states" : [:],
                "screenshots" : [:],
                "system_data" : [:]
            ],
            .lychee : [
                "artworks" : [:],
                "debugger" : [:],
                "firmware" : [:],
                "games" : [:],
                "hd_packs" : [:],
                "recent_games" : [:],
                "saves" : [:],
                "save_states" : [:],
                "screenshots" : [:],
                "system_data" : [:]
            ],
            .mandarine : [
                "artworks" : [:],
                "memory_cards" : [:],
                "games" : [:],
                "save_states" : [:],
                "system_data" : [
                    "bios.bin" : SystemFile(fileName: "bios.bin",
                                            path: "system_data",
                                            priority: .required,
                                            system: .mandarine)
                ]
            ],
            .mango : [
                "artworks" : [:],
                "debugger" : [:],
                "firmware" : [:],
                "games" : [:],
                "hd_packs" : [:],
                "recent_games" : [:],
                "saves" : [:],
                "save_states" : [:],
                "screenshots" : [:],
                "system_data" : [:]
            ],
            .plum : [
                "artworks" : [:],
                "games" : [:]
            ],
            .tomato : [
                "artworks" : [:],
                "debugger" : [:],
                "firmware" : [:],
                "games" : [:],
                "hd_packs" : [:],
                "recent_games" : [:],
                "saves" : [:],
                "save_states" : [:],
                "screenshots" : [:],
                "system_data" : [
                    "gba_bios.bin" : SystemFile(fileName: "gba_bios.bin",
                                                path: "system_data",
                                                priority: .required,
                                                system: .tomato)
                ]
            ]
        ]
        
        for system in await SystemNames.array {
            let systemDirectoryURL = documentDirectoryURL.appending(component: await system.string)
            
            try createDirectoryIfNeeded(from: systemDirectoryURL)
            try fixSubfolders(for: systemDirectoryURL)
            
            if let subfoldersForSystem = subfoldersForSystems[system] {
                try loop(subfolders: subfoldersForSystem, for: systemDirectoryURL) { subfolderName in
                    try createDirectoryIfNeeded(from: systemDirectoryURL.appending(component: subfolderName))
                }
            }
        }
    }
    
    private func createDirectoryIfNeeded(from url: URL) throws {
        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: false)
        }
    }
    
    private func fixSubfolders(for systemDirectoryURL: URL) throws {
        let replacementSubfolderNames = [
            "memcards" : "memory_cards",
            "roms" : "games",
            "states" : "save_states",
            "sysdata" : "system_data"
        ]
        
        for (key, value) in replacementSubfolderNames {
            let oldDirectoryURL = systemDirectoryURL.appending(component: key)
            
            if fileManager.fileExists(atPath: oldDirectoryURL.path) {
                try fileManager.moveItem(at: oldDirectoryURL, to: systemDirectoryURL.appending(component: value))
            }
        }
    }
    
    private func loop(subfolders: [String : [String : SystemFile]], for systemDirectoryURL: URL, using handler: (String) throws -> Void) throws {
        for subfolderName in subfolders.keys {
            if let subfiles = subfolders[subfolderName] {
                for subfile in subfiles.values where subfile.priority == .required {
                    if !fileManager.fileExists(atPath: systemDirectoryURL.appending(component: subfile.path).appending(component: subfile.fileName).path) {
                        unavailableSystemFiles.append(subfile)
                    }
                }
            }
            
            try handler(subfolderName)
        }
    }
}
