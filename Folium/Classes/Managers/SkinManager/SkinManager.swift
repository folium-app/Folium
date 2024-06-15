//
//  SkinManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 13/6/2024.
//

import Foundation

class SkinManager {
    var skins: [Skin] = []
    
    func skins(for core: Core, root: URL) throws {
        enum SkinError : Error {
            case enumeratorFailed
        }
        
        let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let coreDirectory = documentsDirectory.appendingPathComponent(core.rawValue, conformingTo: .folder)
        
        guard let enumerator = FileManager.default.enumerator(at: coreDirectory
            .appendingPathComponent("skins", conformingTo: .folder), includingPropertiesForKeys: [.isRegularFileKey]) else {
            throw SkinError.enumeratorFailed
        }
        
        try enumerator.forEach { element in
            switch element {
            case let url as URL:
                let attributes = try url.resourceValues(forKeys: [.isRegularFileKey])
                if let isRegularFile = attributes.isRegularFile, isRegularFile {
                    let pathExtension = url.pathExtension.lowercased()
                    if pathExtension == "json" {
                        let data = try Data(contentsOf: url)
                        var skin = try JSONDecoder().decode(Skin.self, from: data)
                        skin.path = url.deletingLastPathComponent()
                        
                        skins.append(skin)
                    }
                }
            default:
                break
            }
        }
    }
}
