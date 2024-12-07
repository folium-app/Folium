//
//  File.swift
//  DirectoryManager
//
//  Created by Jarrod Norwell on 6/12/2024.
//

import Foundation
import UIKit

public struct MissingFile : Codable {
    public enum Importance : Int, Codable {
        case optional, required
        
        public var color: UIColor {
            switch self {
            case .optional:
                .systemOrange
            case .required:
                .systemRed
            }
        }
    }
    
    public let core, `extension`: String
    public let importance: Importance
    public let isSystemFile: Bool
    public let name, nameWithoutExtension: String
}
