//
//  MissingFile.swift
//  Folium
//
//  Created by Jarrod Norwell on 15/5/2024.
//

import Foundation

struct MissingFile : Codable, Comparable {
    struct FileDetails : Codable {
        enum Importance : Int, Codable {
            case optional, required
        }
        
        let core: Core
        let `extension`: String
        let importance: Importance
        let isSystem: Bool
        let name: String
        let nameWithoutExtension: String
    }
    
    static func < (lhs: MissingFile, rhs: MissingFile) -> Bool {
        lhs.fileDetails.nameWithoutExtension < rhs.fileDetails.nameWithoutExtension
    }
    
    static func == (lhs: MissingFile, rhs: MissingFile) -> Bool {
        lhs.fileDetails.nameWithoutExtension == rhs.fileDetails.nameWithoutExtension
    }
    
    let fileDetails: FileDetails
}
