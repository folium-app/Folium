//
//  PeerToPeer.swift
//  Folium
//
//  Created by Jarrod Norwell on 5/7/2026.
//

import Foundation

import Mandarine

nonisolated struct P2PMandarineButton : Codable {
    let data: Data
    let pressed: Bool
}

nonisolated struct P2PMandarineFrame : Codable {
    let data: Data
}

nonisolated enum P2PDataType : Codable {
    case button(System)
    case frame(System)
    case prepare(System)
}

nonisolated struct P2PPacket : Codable {
    var data: Data
    let dataType: P2PDataType
}
