// The Swift Programming Language
// https://docs.swift.org/swift-book

import Cytrus
import CryptoKit
import Foundation
import UIKit

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
        
        var sha256: String? {
            try? SHA256(for: url)
        }
        
        var size: String {
            let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
            
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            return formatter.string(fromByteCount: (attributes?[.size] ?? 0) as! Int64)
        }
        
        fileprivate func SHA256(for url: URL) throws -> String {
            let handle = try FileHandle(forReadingFrom: url)
            var hasher = CryptoKit.SHA256()
            
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
    let title: String
    
    init(core: String, fileDetails: FileDetails, title: String) {
        self.core = core
        self.fileDetails = fileDetails
        self.title = title
    }
}

enum Core : String, Codable, Hashable, @unchecked Sendable {
    case cytrus = "Cytrus"
    case grape = "Grape"
    case guava = "Guava"
    case kiwi = "Kiwi"
    case lychee = "Lychee"
    case tomato = "Tomato"
    
    var colors: [Button.`Type` : (UIColor, UIColor)] {
        switch self {
        case .cytrus:
            [
                .dpadUp : (.black, .white),
                .dpadDown : (.black, .white),
                .dpadLeft : (.black, .white),
                .dpadRight : (.black, .white),
                .a : isNintendo ? (.systemRed, .white) : (.systemRed, .white),
                .b : isNintendo ? (.systemYellow, .white) : (.systemBlue, .white),
                .x : isNintendo ? (.systemBlue, .white) : (.systemGreen, .white),
                .y : isNintendo ? (.systemGreen, .white) : (.systemPink, .white),
            ]
        default:
            [
                :
            ]
        }
    }
    
    var console: String {
        switch self {
        case .cytrus:
            "Nintendo 3DS, New Nintendo 3DS"
        case .grape:
            "Nintendo DS, Nintendo DSi"
        case .guava:
            "Nintendo 64"
        case .kiwi:
            "Game Boy, Game Boy Color"
        case .lychee:
            "PlayStation 1"
        case .tomato:
            "Game Boy Advance"
        }
    }
    
    var isNintendo: Bool {
        [.cytrus, .grape, .guava, .kiwi, .lychee, .tomato].contains(self)
    }
}

struct LibraryManager : @unchecked Sendable {
    static let shared = LibraryManager()
    
    var cores: [Core] {
        [.cytrus, .grape/*, .guava, .kiwi, .lychee, .tomato*/] // 3DS, NDS, N64, GB/GBC, PS1, GBA
    }
    
    func games() throws -> Result<[GameBase], Error> {
        enum GamesError : Error {
            case enumeratorFailed
        }
        
        guard let enumerator = FileManager.default.enumerator(at: try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false),
                                                              includingPropertiesForKeys: [.isRegularFileKey]) else {
            return .failure(GamesError.enumeratorFailed)
        }
        
        let result = Result {
            try enumerator.reduce(into: [GameBase]()) {
                switch $1 {
                case let url as URL:
                    let attributes = try url.resourceValues(forKeys: [.isRegularFileKey])
                    if let isRegularFile = attributes.isRegularFile, isRegularFile {
                        let extensions: [String] = ["gb", "gbc", "gba", "3ds", "ds", "nds", "dsi", "n64", "z64", "cue"]
                        if extensions.contains(url.pathExtension.lowercased()) {
                            print("\(#function): success: \(url.lastPathComponent)")
                            
                            let nameWithoutExtension = url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: "")
                            switch url.pathExtension.lowercased() {
                            case "gb", "gbc":
                                $0.append(GameBoyGame(core: "Kiwi", fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                                       name: url.lastPathComponent,
                                                                                       nameWithoutExtension: nameWithoutExtension,
                                                                                       url: url), title: try GameBoyGame.titleFromHeader(for: url)))
                            case "gba":
                                $0.append(GameBoyAdvanceGame(core: "Tomato", fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                                               name: url.lastPathComponent,
                                                                                               nameWithoutExtension: nameWithoutExtension,
                                                                                               url: url), title: try GameBoyAdvanceGame.titleFromHeader(for: url)))
                            case "3ds", "app", "cci", "cia", "cxi":
                                $0.append(Nintendo3DSGame(icon: try Nintendo3DSGame.iconFromHeader(for: url), core: "Cytrus",
                                                          fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                             name: url.lastPathComponent,
                                                                             nameWithoutExtension: nameWithoutExtension,
                                                                             url: url),
                                                          title: try Nintendo3DSGame.titleFromHeader(for: url)))
                            case "ds", "dsi", "nds":
                                $0.append(NintendoDSGame(icon: try NintendoDSGame.iconFromHeader(for: url), core: "Grape",
                                                         fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                            name: url.lastPathComponent,
                                                                            nameWithoutExtension: nameWithoutExtension,
                                                                            url: url),
                                                         title: try NintendoDSGame.titleFromHeader(for: url)))
                            case "n64", "z64":
                                $0.append(Nintendo64Game(core: "Guava",
                                                         fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                            name: url.lastPathComponent,
                                                                            nameWithoutExtension: nameWithoutExtension,
                                                                            url: url),
                                                         title: try Nintendo64Game.titleFromHeader(for: url)))
                            case "cue":
                                $0.append(PlayStation1Game(core: "Lychee",
                                                         fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                            name: url.lastPathComponent,
                                                                            nameWithoutExtension: nameWithoutExtension,
                                                                            url: url),
                                                           title: try PlayStation1Game.titleFromHeader(for: url)))
                            default:
                                break
                            }
                        }
                    }
                default:
                    break
                }
            }
        }
        
        return result
    }
}
