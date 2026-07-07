//
//  DirectoryManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 11/6/2026.
//

import Foundation.NSURL

actor DirectoryManager {
    private let fileManager: FileManager = .default
    
    private var unavailableSystemFiles: [SystemFile] = []
    
    func initializeSystemDirectoriesForInitialLaunch() async throws {
        guard let documentDirectoryURL: URL = await .documentDirectoryURL else {
            return
        }
        
        let subfoldersForSystems: [System : [String : [String : SystemFile]]] = [
            .grape : [
                "artworks" : [:],
                "games" : [:],
                "save_states" : [:],
                "system_data" : [
                    "gba_bios.bin" : SystemFile(path: "system_data",
                                            system: .grape,
                                            systemFileType: .optional,
                                            title: "gba_bios.bin"),
                    "bios7.bin" : SystemFile(path: "system_data",
                                            system: .grape,
                                            systemFileType: .required,
                                            title: "bios7.bin"),
                    "bios9.bin" : SystemFile(path: "system_data",
                                            system: .grape,
                                            systemFileType: .required,
                                            title: "bios9.bin"),
                    "firmware.bin" : SystemFile(path: "system_data",
                                            system: .grape,
                                            systemFileType: .required,
                                            title: "firmware.bin"),
                    "bios7i.bin" : SystemFile(path: "system_data",
                                            system: .grape,
                                            systemFileType: .optional,
                                            title: "bios7i.bin"),
                    "bios9i.bin" : SystemFile(path: "system_data",
                                            system: .grape,
                                            systemFileType: .optional,
                                            title: "bios9i.bin"),
                    "firmwarei.bin" : SystemFile(path: "system_data",
                                            system: .grape,
                                            systemFileType: .optional,
                                            title: "firmwarei.bin"),
                    "nandi.bin" : SystemFile(path: "system_data",
                                            system: .grape,
                                            systemFileType: .optional,
                                            title: "nandi.bin")
                ]
            ],
            .kiwi : [
                "artworks" : [:],
                "games" : [:],
                "save_states" : [:]
            ],
            .mandarine : [
                "artworks" : [:],
                "memory_cards" : [:],
                "games" : [:],
                "save_states" : [:],
                "system_data" : [
                    "bios.bin" : SystemFile(path: "system_data",
                                            system: .mandarine,
                                            systemFileType: .required,
                                            title: "bios.bin")
                ]
            ],
            .tomato : [
                "artworks" : [:],
                "games" : [:],
                "save_states" : [:],
                "system_data" : [
                    "bios.bin" : SystemFile(path: "system_data",
                                            system: .tomato,
                                            systemFileType: .required,
                                            title: "bios.bin")
                ]
            ]
        ]
        
        for system in await SystemNames.array {
            let systemDirectoryURL: URL = documentDirectoryURL.appending(component: await system.string)
            try createDirectoryIfNeeded(from: systemDirectoryURL)
            try fixSubfolders(for: systemDirectoryURL)
            
            if let subfoldersForSystem: [String : [String : SystemFile]] = subfoldersForSystems[system] {
                try loop(subfolders: subfoldersForSystem, for: systemDirectoryURL) { subfolderName in
                    let subfolderDirectoryURL: URL = systemDirectoryURL.appending(component: subfolderName)
                    try createDirectoryIfNeeded(from: subfolderDirectoryURL)
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
        let replacementSubfolderNames: [String : String] = [
            "memcards" : "memory_cards",
            "roms" : "games",
            "states" : "save_states",
            "sysdata" : "system_data"
        ]
        
        for (key, value) in replacementSubfolderNames {
            let oldDirectoryURL: URL = systemDirectoryURL.appending(component: key)
            if fileManager.fileExists(atPath: oldDirectoryURL.path) {
                try fileManager.moveItem(at: oldDirectoryURL, to: systemDirectoryURL
                    .appending(component: value))
            }
        }
    }
    
    private func loop(subfolders: [String : [String : SystemFile]], for systemDirectoryURL: URL, using handler: (String) throws -> Void) throws {
        for subfolderName in subfolders.keys {
            if let subfiles: [String : SystemFile] = subfolders[subfolderName] {
                for subfile in subfiles.values {
                    if !fileManager.fileExists(atPath: systemDirectoryURL
                        .appending(component: subfile.path)
                        .appending(component: subfile.title).path) {
                        unavailableSystemFiles.append(subfile)
                    }
                }
            }
            
            try handler(subfolderName)
        }
    }
}
