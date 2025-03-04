//
//  GameBase.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 2/3/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import CryptoKit
import Foundation

class AnyHashableSendable : NSObject, @unchecked Sendable {}
class GameBase : AnyHashableSendable, @unchecked Sendable {
    class FileDetails : AnyHashableSendable, @unchecked Sendable {
        let `extension`, name, nameWithoutExtension: String
        let url: URL
        
        init(extension: String, name: String, nameWithoutExtension: String, url: URL) {
            self.extension = `extension`
            self.name = name
            self.nameWithoutExtension = nameWithoutExtension
            self.url = url
        }
        
        var md5: String? = nil
        
        var size: String {
            let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
            
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            return formatter.string(fromByteCount: (attributes?[.size] ?? 0) as! Int64)
        }
        
        static func MD5(for url: URL) throws -> String {
            let handle = try FileHandle(forReadingFrom: url)
            var hasher = CryptoKit.Insecure.MD5()
            while try autoreleasepool(invoking: {
                guard let data = try handle.readToEnd(), !data.isEmpty else {
                    return false
                }
                
                hasher.update(data: data)
                return true
            }) { }
            
            return hasher.finalize().map { .init(format: "%02hhx", $0) }.joined()
        }
    }
    
    let core: String
    let fileDetails: FileDetails
    let skins: [Skin]
    let title: String
    
    init(core: String, fileDetails: FileDetails, skins: [Skin], title: String) {
        self.core = core
        self.fileDetails = fileDetails
        self.skins = skins
        self.title = title
    }
}
