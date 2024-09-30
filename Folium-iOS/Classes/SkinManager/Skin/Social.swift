//
//  Social.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 29/7/2024.
//

import Foundation

struct Social : Codable, Hashable {
    enum `Type` : String, Codable, Hashable {
        case discord = "discord"
        case reddit = "reddit"
        case twitter = "twitter"
        case youtube = "youtube"
        
        enum CodingKeys : String, CodingKey {
            case twitter = "x" // gross
        }
    }
    
    let type: `Type`
    let username: String
}
