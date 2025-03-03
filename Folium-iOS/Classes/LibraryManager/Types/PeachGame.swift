//
//  PeachGame.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 2/3/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Foundation

class PeachGame : GameBase, @unchecked Sendable {
    static func title(for url: URL) -> String { url.deletingPathExtension().lastPathComponent }
}
