//
//  MandarineSystem.swift
//  Mandarine
//
//  Created by Jarrod Norwell on 13/6/2026.
//

import UIKit

public enum MandarineButton : UInt32 {
    case circle = 0x00000001,
         cross = 0x00000002,
         triangle = 0x00000003,
         square = 0x00000004
    
    case right  = 0x00000005,
         left   = 0x00000006,
         up     = 0x00000007,
         down   = 0x00000008
    
    case select = 0x00000009,
         start  = 0x0000000A
    
    case l1 = 0x0000000B,
         r1 = 0x0000000C
    
    case l2 = 0x0000000D,
         r2 = 0x0000000E
    
    case l3 = 0x0000000F,
         r3 = 0x00000010
    
    case leftUp = 0x00000011,
         leftRight = 0x00000012,
         leftDown = 0x00000013,
         leftLeft = 0x00000014
    
    case rightUp = 0x00000015,
         rightRight = 0x00000016,
         rightDown = 0x00000017,
         rightLeft = 0x00000018
    
    var string: String {
        switch self {
        case .circle:
            "circle"
        case .cross:
            "cross"
        case .triangle:
            "triangle"
        case .square:
            "square"
        case .right:
            "dpad_right"
        case .left:
            "dpad_left"
        case .up:
            "dpad_up"
        case .down:
            "dpad_down"
        case .select:
            "select"
        case .start:
            "start"
        case .l1:
            "l1"
        case .r1:
            "r1"
        case .l2:
            "l2"
        case .r2:
            "r2"
        case .l3:
            "l3"
        case .r3:
            "r3"
            
        case .leftUp:
            "l_up"
        case .leftRight:
            "l_right"
        case .leftDown:
            "l_down"
        case .leftLeft:
            "l_left"
            
        case .rightUp:
            "r_up"
        case .rightRight:
            "r_right"
        case .rightDown:
            "r_down"
        case .rightLeft:
            "r_left"
        }
    }
}

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

public actor MandarineSystem {
    private var fileManager: FileManager = .default
    
    public init() {}
    
    public func printAbout() {
        mandarine.print_about()
    }
    
    public nonisolated func identifier(for url: URL) -> String {
        String(mandarine.disc_identifier(std.string(url.path)))
            .replacingOccurrences(of: "_", with: "-")
            .replacingOccurrences(of: ".", with: "")
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
    
    public func set(change: Bool = false, isRunning: Bool = false) {
        if change {
            running = isRunning
        }
    }
    
    public var running: Bool {
        get {
            mandarine.is_running()
        }
        set {
            mandarine.is_running(true, newValue)
        }
    }
    
    public func set(change: Bool = false, isPaused: Bool = false) {
        if change {
            paused = isPaused
        }
    }
    
    public var paused: Bool {
        get {
            mandarine.is_paused()
        }
        set {
            mandarine.is_paused(true, newValue)
        }
    }
    
    public func start() {
        mandarine.start()
    }
    
    public func stop() {
        mandarine.stop()
    }
    
    public var framebufferStartX: Int16 {
        mandarine.framebuffer_start_x()
    }
    
    public var framebufferStartY: Int16 {
        mandarine.framebuffer_start_y()
    }
    
    public var framebufferHeight: Int32 {
        mandarine.framebuffer_height()
    }
    
    public var framebufferWidth: Int32 {
        mandarine.framebuffer_width()
    }
    
    
    public nonisolated func videoBuffer15Bit(callback: mandarine.VideoBufferCallback15Bit) {
        mandarine.video_buffer_callback_15bit(callback)
    }
    
    public nonisolated func videoBuffer24Bit(callback: mandarine.VideoBufferCallback24Bit) {
        mandarine.video_buffer_callback_24bit(callback)
    }
    
    
    public nonisolated func press(button: MandarineButton) {
        mandarine.press_button(std.string(button.string))
    }
    
    public nonisolated func release(button: MandarineButton) {
        mandarine.release_button(std.string(button.string))
    }
    
    public nonisolated func drag(thumbstick: String, value: UInt8) {
        mandarine.drag_thumbstick(std.string(thumbstick), value)
    }
    

    public func setContext(context: UnsafeMutableRawPointer) {
        mandarine.set_context(context)
    }
    
    
    public func setSetting<T>(setting: mandarine.SETTING, value: T) {
        switch value {
        case let boolSetting as Bool:
            mandarine.set_setting(setting, boolSetting)
        default:
            break
        }
    }
    
    
    public nonisolated func boxartURLString(for url: URL) -> String? {
        var link: String? = nil
        for file in files(from: url) {
            let id: String = identifier(for: url.deletingLastPathComponent().appending(component: file))
            if !id.isEmpty {
                link = "https://raw.githubusercontent.com/xlenore/psx-covers/refs/heads/main/covers/default/\(id).jpg"
                break
            }
        }
        
        return link
    }
    
    
    public nonisolated func totalSizeOfFiles(for url: URL) -> Int {
        var size: Int = 0
        for file in files(from: url) {
            let fileURL: URL = url.deletingLastPathComponent().appending(component: file)
            
            do {
                let resourceValues: URLResourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                if let fileSize: Int = resourceValues.fileSize {
                    size += fileSize
                }
            } catch {
                size = 0
            }
        }
        
        return size
    }
    
    
    public nonisolated func files(from url: URL) -> [String] {
        if let contents: String = try? String(contentsOf: url, encoding: .utf8) {
            let lines: [Substring] = contents.split(separator: "\n")
            
            var files: [String] = []
            lines.forEach { line in
                let trimmed: String = line.trimmingCharacters(in: .whitespaces)
                if trimmed.uppercased().starts(with: "FILE") {
                    let components: [String.SubSequence] = trimmed.split(separator: "\"", omittingEmptySubsequences: false)
                    if components.count >= 2 {
                        let path: String = String(components[1])
                        files.append(path)
                    }
                }
            }
            
            return files
        } else {
            return []
        }
    }
}
