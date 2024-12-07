// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public struct DirectoryManager {
    public static let shared = DirectoryManager()
    
    fileprivate var directories: [String : [String : [String : MissingFile]]] {
        [
            "Cytrus" : [ // 3DS
                "cache" : [:],
                "cheats" : [:],
                "config" : [:],
                "dump" : [:],
                "external_dlls" : [:],
                "icons" : [:],
                "load" : [:],
                "log" : [:],
                "nand" : [:],
                "roms" : [:],
                "sdmc" : [:],
                "shaders" : [:],
                "skins" : [:],
                "states" : [:],
                "sysdata" : [
                    "aes_keys.txt" : .init(core: "Cytrus", extension: "txt", importance: .optional, isSystemFile: true, name: "aes_keys.txt", nameWithoutExtension: "aes_keys")
                ]
            ],
            "Grape" : [ // NDS/NDSi
                "config" : [:],
                "roms" : [:],
                "sysdata" : [
                    "bios7.bin" : .init(core: "Grape", extension: "bin", importance: .required, isSystemFile: true, name: "bios7.bin", nameWithoutExtension: "bios7"),
                    "bios9.bin" : .init(core: "Grape", extension: "bin", importance: .required, isSystemFile: true, name: "bios9.bin", nameWithoutExtension: "bios9"),
                    "firmware.bin" : .init(core: "Grape", extension: "bin", importance: .required, isSystemFile: true, name: "firmware.bin", nameWithoutExtension: "firmware"),
                    "gba_bios.bin" : .init(core: "Grape", extension: "bin", importance: .optional, isSystemFile: true, name: "gba_bios.bin", nameWithoutExtension: "gba_bios")
                ]
            ],
            "Guava" : [ // N64
                "roms" : [:],
                "sysdata" : [:]
            ],
            "Kiwi" : [ // GB/GBC
                "roms" : [:]
            ],
            "Lychee" : [ // PS1
                "roms" : [:],
                "sysdata" : [
                    "bios.bin" : .init(core: "Lychee", extension: "bin", importance: .required, isSystemFile: true, name: "bios.bin", nameWithoutExtension: "bios")
                ]
            ],
            "Mango" : [ // SNES
                "roms" : [:]
            ],
            "Tomato" : [ // GBA
                "roms" : [:]
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
                        let coreSubdirectory = coreDirectory.appendingPathComponent($0.key)
                        if !FileManager.default.fileExists(atPath: coreSubdirectory.path) {
                            try FileManager.default.createDirectory(at: coreSubdirectory, withIntermediateDirectories: false)
                        }
                    }
                } else {
                    try $1.forEach {
                        let coreSubdirectory = coreDirectory.appendingPathComponent($0.key)
                        if !FileManager.default.fileExists(atPath: coreSubdirectory.path) {
                            try FileManager.default.createDirectory(at: coreSubdirectory, withIntermediateDirectories: false)
                        }
                    }
                }
            }
        }
    }
    
    public func scanDirectoryForMissingFiles(for core: String) -> [MissingFile] {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        guard let directory = directories.first(where: { $0.key == core }) else {
            return []
        }
        
        var files: [MissingFile] = []
        
        directory.value.forEach { subdirectory, fileNames in
            let coreSubdirectory = documentsDirectory.appendingPathComponent(directory.key, conformingTo: .folder)
                .appendingPathComponent(subdirectory, conformingTo: .folder)
            fileNames.forEach { fileName, missingFile in
                if !FileManager.default.fileExists(atPath: coreSubdirectory.appendingPathComponent(fileName, conformingTo: .fileURL).path) {
                    files.append(missingFile)
                }
            }
        }
        
        return files
    }
}
