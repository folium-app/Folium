//
//  NintendoEntertainmentSystemGame.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 22/2/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Foundation

// MARK: Class for the Nintendo Entertainment System core,
class NintendoEntertainmentSystemGame : GameBase, @unchecked Sendable {
    static func titleFromHeader(for url: URL) throws -> String {
        let title = url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: "")
        return title
    }
}
