//
//  CytrusGame.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 2/3/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Cytrus
import Foundation

class CytrusGame : GameBase, @unchecked Sendable {
    var icon: Data? = nil
    var identifier: UInt64? = nil
    var coreVersion: CoreVersion? = nil
    var kernelMemoryMode: KernelMemoryMode? = nil
    var new3DSKernelMemoryMode: New3DSKernelMemoryMode? = nil
    var publisher: String? = nil
    var regions: String? = nil
    var cheats: [Cheat]
    var saves: [SaveStateInfo]
    
    static fileprivate let cytrus = Cytrus.shared
    
    init(icon: Data? = nil, identifier: UInt64? = nil, coreVersion: CoreVersion? = nil, kernelMemoryMode: KernelMemoryMode? = nil, new3DSKernelMemoryMode: New3DSKernelMemoryMode? = nil, publisher: String? = nil, regions: String? = nil, cheats: [Cheat], saves: [SaveStateInfo], core: String, fileDetails: GameBase.FileDetails, skins: [Skin], title: String) {
        self.icon = icon
        self.identifier = identifier
        self.coreVersion = coreVersion
        self.kernelMemoryMode = kernelMemoryMode
        self.new3DSKernelMemoryMode = new3DSKernelMemoryMode
        self.publisher = publisher
        self.regions = regions
        self.cheats = cheats
        self.saves = saves
        super.init(core: core, fileDetails: fileDetails, skins: skins, title: title)
    }
    
    init(for url: URL, core: String, fileDetails: GameBase.FileDetails, skins: [Skin], title: String) {
        self.icon = Self.icon(for: url)
        self.identifier = Self.identifier(for: url)
        self.coreVersion = Self.coreVersion(for: url)
        self.kernelMemoryMode = Self.kernelMemoryMode(for: url)
        self.new3DSKernelMemoryMode = Self.new3DSKernelMemoryMode(for: url)
        self.publisher = Self.publisher(for: url)
        self.regions = Self.regions(for: url)
        self.cheats = Self.cheats(for: Self.identifier(for: url))
        self.saves = Self.saves(for: Self.identifier(for: url))
        super.init(core: core, fileDetails: fileDetails, skins: skins, title: title)
    }
    
    static func icon(for url: URL) -> Data? { cytrus.information(for: url).icon }
    static func identifier(for url: URL) -> UInt64 { cytrus.information(for: url).identifier }
    static func coreVersion(for url: URL) -> CoreVersion { cytrus.information(for: url).coreVersion }
    static func kernelMemoryMode(for url: URL) -> KernelMemoryMode { cytrus.information(for: url).kernelMemoryMode }
    static func new3DSKernelMemoryMode(for url: URL) -> New3DSKernelMemoryMode { cytrus.information(for: url).new3DSKernelMemoryMode }
    static func publisher(for url: URL) -> String { cytrus.information(for: url).publisher }
    static func regions(for url: URL) -> String { cytrus.information(for: url).regions }
    static func title(for url: URL) -> String { cytrus.information(for: url).title }
    static func cheats(for identifier: UInt64) -> [Cheat] {
        CheatsManager().loadCheats(identifier)
        return CheatsManager().getCheats()
    }
    static func saves(for identifier: UInt64) -> [SaveStateInfo] { cytrus.saves(for: identifier) }
    
    func update() {
        cheats = CytrusGame.cheats(for: CytrusGame.identifier(for: fileDetails.url))
        saves = CytrusGame.saves(for: CytrusGame.identifier(for: fileDetails.url))
    }
}
