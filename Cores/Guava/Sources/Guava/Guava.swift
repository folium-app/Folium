// The Swift Programming Language
// https://docs.swift.org/swift-book

import GuavaObjC

public struct Guava : @unchecked Sendable {
    public static let shared = Guava()
    
    var emulator: GuavaObjC = .shared()
    
    public func insert(cartridge: URL) { emulator.insertCartridge(cartridge) }
    
    public func step() { emulator.step() }
    
    public func rgba5551(_ framebuffer: @escaping (UnsafeMutablePointer<UInt16>, Int32, Int32) -> Void) { emulator.framebufferRGBA5551 = framebuffer }
    public func abgr8888(_ framebuffer: @escaping (UnsafePointer<UInt8>, Int32, Int32) -> Void) { emulator.framebufferABGR8888 = framebuffer }
}
