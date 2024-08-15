//
//  Social.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 29/7/2024.
//

import Foundation

struct Social : Codable, Hashable {
    enum `Type` : String, Codable, Hashable {
        case twitter = "Twitter"
        
        enum CodingKeys : String, CodingKey {
            case twitter = "X"
        }
    }
    
    let type: `Type`
    let username: String
}