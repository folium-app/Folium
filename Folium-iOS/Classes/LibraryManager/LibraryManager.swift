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
    let skins: [Skin]
    let title: String
    
    init(core: String, fileDetails: FileDetails, skins: [Skin], title: String) {
        self.core = core
        self.fileDetails = fileDetails
        self.skins = skins
        self.title = title
    }
}

enum Feature {
    case gameController,
         speakerOutput,
         microphoneInput,
         cameraInput,
         saveStates,
         loadStates,
         fastForward
}

enum Core : String, Codable, Comparable, CaseIterable, CustomStringConvertible, Hashable, @unchecked Sendable {
    static func < (lhs: Core, rhs: Core) -> Bool { lhs.rawValue < rhs.rawValue }
    
    case cherry = "Cherry" // PS2
    case cytrus = "Cytrus" // 3DS
    case grape = "Grape" // NDS
    case guava = "Guava" // N64
    case kiwi = "Kiwi" // GB/GBC
    case lychee = "Lychee" // PS1
    case mango = "Mango" // SNES
    case peach = "Peach" // NES
    case tomato = "Tomato" // GBA
    
    var color: [Button.`Type` : UIColor] {
        switch self {
        case .cytrus, .grape, .mango:
            [
                .a : .systemRed,
                .b : .systemYellow,
                .x : .systemBlue,
                .y : .systemGreen
            ]
        case .cherry, .lychee:
            [
                .a : .systemOrange,
                .b : .systemBlue,
                .x : .systemGreen,
                .y : .systemPink
            ]
        default:
            [:]
        }
    }
    
    var colors: [Button.`Type` : (UIColor, UIColor)] {
        switch self {
        case .cytrus:
            let isNew3DS = UserDefaults.standard.bool(forKey: "cytrus.new3DS")
            
            return [
                .dpadUp : (.black, .white),
                .dpadDown : (.black, .white),
                .dpadLeft : (.black, .white),
                .dpadRight : (.black, .white),
                .a : isNew3DS ? (.white, .systemRed) : (.black, .white),
                .b : isNew3DS ? (.white, .systemYellow) : (.black, .white),
                .x : isNew3DS ? (.white, .systemBlue) : (.black, .white),
                .y : isNew3DS ? (.white, .systemGreen) : (.black, .white)
            ]
        case .lychee:
            return [
                .a : (.systemOrange, .white),
                .b : (.systemBlue, .white),
                .x : (.systemGreen, .white),
                .y : (.systemPink, .white)
            ]
        default:
            return [
                :
            ]
        }
    }
    
    var console: String {
        switch self {
        case .cherry: "PlayStation 2"
        case .cytrus: "Nintendo 3DS, New Nintendo 3DS"
        case .grape: "Nintendo DS, Nintendo DSi"
        case .guava: "Nintendo 64"
        case .kiwi: "Game Boy, Game Boy Color"
        case .lychee: "PlayStation 1"
        case .mango: "Super Nintendo Entertainment System"
        case .peach: "Nintendo Entertainment System"
        case .tomato: "Game Boy Advance"
        }
    }
    
    var description: String { rawValue }
    
    var isBeta: Bool {
        switch self {
        case .cherry, .lychee, .mango, .tomato:
            true
        default:
            false
        }
    }
    
    var isNintendo: Bool { [.cytrus, .grape, .guava, .kiwi, .mango, .peach, .tomato].contains(self) }
}

struct LibraryManager : @unchecked Sendable {
    static var shared = LibraryManager()
    
    var cores: [Core] {
        [.cytrus, .grape, .lychee, .mango, .peach, .tomato] // 3DS, NDS, PS1, SNES, NES, GBA
    }
    
    var coresWithGames: [Core] = []
    
