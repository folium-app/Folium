//
//  File.swift
//  DirectoryManager
//
//  Created by Jarrod Norwell on 6/12/2024.
//

import Foundation
import UIKit

public struct MissingFile : Codable, Hashable, @unchecked Sendable {
    public enum Importance : Int, Codable, Hashable, @unchecked Sendable {
        case optional, required
        
        public var color: UIColor {
            switch self {
            case .optional:
                .systemOrange
            case .required:
                .systemRed
            }
        }
        
        public var string: String {
            switch self {
            case .optional:
                "Optional"
            case .required:
                "Required"
            }
        }
    }
    
    public var details: String? = nil
    public let core, `extension`: String
    public let importance: Importance
    public let isSystemFile: Bool
    public let name, nameWithoutExtension: String
}
