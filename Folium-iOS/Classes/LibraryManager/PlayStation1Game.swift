//
//  PlayStation1Game.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 29/7/2024.
//

import Foundation

// MARK: Class for the PlayStation 1 core, Lychee
class PlayStation1Game : GameBase, @unchecked Sendable {
    static func titleFromHeader(for url: URL) throws -> String {
        url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: "")
    }
}
