//
//  Cherry.swift
//  Cherry
//
//  Created by Jarrod Norwell on 9/8/2026.
//

import Foundation

public enum CherryButton : Int32, Codable {
    case button8 = 1,
         button4 = 2,
         button5 = 3,
         buttonBlue = 4,
         button7 = 5,
         buttonHash = 6,
         button2 = 7,
         buttonPurple = 8,
         buttonAsterisk = 9,
         button0 = 10,
         button9 = 11,
         button3 = 12,
         button1 = 13,
         button6 = 14,
         buttonUp = 16,
         buttonRight = 17,
         buttonDown = 18,
         buttonLeft = 19,
         buttonLeftTrigger = 20,
         buttonRightTrigger = 21
    
    var int32: Int32 { rawValue }
}

public class CherryCommon {
    public init() {}
    
    public static var documentDirectoryURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    public static var cherryDirectoryURL: String? {
        if let documentDirectoryURL {
            documentDirectoryURL.appending(component: "Cherry").path
        } else {
            nil
        }
    }
}

public actor CherrySystem {
    private var fileManager: FileManager = .default
    
    public init() {}
    
    public func printAbout() {
        cherry.print_about()
    }
    
    
    public func initializePaths() {
        cherry.initialize_paths()
    }
    
    public func initializeSystem() {
        cherry.initialize_system()
    }
    
    
    public func destroySystem() {
        cherry.destroy_system()
    }
    
    
    public func insertDisc(at url: URL) {
        cherry.insert_disc(std.string(url.path))
    }
    
    
    public func set(change: Bool = false, isRunning: Bool = false) {
        if change {
            running = isRunning
        }
    }
    
    public var running: Bool {
        get {
            cherry.is_running()
        }
        set {
            cherry.is_running(true, newValue)
        }
    }
    
    public func set(change: Bool = false, isPaused: Bool = false) {
        if change {
            paused = isPaused
        }
    }
    
    public var paused: Bool {
        get {
            cherry.is_paused()
        }
        set {
            cherry.is_paused(true, newValue)
        }
    }
    
    public func start() {
        cherry.start()
    }
    
    public func stop() {
        cherry.stop()
    }
    
    
    public nonisolated func press(button: CherryButton, index: Int32) {
        cherry.press_button(button.int32, index)
    }
    
    public nonisolated func release(button: CherryButton, index: Int32) {
        cherry.release_button(button.int32, index)
    }
    
    
    public var framebufferHeight: Int32 {
        cherry.framebuffer_height()
    }
    
    public var framebufferWidth: Int32 {
        cherry.framebuffer_width()
    }
    
    
    public nonisolated func videoBuffer(callback: cherry.VideoBufferCallback) {
        cherry.video_buffer_callback(callback)
    }
    
    
    public func setContext(context: UnsafeMutableRawPointer) {
        cherry.set_context(context)
    }
}
