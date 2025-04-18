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
    var cheats: [Cheat] = []
    var saves: [SaveStateInfo] = []
    
    fileprivate var cytrus: Cytrus = .shared
    var cheatsManager: CheatsManager
    
    init(for url: URL, core: String, fileDetails: GameBase.FileDetails, skins: [Skin]) {
        self.icon = cytrus.information(url).icon
        self.identifier = cytrus.information(url).identifier
        self.coreVersion = cytrus.information(url).coreVersion
        self.kernelMemoryMode = cytrus.information(url).kernelMemoryMode
        self.new3DSKernelMemoryMode = cytrus.information(url).new3DSKernelMemoryMode
        self.publisher = cytrus.information(url).publisher
        self.regions = cytrus.information(url).regions
        self.saves = cytrus.saves(for: identifier ?? 0)
        
        self.cheatsManager = .init(identifier: identifier ?? 0)
        self.cheatsManager.loadCheats()
        self.cheats = cheatsManager.getCheats()
        
        super.init(core: core, fileDetails: fileDetails, skins: skins, title: cytrus.information(url).title)
    }
    
    func update() {
        cheatsManager.loadCheats()
        cheats = cheatsManager.getCheats()
        saves = cytrus.saves(for: identifier ?? 0)
    }
}