    mutating func games() throws -> Result<[GameBase], Error> {
        let skinManager = SkinManager.shared
        do {
            try skinManager.getSkins()
        } catch {
            print(#function, error, error.localizedDescription)
        }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var games: [GameBase] = []
        
        for url in Cytrus.shared.installed() {
            if !coresWithGames.contains(.cytrus) {
                coresWithGames.append(.cytrus)
            }
            
            let title = try Nintendo3DSGame.titleFromHeader(for: url)
            if title.isEmpty {
                break
            }
            
            let nameWithoutExtension = url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: "")
            games.append(Nintendo3DSGame(icon: try Nintendo3DSGame.iconFromHeader(for: url), core: "Cytrus",
                                         fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                            name: url.lastPathComponent,
                                                            nameWithoutExtension: nameWithoutExtension,
                                                            url: url),
                                         skins: skinManager.skins(for: .cytrus),
                                         title: title,
                                         titleIdentifier: try Nintendo3DSGame.titleIdentifierFromHeader(for: url)))
        }
        
        for url in Cytrus.shared.system() {
            if !coresWithGames.contains(.cytrus) {
                coresWithGames.append(.cytrus)
            }
            
            let title = try Nintendo3DSGame.titleFromHeader(for: url)
            if title.isEmpty {
                break
            }
            
            let nameWithoutExtension = url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: "")
            games.append(Nintendo3DSGame(icon: try Nintendo3DSGame.iconFromHeader(for: url), core: "Cytrus",
                                         fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                            name: url.lastPathComponent,
                                                            nameWithoutExtension: nameWithoutExtension,
                                                            url: url),
                                         skins: skinManager.skins(for: .cytrus),
                                         title: title,
                                         titleIdentifier: try Nintendo3DSGame.titleIdentifierFromHeader(for: url)))
        }
        
        try cores.forEach { core in
            let romsDirectory = if #available(iOS 16, *) {
                documentsDirectory.appending(component: core.rawValue).appending(component: "roms")
            } else {
                documentsDirectory.appendingPathComponent(core.rawValue).appendingPathComponent("roms")
            }
            
            if let enumerator = FileManager.default.enumerator(at: romsDirectory,
                                                               includingPropertiesForKeys: [.isRegularFileKey],
                                                               options: [.skipsHiddenFiles]) {
                games.append(contentsOf: try enumerator.reduce(into: [GameBase]()) { partialResult, element in
                    switch element {
                    case let url as URL:
                        let attributes = try url.resourceValues(forKeys: [.isRegularFileKey])
                        if let isRegularFile = attributes.isRegularFile, isRegularFile {
                            let nameWithoutExtension = url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: "")
                            switch url.pathExtension.lowercased() {
                            case "cue":
                                let title = try PlayStation1Game.titleFromHeader(for: url)
                                if title.isEmpty {
                                    break
                                }
                                
                                if !coresWithGames.contains(.lychee) {
                                    coresWithGames.append(.lychee)
                                }
                                
                                partialResult.append(PlayStation1Game(icon: try PlayStation1Game.iconFromHeader(for: url),
                                                                      core: "Lychee",
                                                                      fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                                         name: url.lastPathComponent,
                                                                                         nameWithoutExtension: nameWithoutExtension,
                                                                                         url: url),
                                                                      skins: skinManager.skins(for: .lychee),
                                                                      title: title))
                            case "iso":
                                let title = try PlayStation2Game.titleFromHeader(for: url)
                                if title.isEmpty {
                                    break
                                }
                                
                                if !coresWithGames.contains(.cherry) {
                                    coresWithGames.append(.cherry)
                                }
                                
                                partialResult.append(PlayStation2Game(icon: try PlayStation2Game.iconFromHeader(for: url),
                                                                      core: "Cherry",
                                                                      fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                                         name: url.lastPathComponent,
                                                                                         nameWithoutExtension: nameWithoutExtension,
                                                                                         url: url),
                                                                      skins: skinManager.skins(for: .cherry),
                                                                      title: title))
                            case "3ds", "cci", "cxi":
                                let title = try Nintendo3DSGame.titleFromHeader(for: url)
                                if title.isEmpty {
                                    break
                                }
                                
                                if !coresWithGames.contains(.cytrus) {
                                    coresWithGames.append(.cytrus)
                                }
                                
                                partialResult.append(Nintendo3DSGame(icon: try Nintendo3DSGame.iconFromHeader(for: url),
                                                                     core: "Cytrus",
                                                                     fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                                        name: url.lastPathComponent,
                                                                                        nameWithoutExtension: nameWithoutExtension,
                                                                                        url: url),
                                                                     skins: skinManager.skins(for: .cytrus),
                                                                     title: title,
                                                                     titleIdentifier: try Nintendo3DSGame.titleIdentifierFromHeader(for: url)))
                            case "ds", "nds":
                                if !coresWithGames.contains(.grape) {
                                    coresWithGames.append(.grape)
                                }
                                
                                partialResult.append(NintendoDSGame(icon: try NintendoDSGame.iconFromHeader(for: url),
                                                                    core: "Grape",
                                                                    fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                                       name: url.lastPathComponent,
                                                                                       nameWithoutExtension: nameWithoutExtension,
                                                                                       url: url),
                                                                    skins: skinManager.skins(for: .grape),
                                                                    title: try NintendoDSGame.titleFromHeader(for: url)))
                            case "sfc", "smc":
                                if !coresWithGames.contains(.mango) {
                                    coresWithGames.append(.mango)
                                }
                                
                                partialResult.append(SuperNESGame(icon: try SuperNESGame.iconFromHeader(for: url),
                                                                  core: "Mango",
                                                                  fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                                     name: url.lastPathComponent,
                                                                                     nameWithoutExtension: nameWithoutExtension,
                                                                                     url: url),
                                                                  skins: skinManager.skins(for: .mango),
                                                                  title: try SuperNESGame.titleFromHeader(for: url)))
                            case "nes":
                                if !coresWithGames.contains(.peach) {
                                    coresWithGames.append(.peach)
                                }
                                
                                partialResult.append(NintendoEntertainmentSystemGame(core: "Peach",
                                                                                     fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                                                        name: url.lastPathComponent,
                                                                                                        nameWithoutExtension: nameWithoutExtension,
                                                                                                        url: url),
                                                                                     skins: skinManager.skins(for: .peach),
                                                                                     title: try NintendoEntertainmentSystemGame.titleFromHeader(for: url)))
                                
                            case "gba":
                                if !coresWithGames.contains(.tomato) {
                                    coresWithGames.append(.tomato)
                                }
                                
                                partialResult.append(GameBoyAdvanceGame(icon: try GameBoyAdvanceGame.iconFromHeader(for: url),
                                                                        core: "Tomato",
                                                                        fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                                           name: url.lastPathComponent,
                                                                                           nameWithoutExtension: nameWithoutExtension,
                                                                                           url: url),
                                                                        skins: skinManager.skins(for: .tomato),
                                                                        title: try GameBoyAdvanceGame.titleFromHeader(for: url)))
                            default:
                                break
                            }
                        }
                    default:
                        break
                    }
                })
            }
        }
        
        if !UserDefaults.standard.bool(forKey: "folium.showBetaConsoles") {
            coresWithGames.removeAll(where: { $0.isBeta == true })
        }
        
        return .success(games)
        
        
        /*
        enum GamesError : Error {
            case enumeratorFailed
        }
        
        guard let enumerator = FileManager.default.enumerator(at: try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false),
                                                              includingPropertiesForKeys: [.isRegularFileKey]) else {
            return .failure(GamesError.enumeratorFailed)
        }
        
        let result = Result {
            var games: [GameBase] = []
            let skinManager = SkinManager.shared
            do {
                try skinManager.getSkins()
            } catch {}
            
            try Cytrus.shared.installed().forEach { url in
                print("user = ", url.path)
                let nameWithoutExtension = url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: "")
                
                let icon = try Nintendo3DSGame.iconFromHeader(for: url)
                let title = try Nintendo3DSGame.titleFromHeader(for: url)
                
                if !icon.isEmpty, !title.isEmpty {
                    games.append(Nintendo3DSGame(icon: icon,
                                                 core: "Cytrus",
                                                 fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                    name: url.lastPathComponent,
                                                                    nameWithoutExtension: nameWithoutExtension,
                                                                    url: url),
                                                 skins: skinManager.skins(for: .cytrus),
                                                 title: title))
                }
            }
            
            try Cytrus.shared.system().forEach { url in
                print("system = ", url.path)
                let nameWithoutExtension = url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: "")
                
                let icon = try Nintendo3DSGame.iconFromHeader(for: url)
                let title = try Nintendo3DSGame.titleFromHeader(for: url)
                
                if !icon.isEmpty, !title.isEmpty {
                    games.append(Nintendo3DSGame(icon: icon,
                                                 core: "Cytrus",
                                                 fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                    name: url.lastPathComponent,
                                                                    nameWithoutExtension: nameWithoutExtension,
                                                                    url: url),
                                                 skins: skinManager.skins(for: .cytrus),
                                                 title: title))
                }
            }
            
            cores.forEach { core in
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let coreDirectory = documentsDirectory.appending(component: core.rawValue)
                
                
            }
            
            
            games.append(contentsOf: try enumerator.reduce(into: [GameBase]()) {
                switch $1 {
                case let url as URL:
                    let attributes = try url.resourceValues(forKeys: [.isRegularFileKey])
                    if let isRegularFile = attributes.isRegularFile, isRegularFile {
                        let extensions: [String] = ["gb", "gba", "gbc", "3ds", "cci", "cxi", "ds", "nds", "n64", "z64", "bin", "cue", "sfc", "smc"]
                        if extensions.contains(url.pathExtension.lowercased()) {
                            print("\(#function): success: \(url.lastPathComponent)")
                            
                            let nameWithoutExtension = url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: "")
                            switch url.pathExtension.lowercased() {
                            case "gb", "gbc":
                                $0.append(GameBoyGame(core: "Kiwi",
                                                      fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                         name: url.lastPathComponent,
                                                                         nameWithoutExtension: nameWithoutExtension,
                                                                         url: url),
                                                      skins: skinManager.skins(for: .kiwi),
                                                      title: try GameBoyGame.titleFromHeader(for: url)))
                            case "gba":
                                $0.append(GameBoyAdvanceGame(core: "Tomato",
                                                             fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                                name: url.lastPathComponent,
                                                                                nameWithoutExtension: nameWithoutExtension,
                                                                                url: url),
                                                             skins: skinManager.skins(for: .tomato),
                                                             title: try GameBoyAdvanceGame.titleFromHeader(for: url)))
                            case "3ds", "cci", "cxi":
                                $0.append(Nintendo3DSGame(icon: try Nintendo3DSGame.iconFromHeader(for: url), core: "Cytrus",
                                                          fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                             name: url.lastPathComponent,
                                                                             nameWithoutExtension: nameWithoutExtension,
                                                                             url: url),
                                                          skins: skinManager.skins(for: .cytrus),
                                                          title: try Nintendo3DSGame.titleFromHeader(for: url)))
                            case "ds", "nds":
                                $0.append(NintendoDSGame(icon: try NintendoDSGame.iconFromHeader(for: url), core: "Grape",
                                                         fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                            name: url.lastPathComponent,
                                                                            nameWithoutExtension: nameWithoutExtension,
                                                                            url: url),
                                                         skins: skinManager.skins(for: .grape),
                                                         title: try NintendoDSGame.titleFromHeader(for: url)))
                            case "n64", "z64":
                                $0.append(Nintendo64Game(core: "Guava",
                                                         fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                            name: url.lastPathComponent,
                                                                            nameWithoutExtension: nameWithoutExtension,
                                                                            url: url),
                                                         skins: skinManager.skins(for: .guava),
                                                         title: try Nintendo64Game.titleFromHeader(for: url)))
                            case "bin", "cue":
                                $0.append(PlayStation1Game(core: "Lychee",
                                                           fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                              name: url.lastPathComponent,
                                                                              nameWithoutExtension: nameWithoutExtension,
                                                                              url: url),
                                                           skins: skinManager.skins(for: .lychee),
                                                           title: try PlayStation1Game.titleFromHeader(for: url)))
                            case "sfc", "smc":
                                $0.append(SuperNESGame(core: "Mango",
                                                       fileDetails: .init(extension: url.pathExtension.lowercased(),
                                                                          name: url.lastPathComponent,
                                                                          nameWithoutExtension: nameWithoutExtension,
                                                                          url: url),
                                                       skins: skinManager.skins(for: .mango),
                                                       title: try SuperNESGame.titleFromHeader(for: url)))
                            default:
                                break
                            }
                        }
                    }
                default:
                    break
                }
            })
            
            return games
        }
        
        return result
         */
    }
}
