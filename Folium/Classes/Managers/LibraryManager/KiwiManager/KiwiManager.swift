//
//  KiwiManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 15/5/2024.
//

import Foundation
import Kiwi
import UIKit

class KiwiManager {
    struct Library {
        struct FileDetails : Codable, Hashable {
            let `extension`: String
            let name: String
            let nameWithoutExtension: String
            let url: URL
        }
        
        class Game : AnyHashableSendable, @unchecked Sendable {
            static func < (lhs: Game, rhs: Game) -> Bool {
                lhs.title < rhs.title
            }
            
            static func == (lhs: Game, rhs: Game) -> Bool {
                lhs.title == rhs.title
            }
            
            let core: Core
            let fileDetails: FileDetails
            let title: String
            
            init(core: Core, fileDetails: FileDetails, title: String) {
                self.core = core
                self.fileDetails = fileDetails
                self.title = title
            }
        }
        
        var games: [Game]
        var missingFiles: [MissingFile]
        
        mutating func add(_ game: Game) {
            games.append(game)
            games.sort(by: <)
        }
        
        mutating func add(_ missingFile: MissingFile) {
            missingFiles.append(missingFile)
            missingFiles.sort(by: <)
        }
    }
    
    static let shared = KiwiManager()
    
    var library: Library
    init() {
        library = .init(games: [], missingFiles: [])
    }
    
    func menu(_ button: UIButton) -> UIMenu {
        func isCurrentUpscalingOption(_ filter: Int32, _ factor: Int32) -> Bool {
            let currentFilter = Kiwi.shared.useUpscalingFilter()
            let currentFactor = Kiwi.shared.useUpscalingFactor()
            
            return filter == currentFilter && factor == currentFactor
        }
        
        return .init(children: [
            UIMenu(title: "Upscaling Filter", image: .init(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"), children: [
                UIMenu(title: "HQx", children: [
                    UIAction(title: "2x", state: isCurrentUpscalingOption(0, 2) ? .on : .off, handler: { _ in
                        Kiwi.shared.setUpscalingFilter(0)
                        Kiwi.shared.setUpscalingFactor(2)
                        
                        button.menu = self.menu(button)
                    }),
                    UIAction(title: "3x", state: isCurrentUpscalingOption(0, 3) ? .on : .off, handler: { _ in
                        Kiwi.shared.setUpscalingFilter(0)
                        Kiwi.shared.setUpscalingFactor(3)
                        
                        button.menu = self.menu(button)
                    }),
                    UIAction(title: "4x", state: isCurrentUpscalingOption(0, 4) ? .on : .off, handler: { _ in
                        Kiwi.shared.setUpscalingFilter(0)
                        Kiwi.shared.setUpscalingFactor(4)
                        
                        button.menu = self.menu(button)
                    })
                ]),
                UIMenu(title: "xBRZ", children: [
                    UIAction(title: "2x", state: isCurrentUpscalingOption(1, 2) ? .on : .off, handler: { _ in
                        Kiwi.shared.setUpscalingFilter(1)
                        Kiwi.shared.setUpscalingFactor(2)
                        
                        button.menu = self.menu(button)
                    }),
                    UIAction(title: "3x", state: isCurrentUpscalingOption(1, 3) ? .on : .off, handler: { _ in
                        Kiwi.shared.setUpscalingFilter(1)
                        Kiwi.shared.setUpscalingFactor(3)
                        
                        button.menu = self.menu(button)
                    }),
                    UIAction(title: "4x", state: isCurrentUpscalingOption(1, 4) ? .on : .off, handler: { _ in
                        Kiwi.shared.setUpscalingFilter(1)
                        Kiwi.shared.setUpscalingFactor(4)
                        
                        button.menu = self.menu(button)
                    }),
                    UIAction(title: "5x", state: isCurrentUpscalingOption(1, 5) ? .on : .off, handler: { _ in
                        Kiwi.shared.setUpscalingFilter(1)
                        Kiwi.shared.setUpscalingFactor(5)
                        
                        button.menu = self.menu(button)
                    }),
                    UIAction(title: "6x", state: isCurrentUpscalingOption(1, 6) ? .on : .off, handler: { _ in
                        Kiwi.shared.setUpscalingFilter(1)
                        Kiwi.shared.setUpscalingFactor(6)
                        
                        button.menu = self.menu(button)
                    })
                ]),
                UIAction(title: "Off", state: isCurrentUpscalingOption(-1, 2) ? .on : .off, handler: { _ in
                    Kiwi.shared.setUpscalingFilter(-1)
                    Kiwi.shared.setUpscalingFactor(2)
                    
                    button.menu = self.menu(button)
                })
            ])
        ])
    }
}
