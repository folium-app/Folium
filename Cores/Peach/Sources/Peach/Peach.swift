// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import PeachObjC

public struct Peach : @unchecked Sendable {
    public static let shared = Peach()
    
    var emulator: PeachObjC = .shared()
    
    public func insert(cartridge: URL) { emulator.insert(cartridge: cartridge) }
    public func step() { emulator.step() }
    
    public func framebuffer() -> UnsafeMutablePointer<UInt32> { emulator.framebuffer() }
    
    public func width() -> Int32 { emulator.width() }
    public func height() -> Int32 { emulator.height() }
    
    public func button(button: UInt8, player: Int, pressed: Bool) { emulator.button(button, player: .init(player), pressed: pressed) }
}
