//
//  Skin.swift
//  Folium
//
//  Created by Jarrod Norwell on 13/6/2024.
//

import Foundation

struct Skin : Codable, Hashable {
    let author, description, name: String
    let core: Core
    
    let devices: [Device]
    
    var isDebug: Bool? = false
    
    var path: URL? = nil
}
