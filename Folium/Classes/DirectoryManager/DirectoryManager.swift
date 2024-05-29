//
//  DirectoryManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 15/5/2024.
//

import Foundation

class DirectoryManager {
    static let shared = DirectoryManager()
    
    func directories() -> [String : [String : [String : MissingFile.FileDetails]]] {
        [
            "Cytrus" : [
                "cache" : [:],
                "cheats" : [:],
                "config" : [:],
                "dump" : [:],
                "external_dlls" : [:],
                "load" : [:],
                "log" : [:],
                "nand" : [:],
                "roms" : [:],
                "sdmc" : [:],
                "shaders" : [:],
                "states" : [:],
                "sysdata" : [
                    "aes_keys.txt" : .init(core: .cytrus, extension: "txt", importance: .required, isSystem: true, name: "aes_keys.txt",
                        nameWithoutExtension: "aes_keys")
                ]
            ],
            "Grape" : [
                "config" : [:],
                "roms" : [:],
                "saves" : [:],
                "sysdata" : [
                    "bios7.bin" : .init(core: .grape, extension: "bin", importance: .required, isSystem: true, name: "bios7.bin",
                        nameWithoutExtension: "bios7"),
                    "bios9.bin" : .init(core: .grape, extension: "bin", importance: .required, isSystem: true, name: "bios9.bin",
                        nameWithoutExtension: "bios9"),
                    "firmware.bin" : .init(core: .grape, extension: "bin", importance: .required, isSystem: true, name: "firmware.bin",
                        nameWithoutExtension: "firmware"),
                    "gba_bios.bin" : .init(core: .grape, extension: "bin", importance: .optional, isSystem: true, name: "gba_bios.bin",
                        nameWithoutExtension: "gba_bios"),
                    "sdcard.img" : .init(core: .grape, extension: "img", importance: .optional, isSystem: false, name: "sdcard.img",
                        nameWithoutExtension: "sdcard")
                ]
            ],
            "Kiwi" : [
                "config" : [:],
                "roms" : [:]
            ]/*,
              "Lychee" : [
              "roms" : [:],
              "sysdata" : [
              "bios.bin" : .init(importance: .required, isFromSystem: true)
              ]
              ],
              "Peach" : [
              "config" : [:],
              "roms" : [:]
              ]*/
        ]
    }
    
    func createMissingDirectoriesInDocumentsDirectory() throws {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try directories().forEach { directory, subdirectories in
            let coreDirectory = documentsDirectory.appendingPathComponent(directory, conformingTo: .folder)
            if !FileManager.default.fileExists(atPath: coreDirectory.path) {
                try FileManager.default.createDirectory(at: coreDirectory, withIntermediateDirectories: false)
                
                try subdirectories.forEach { subdirectory, files in
                    let coreSubdirectory = coreDirectory.appendingPathComponent(subdirectory, conformingTo: .folder)
                    if !FileManager.default.fileExists(atPath: coreSubdirectory.path) {
                        try FileManager.default.createDirectory(at: coreSubdirectory, withIntermediateDirectories: false)
                    }
                }
            } else {
                try subdirectories.forEach { subdirectory, files in
                    let coreSubdirectory = coreDirectory.appendingPathComponent(subdirectory, conformingTo: .folder)
                    if !FileManager.default.fileExists(atPath: coreSubdirectory.path) {
                        try FileManager.default.createDirectory(at: coreSubdirectory, withIntermediateDirectories: false)
                    }
                }
            }
        }
    }
    
    func scanDirectoriesForRequiredFiles(_ core: Core) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        guard let directory = directories().first(where: { $0.key == core.rawValue }) else {
            return
        }
        
        directory.value.forEach { subdirectory, fileNames in
            let coreSubdirectory = documentsDirectory.appendingPathComponent(directory.key, conformingTo: .folder)
                .appendingPathComponent(subdirectory, conformingTo: .folder)
            fileNames.forEach { fileName, fileDetails in
                if !FileManager.default.fileExists(atPath: coreSubdirectory.appendingPathComponent(fileName, conformingTo: .fileURL).path) {
                    var fileDetails = fileDetails
                    fileDetails.path = coreSubdirectory.appendingPathComponent(fileName, conformingTo: .fileURL)
                    switch core {
                    case .cytrus:
                        LibraryManager.shared.cytrusManager.library.add(.init(fileDetails: fileDetails))
                    case .grape:
                        LibraryManager.shared.grapeManager.library.add(.init(fileDetails: fileDetails))
                    case .kiwi:
                        LibraryManager.shared.kiwiManager.library.add(.init(fileDetails: fileDetails))
                    }
                }
            }
        }
    }
}
