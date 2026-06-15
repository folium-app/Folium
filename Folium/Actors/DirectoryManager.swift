//
//  DirectoryManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 11/6/2026.
//

import Foundation
import UIKit

struct SystemFile {
    enum SystemFileType : Int {
        case optional = 0
        case required = 1
        
        var string: String {
            switch self {
            case .optional:
                "Optional"
            case .required:
                "Required"
            }
        }
        
        var tintColor: UIColor {
            switch self {
            case .optional:
                UIColor.systemOrange
            case .required:
                UIColor.systemRed
            }
        }
    }
    
    let path: String
    let system: String
    let systemFileType: SystemFileType
    let title: String
}

actor DirectoryManager {
    private let fileManager: FileManager = FileManager.default
    
    func initializeSystemDirectoriesForInitialLaunch() async throws {
        let systemNames: [String] = ["Cytrus", "Grape", "Guava", "Kiwi", "Mandarine", "Mango", "Plum", "Tomato"].sorted()
        let subfoldersForSystemNames: [String : [String : [String : SystemFile]]] = [
            "Mandarine" : [
                "artworks" : [:],
                "memory_cards" : [:],
                "games" : [:],
                "save_states" : [:],
                "system_data" : [
                    "bios.bin" : SystemFile(path: "system_data",
                                            system: "Mandarine",
                                            systemFileType: .required,
                                            title: "bios.bin")
                ]
            ]
        ]
        
        guard let documentDirectoryURL: URL = await .documentDirectoryURL else {
            return
        }
        
        let contents: [String] = try fileManager.contentsOfDirectory(atPath: documentDirectoryURL.path).sorted()
        for systemName in systemNames {
            let systemSubdirectoryURL: URL = documentDirectoryURL.appending(component: systemName)
            if contents != systemNames {
                try createDirectoryIfNeeded(from: systemSubdirectoryURL)
            }
            
            if let subfoldersForSystemName: [String : [String : SystemFile]] = subfoldersForSystemNames[systemName] {
                try loop(subfolders: subfoldersForSystemName, for: systemSubdirectoryURL) { subfolderName in
                    let subfolderSubdirectoryURL: URL = systemSubdirectoryURL.appending(component: subfolderName)
                    try createDirectoryIfNeeded(from: subfolderSubdirectoryURL)
                }
            }
        }
    }
    
    private func createDirectoryIfNeeded(from url: URL) throws {
        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: false)
        }
    }
    
    private func loop(subfolders: [String : [String : SystemFile]], for systemSubdirectoryURL: URL, handler: (String) throws -> Void) throws {
        for subfolderName in subfolders.keys {
            if let subfiles: [String : SystemFile] = subfolders[subfolderName] {
                for _ in subfiles.values {
                    // print(systemSubdirectoryURL.lastPathComponent, subfile)
                }
            }
            
            try handler(subfolderName)
        }
    }
}
