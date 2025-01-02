// The Swift Programming Language
// https://docs.swift.org/swift-book

import CherryObjC

public struct Cherry : @unchecked Sendable {
    public static let shared = Cherry()
    
    public let cherryObjC = CherryObjC.shared()
    
    public func insertCartridge(from url: URL) {
        cherryObjC.insertCartridge(url)
    }
    
    public func step() {
        cherryObjC.step()
    }
    
    public func stop() {
        
    }
    
    public func buffer(_ buf: @escaping (UnsafeMutablePointer<UInt32>) -> Void) {
        cherryObjC.buffer = buf
    }
    
    public func gameID(from url: URL) -> String {
        cherryObjC.gameID(url)
            .replacingOccurrences(of: "_", with: "-")
            .replacingOccurrences(of: ".", with: "")
    }
}
