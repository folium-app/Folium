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

@objcMembers
public class GrapeCommon : NSObject {
    public override init() {}
    
    public static var documentDirectoryURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    public static var grapeDirectoryURL: URL? {
        if let documentDirectoryURL {
            documentDirectoryURL.appending(component: "Grape")
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
    
    public func initializePaths() {
        grape.initialize_paths()
    }
    
    public func initializeSystem() {
        grape.initialize_system()
    }
    
    public func destroySystem() {
        grape.destroy_system()
    }
    
    public func insertDisc(at url: URL) {
        grape.insert_disc(std.string(url.path))
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
        grape.start()
    }
    
    public func stop() {
        grape.stop()
    }
    
    public var framebufferHeight: Int32 {
        grape.framebuffer_height()
    }
    
    public var framebufferWidth: Int32 {
        grape.framebuffer_width()
    }
    
    public nonisolated func videoBuffer(callback: grape.VideoBufferCallback) {
        grape.video_buffer_callback(callback)
    }
    
    public nonisolated func press(button: GrapeButton) {
        grape.press_button(button.uint32)
    }
    
    public nonisolated func release(button: GrapeButton) {
        grape.release_button(button.uint32)
    }
    
    public func touchBegan(x: UInt16, y: UInt16) {
        grape.touch_began(x, y)
    }
    
    public func touchEnded() {
        grape.touch_ended()
    }
    
    public func touchMoved(x: UInt16, y: UInt16) {
        grape.touch_moved(x, y)
    }
    
    public func setContext(context: UnsafeMutableRawPointer) {
        grape.set_context(context)
    }
    
    public func boxart(for url: URL) -> SendableBoxart {
        SendableBoxart(buffer: grape.icon_from_disc(std.string(url.path)))
    }
}
