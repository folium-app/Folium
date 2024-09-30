//
//  SkinManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 13/6/2024.
//

import Foundation
import UIKit

class SkinManager {
    static let shared = SkinManager()
    
    var skins: [Skin] = []
    func getSkins() throws {
        skins.removeAll()
        
        enum SkinError : Error {
            case enumeratorFailed
        }
        
        let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        guard let enumerator = FileManager.default.enumerator(at: documentDirectory, includingPropertiesForKeys: [.isRegularFileKey]) else {
            throw SkinError.enumeratorFailed
        }
        
        try enumerator.forEach { element in
            switch element {
            case let url as URL:
                let attributes = try url.resourceValues(forKeys: [.isRegularFileKey])
                if let isRegularFile = attributes.isRegularFile, isRegularFile {
                    if url.lastPathComponent.lowercased() == "info.json" {
                        let data = try Data(contentsOf: url)
                        var skin = try JSONDecoder().decode(Skin.self, from: data)
                        skin.url = url.deletingLastPathComponent()
                        
                        if skin.skinSupportsCurrentDevice() {
                            skins.append(skin)
                        }
                    }
                }
            default:
                break
            }
        }
    }
    
    func skins(for core: Core) -> [Skin] {
        skins.filter { $0.core == core }
    }
    
    func skin(from url: URL) throws -> Skin {
        let url = url.appendingPathComponent("info.json", conformingTo: .fileURL)
        let data = try Data(contentsOf: url)
        var skin = try JSONDecoder().decode(Skin.self, from: data)
        skin.url = url.deletingLastPathComponent()
        return skin
    }
}
