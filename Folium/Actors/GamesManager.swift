//
//  GamesManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 3/6/2026.
//

import Foundation

actor GamesManager {
    private var empty: [URL] = []
    
    func mandarine() async -> [URL] {
        guard let documentDirectoryURL: URL = await .documentDirectoryURL else {
            return empty
        }
        
        let cytrusDirectoryURL: URL = documentDirectoryURL.appending(component: "Cytrus")
        
        guard let directoryEnumerator: FileManager.DirectoryEnumerator = FileManager.default.enumerator(atPath: cytrusDirectoryURL.path) else {
            return empty
        }
        
        let direcoryEnumeratorURLs: [NSEnumerator.Element] = directoryEnumerator.filter { element in element is URL }
        
        let games: [URL] = [] // TODO: Change to actual games class
        for case _ as URL in direcoryEnumeratorURLs {
            
        }
        
        return games
    }
}
