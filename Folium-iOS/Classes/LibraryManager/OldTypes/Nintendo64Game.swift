//
//  Nintendo64Game.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 18/7/2024.
//

import Foundation

// MARK: Class for the Nintendo 64 core, Guava
class Nintendo64Game : GameBase, @unchecked Sendable {
    static func title(for url: URL) -> String {
        url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: "")
    }
}
