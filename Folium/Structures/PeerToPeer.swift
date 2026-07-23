//
//  PeerToPeer.swift
//  Folium
//
//  Created by Jarrod Norwell on 5/7/2026.
//

import Foundation

import Mandarine

nonisolated struct P2P : Codable {
    nonisolated struct Mandarine : Codable {
        nonisolated struct Button : Codable {
            let data: Data
            let pressed: Bool
        }
        
        nonisolated struct Frame : Codable {
            let data: Data
        }
    }
    
    nonisolated enum DataType : Codable {
        case button(System)
        case frame(System)
        case prepare(System)
    }

    nonisolated struct Packet : Codable {
        var data: Data
        let dataType: DataType
    }
}
