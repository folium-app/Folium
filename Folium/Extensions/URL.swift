//
//  URL.swift
//  Folium
//
//  Created by Jarrod Norwell on 3/6/2026.
//

import Foundation

extension URL {
    static var documentDirectoryURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
