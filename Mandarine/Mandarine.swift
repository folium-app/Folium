//
//  MandarineSystem.swift
//  Mandarine
//
//  Created by Jarrod Norwell on 13/6/2026.
//

import Foundation

public class MandarineCommon {
    public init() {}
    
    public static var documentDirectoryURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    public static var mandarineDirectoryURL: String? {
        if let documentDirectoryURL {
            documentDirectoryURL.appending(component: "Mandarine").path
        } else {
            nil
        }
    }
}

public class MandarineSystem {
    public init() {}
    
    
    public func printAbout() {
        mandarine.print_about()
    }
    
    
    public func initializePaths() {
        mandarine.initialize_paths()
    }
    
    public func initializeMemoryCards() {
        mandarine.initialize_memory_cards()
    }
    
    public func initializeSystem() {
        mandarine.initialize_system()
    }
    
    
    public func destroySystem() {
        mandarine.destroy_system()
    }
    
    
    public func insertDisc(at url: URL) {
        mandarine.insert_disc(std.string(url.path))
    }
}
