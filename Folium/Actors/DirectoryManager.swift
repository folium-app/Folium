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
    
    private func loop(subfolders: [String : [String : SystemFile]], for systemDirectoryURL: URL, using handler: (String) throws -> Void) throws {
        for subfolderName in subfolders.keys {
            if let subfiles: [String : SystemFile] = subfolders[subfolderName] {
                for subfile in subfiles.values {
                    if !fileManager.fileExists(atPath: systemDirectoryURL.appending(component: subfile.path).appending(component: subfile.title).path) {
                        unavailableSystemFiles.append(subfile)
                    }
                }
            }
            
            try handler(subfolderName)
        }
    }
}
