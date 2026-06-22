//
//  Tomato.swift
//  Tomato
//
//  Created by Jarrod Norwell on 21/6/2026.
//

import Foundation

public enum TomatoButton : UInt8 {
    case a = 0
    case b = 1
    case select = 2
    case start = 3
    case right = 4
    case left = 5
    case up = 6
    case down = 7
    case r = 8
    case l = 9
    
    var uint8: UInt8 { rawValue }
}

public class TomatoCommon {
    public init() {}
    
    public static var documentDirectoryURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    public static var tomatoDirectoryURL: String? {
        if let documentDirectoryURL {
            documentDirectoryURL.appending(component: "Tomato").path
        } else {
            nil
        }
    }
}

public actor TomatoSystem {
    private var fileManager: FileManager = .default
    
    public init() {}
    
    public func printAbout() {
        tomato.print_about()
    }
    
    public func initializePaths() {
        tomato.initialize_paths()
    }
    
    public func initializeSystem() {
        tomato.initialize_system()
    }
    
    public func destroySystem() {
        tomato.destroy_system()
    }
    
    public func insertDisc(at url: URL) {
        tomato.insert_disc(std.string(url.path))
    }
    
    public func set(change: Bool = false, isRunning: Bool = false) {
        if change {
            running = isRunning
        }
    }
    
    public var running: Bool {
        get {
            tomato.is_running()
        }
        set {
            tomato.is_running(true, newValue)
        }
    }
    
    public func set(change: Bool = false, isPaused: Bool = false) {
        if change {
            paused = isPaused
        }
    }
    
    public var paused: Bool {
        get {
            tomato.is_paused()
        }
        set {
            tomato.is_paused(true, newValue)
        }
    }
    
    
    public func start() {
        tomato.start()
    }
    
    public func stop() {
        tomato.stop()
    }
    
    
    public var framebufferHeight: Int32 {
        tomato.framebuffer_height()
    }
    
    public var framebufferWidth: Int32 {
        tomato.framebuffer_width()
    }
    
    
    public nonisolated func press(button: TomatoButton) {
        tomato.press_button(button.uint8)
    }
    
    public nonisolated func release(button: TomatoButton) {
        tomato.release_button(button.uint8)
    }
    
    
    public nonisolated func videoBuffer(callback: tomato.VideoBufferCallback) {
        tomato.video_buffer_callback(callback)
    }
    
    
    public func setContext(context: UnsafeMutableRawPointer) {
        tomato.set_context(context)
    }
    
    
    public nonisolated func boxartURLString(for url: URL) -> String? {
        var title: String = url.deletingPathExtension().lastPathComponent
        title = title.replacingOccurrences(of: "&", with: "_")
        
        /*
        func code(from url: URL) throws -> String? {
            let file: FileHandle = try FileHandle(forReadingFrom: url)
            try file.seek(toOffset: 0x0AC)
            
            guard let data: Data = try file.read(upToCount: 0x04) else {
                return title
            }
            
            try file.close()
            
            guard let string: String = String(data: data, encoding: .ascii),
                  let destination: Substring = string.trimmingCharacters(in: .controlCharacters).split(separator: "").last else {
                return title
            }
            
            return String(destination).uppercased()
        }
         */
        
        return "https://raw.githubusercontent.com/libretro/libretro-thumbnails/refs/heads/master/Nintendo - Game Boy Advance/Named_Boxarts/\(title).png"
    }
}
