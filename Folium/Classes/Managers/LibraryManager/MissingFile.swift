//
//  MissingFile.swift
//  Folium
//
//  Created by Jarrod Norwell on 15/5/2024.
//

import Foundation
import UIKit

class MissingFile : AnyHashableSendable, @unchecked Sendable {
    struct FileDetails : Codable, Hashable {
        enum Importance : Int, Codable, Hashable {
            case optional, required
            
            var color: UIColor {
                switch self {
                case .optional:
                        .systemOrange
                case .required:
                        .systemRed
                }
            }
        }
        
        let core: Core
        let `extension`: String
        let importance: Importance
        let isSystem: Bool
        let name: String
        let nameWithoutExtension: String
        var path: URL? = nil
    }
    
    static func < (lhs: MissingFile, rhs: MissingFile) -> Bool {
        lhs.fileDetails.nameWithoutExtension < rhs.fileDetails.nameWithoutExtension
    }
    
    static func == (lhs: MissingFile, rhs: MissingFile) -> Bool {
        lhs.fileDetails.nameWithoutExtension == rhs.fileDetails.nameWithoutExtension
    }
    
    let fileDetails: FileDetails
    
    init(fileDetails: FileDetails) {
        self.fileDetails = fileDetails
    }
}
