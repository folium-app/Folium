//
//  PeerToPeer.swift
//  Folium
//
//  Created by Jarrod Norwell on 5/7/2026.
//

import Foundation

typealias P2PTomatoFramebuffer = Data

nonisolated struct P2PGame : Codable {
    let data: Data
    let game: Game
    let system: System
}

nonisolated enum P2PDataType : Codable {
    case tomatoFramebuffer
    case game
}

nonisolated struct P2PPacket : Codable {
    let data: Data
    let dataType: P2PDataType
}
