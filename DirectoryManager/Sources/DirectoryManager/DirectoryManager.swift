// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public struct DirectoryManager {
    public static let shared = DirectoryManager()
    
    fileprivate var directories: [String : [String]] {
        [
            "Cytrus" : [ // 3DS
                "cache",
                "cheats",
                "config",
                "dump",
                "external_dlls",
                "icons",
                "load",
                "log",
                "nand",
                "roms",
                "sdmc",
                "shaders",
                "skins",
                "states",
                "sysdata"
            ],
            "Grape" : [ // NDS/NDSi
                "config",
                "roms",
                "sysdata"
            ],
            "Guava" : [ // N64
                "roms",
                "sysdata"
            ],
            "Kiwi" : [ // GB/GBC
                "roms"
            ],
            "Lychee" : [ // PS1
                "roms",
                "sysdata"
            ],
            "Mango" : [ // SNES
                "roms"
            ],
            "Tomato" : [ // GBA
                "roms"
            ]
        ]
    }
    
    public func createMissingDirectoriesInDocumentsDirectory(for cores: [String]) throws {
        let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        try directories.forEach {
            if cores.contains($0) {
                let coreDirectory = if #available(iOS 16, *) {
                    documentsDirectory.appending(component: $0)
                } else {
                    documentsDirectory.appendingPathComponent($0)
                }
                
                if !FileManager.default.fileExists(atPath: coreDirectory.path) {
                    try FileManager.default.createDirectory(at: coreDirectory, withIntermediateDirectories: false)
                    
                    try $1.forEach {
                        let coreSubdirectory = coreDirectory.appendingPathComponent($0)
                        if !FileManager.default.fileExists(atPath: coreSubdirectory.path) {
                            try FileManager.default.createDirectory(at: coreSubdirectory, withIntermediateDirectories: false)
                        }
                    }
                } else {
                    try $1.forEach {
                        let coreSubdirectory = coreDirectory.appendingPathComponent($0)
                        if !FileManager.default.fileExists(atPath: coreSubdirectory.path) {
                            try FileManager.default.createDirectory(at: coreSubdirectory, withIntermediateDirectories: false)
                        }
                    }
                }
            }
        }
    }
}
