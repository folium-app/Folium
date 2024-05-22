//
//  GrapeManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 15/5/2024.
//

import Foundation
import Grape
import UIKit

class GrapeManager {
    struct Library {
        struct FileDetails : Codable, Hashable {
            let `extension`: String
            let name: String
            let nameWithoutExtension: String
            let url: URL
        }
        
        struct Game : Codable, Comparable, Hashable {
            static func < (lhs: Game, rhs: Game) -> Bool {
                lhs.title < rhs.title
            }
            
            static func == (lhs: Game, rhs: Game) -> Bool {
                lhs.title == rhs.title
            }
            
            let core: Core
            let fileDetails: FileDetails
            let title: String
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
    
    static let shared = GrapeManager()
    
    var library: Library
    init() {
        library = .init(games: [], missingFiles: [])
    }
    
    func menu(_ button: UIButton) -> UIMenu {
        func isCurrentUpscalingOption(_ filter: Int32, _ factor: Int32) -> Bool {
            let currentFilter = Grape.shared.useUpscalingFilter()
            let currentFactor = Grape.shared.useUpscalingFactor()
            
            return filter == currentFilter && factor == currentFactor
        }
        
        return .init(children: [
            UIAction(title: "High Resolution 3D", image: .init(systemName: "scale.3d"), attributes: [.disabled],
                     state: Grape.shared.useHighRes3D() == 1 ? .on : .off, handler: { _ in
                         Grape.shared.setHighRes3D(Grape.shared.useHighRes3D() == 1 ? 0 : 1)
                         
                         button.menu = self.menu(button)
                     }),
            UIMenu(title: "Upscaling Filter", image: .init(systemName: "square.resize.up"), children: [
                UIMenu(title: "HQx", children: [
                    UIAction(title: "2x", state: isCurrentUpscalingOption(0, 2) ? .on : .off, handler: { _ in
                        Grape.shared.setUpscalingFilter(0)
                        Grape.shared.setUpscalingFactor(2)
                        
                        button.menu = self.menu(button)
                    }),
                    UIAction(title: "3x", state: isCurrentUpscalingOption(0, 3) ? .on : .off, handler: { _ in
                        Grape.shared.setUpscalingFilter(0)
                        Grape.shared.setUpscalingFactor(3)
                        
                        button.menu = self.menu(button)
                    }),
                    UIAction(title: "4x", state: isCurrentUpscalingOption(0, 4) ? .on : .off, handler: { _ in
                        Grape.shared.setUpscalingFilter(0)
                        Grape.shared.setUpscalingFactor(4)
                        
                        button.menu = self.menu(button)
                    })
                ]),
                UIMenu(title: "xBRZ", children: [
                    UIAction(title: "2x", state: isCurrentUpscalingOption(1, 2) ? .on : .off, handler: { _ in
                        Grape.shared.setUpscalingFilter(1)
                        Grape.shared.setUpscalingFactor(2)
                        
                        button.menu = self.menu(button)
                    }),
                    UIAction(title: "3x", state: isCurrentUpscalingOption(1, 3) ? .on : .off, handler: { _ in
                        Grape.shared.setUpscalingFilter(1)
                        Grape.shared.setUpscalingFactor(3)
                        
                        button.menu = self.menu(button)
                    }),
                    UIAction(title: "4x", state: isCurrentUpscalingOption(1, 4) ? .on : .off, handler: { _ in
                        Grape.shared.setUpscalingFilter(1)
                        Grape.shared.setUpscalingFactor(4)
                        
                        button.menu = self.menu(button)
                    }),
                    UIAction(title: "5x", state: isCurrentUpscalingOption(1, 5) ? .on : .off, handler: { _ in
                        Grape.shared.setUpscalingFilter(1)
                        Grape.shared.setUpscalingFactor(5)
                        
                        button.menu = self.menu(button)
                    }),
                    UIAction(title: "6x", state: isCurrentUpscalingOption(1, 6) ? .on : .off, handler: { _ in
                        Grape.shared.setUpscalingFilter(1)
                        Grape.shared.setUpscalingFactor(6)
                        
                        button.menu = self.menu(button)
                    })
                ]),
                UIAction(title: "Off", state: isCurrentUpscalingOption(-1, 2) ? .on : .off, handler: { _ in
                    Grape.shared.setUpscalingFilter(-1)
                    Grape.shared.setUpscalingFactor(2)
                    
                    button.menu = self.menu(button)
                })
            ])
        ])
    }
}
