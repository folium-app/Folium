//
//  NewGrape.swift
//  NewGrape
//
//  Created by Jarrod Norwell on 4/3/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

public enum NDSKey : UInt32 {
    case a = 1
    case b = 2
    case x = 1024
    case y = 2048
    case select = 4
    case start = 8
    case right = 16
    case left = 32
    case up = 64
    case down = 128
    case l = 512
    case r = 256
}

public struct NewGrape : @unchecked Sendable {
    public static let shared = NewGrape()
    
    fileprivate let emulator = NewGrapeObjC.shared()
    
    public func insert(from url: URL) { emulator.insert(from: url) }
    
    public func step() { emulator.step() }
    
    public func pause() { /* TODO */ }
    public func stop() { emulator.stop() }
    
    public func ab(_ buf: @escaping (UnsafeMutablePointer<Int16>, Int32) -> Void) { emulator.ab = buf }
    public func fbs(_ buf: @escaping (UnsafeMutablePointer<UInt32>, UnsafeMutablePointer<UInt32>) -> Void) { emulator.fbs = buf }
    
    public func touchBegan(at point: CGPoint) { emulator.touchBegan(at: point) }
    public func touchEnded() { emulator.touchEnded() }
    public func touchMoved(at point: CGPoint) { emulator.touchMoved(at: point) }
    
    public func button(button: NDSKey, pressed: Bool) { emulator.button(button.rawValue, pressed: pressed) }
    
    public func loadState(_ completionHandler: @escaping (Bool) -> Void) { completionHandler(emulator.loadState()) }
    public func saveState(_ completionHandler: @escaping (Bool) -> Void) { completionHandler(emulator.saveState()) }
    
    public func updateSettings() { emulator.updateSettings() }
}
