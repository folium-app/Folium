//
//  Grape.swift
//  Grape
//
//  Created by Jarrod Norwell on 28/6/2026.
//

import Foundation

public enum GrapeButton : UInt32 {
    case a = 0x00000001,
         b = 0x00000002,
         x = 0x00000400,
         y = 0x00000800
    
    case right  = 0x00000010,
         left   = 0x00000020,
         up     = 0x00000040,
         down   = 0x00000080
    
    case select = 0x00000004,
         start  = 0x00000008
    
    case l = 0x00000200,
         r = 0x00000100
    
    var uint32: UInt32 { rawValue }
}

public class GrapeCommon {
    public init() {}
    
    public static var documentDirectoryURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    public static var grapeDirectoryURL: String? {
        if let documentDirectoryURL {
            documentDirectoryURL.appending(component: "Grape").path
        } else {
            nil
        }
    }
}

public struct SendableBoxart : @unchecked Sendable {
    public let buffer: UnsafeMutablePointer<UInt32>
}

public actor GrapeSystem {
    private var fileManager: FileManager = .default
    
    public init() {}
    
    public func printAbout() {
        grape.print_about()
    }
    
    public func set(change: Bool = false, isRunning: Bool = false) {
        if change {
            running = isRunning
        }
    }
    
    public var running: Bool {
        get {
            grape.is_running()
        }
        set {
            grape.is_running(true, newValue)
        }
    }
    
    public func set(change: Bool = false, isPaused: Bool = false) {
        if change {
            paused = isPaused
        }
    }
    
    public var paused: Bool {
        get {
            grape.is_paused()
        }
        set {
            grape.is_paused(true, newValue)
        }
    }
    
    public func start() {
        
    }
    
    public func stop() {
        
    }
    
    public nonisolated func press(button: GrapeButton) {
        grape.press_button(button.uint32)
    }
    
    public nonisolated func release(button: GrapeButton) {
        grape.release_button(button.uint32)
    }
    
    public func boxart(for url: URL) -> SendableBoxart {
        SendableBoxart(buffer: grape.icon_from_disc(std.string(url.path)))
    }
}
