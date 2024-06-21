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
        
        class Game : AnyHashableSendable, @unchecked Sendable {
            static func < (lhs: Game, rhs: Game) -> Bool {
                lhs.title < rhs.title
            }
            
            static func == (lhs: Game, rhs: Game) -> Bool {
                lhs.title == rhs.title
            }
            
            enum GameType : Int, Codable, Hashable {
                case gba, nds
            }
            
            let core: Core
            let fileDetails: FileDetails
            let title: String
            
            var gameType: GameType {
                fileDetails.extension == "gba" ? .gba : .nds
            }
            
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
    
    static let shared = GrapeManager()
    let skinsManager = SkinManager()
    
    var library: Library
    init() {
        library = .init(games: [], missingFiles: [])
    }
    
    func defaultSkin() -> Skin {
        let bounds = UIScreen.main.bounds
        let width = bounds.width
        let height = bounds.height
        
        func iPadScreens() -> [Screen] {
            let iPadWidth = (width / 2) + (width / 4)
            let portraitHeight = iPadWidth / 1.33
            
            let bottomTopInset = (height / 2) + 10
            return [
                .init(x: (width / 2) - (iPadWidth / 2), y: (height / 2) - (portraitHeight + 10), width: iPadWidth, height: portraitHeight),
                .init(x: (width / 2) - (iPadWidth / 2), y: bottomTopInset, width: iPadWidth, height: portraitHeight)
            ]
        }
        
        func iPhoneScreens() -> [Screen] {
            let portraitHeight = width / 1.33
            
            return [
                .init(x: 10, y: safeAreaInsets.top + 10, width: width - 20, height: portraitHeight - 20),
                .init(x: 10, y: (safeAreaInsets.top + 10) + portraitHeight, width: width - 20, height: portraitHeight - 20)
            ]
        }
        
        
        
        let safeAreaInsets = UIApplication.shared.windows[0].safeAreaInsets
        
        let homeButtonX = (width / 2) - 15
        
        let buttons: [Button] = [
            .init(x: width-80, y: height-(120+safeAreaInsets.bottom), width: 60, height: 60, type: .a),
            .init(x: width-140, y: height-(60+safeAreaInsets.bottom), width: 60, height: 60, type: .b),
            .init(x: width-140, y: height-(180+safeAreaInsets.bottom), width: 60, height: 60, type: .x),
            .init(x: width-200, y: height-(120+safeAreaInsets.bottom), width: 60, height: 60, type: .y),
            
            .init(x: 80, y: height-(180+safeAreaInsets.bottom), width: 60, height: 60, type: .dpadUp),
            .init(x: 80, y: height-(60+safeAreaInsets.bottom), width: 60, height: 60, type: .dpadDown),
            .init(x: 20, y: height-(120+safeAreaInsets.bottom), width: 60, height: 60, type: .dpadLeft),
            .init(x: 140, y: height-(120+safeAreaInsets.bottom), width: 60, height: 60, type: .dpadRight),
            
            .init(x: 20, y: height-(240+safeAreaInsets.bottom), width: 70, height: 50, type: .l),
            .init(x: width-90, y: height-(240+safeAreaInsets.bottom), width: 70, height: 50, type: .r),
            
            .init(x: homeButtonX-45, y: height-(20+safeAreaInsets.bottom), width: 30, height: 30, type: .minus),
            .init(x: homeButtonX+45, y: height-(20+safeAreaInsets.bottom), width: 30, height: 30, type: .plus)
        ]
        
        let screens: [Screen] = if UIDevice.current.userInterfaceIdiom == .pad {
            iPadScreens()
        } else {
            iPhoneScreens()
        }
        
        let devices: [Device] = [
            .init(device: machine, orientation: .portrait, buttons: buttons, screens: screens, thumbsticks: [])
        ]
        
        return Skin(author: "Antique", description: "Default skin for the Nintendo DS", name: "Grape Skin", core: .grape, devices: devices)
    }
    
    func menu(_ button: UIButton) -> UIMenu {
        func isCurrentUpscalingOption(_ filter: Int32, _ factor: Int32) -> Bool {
            let currentFilter = Grape.shared.useUpscalingFilter()
            let currentFactor = Grape.shared.useUpscalingFactor()
            
            return filter == currentFilter && factor == currentFactor
        }
        
        return .init(children: [
            UIAction(title: "Direct Boot", image: .init(systemName: "power"),
                     state: Grape.shared.useDirectBoot() == 1 ? .on : .off, handler: { _ in
                         Grape.shared.setDirectBoot(Grape.shared.useDirectBoot() == 1 ? 0 : 1)
                         
                         button.menu = self.menu(button)
                     }),
            UIAction(title: "High Resolution 3D", image: .init(systemName: "scale.3d"), attributes: [.disabled],
                     state: Grape.shared.useHighRes3D() == 1 ? .on : .off, handler: { _ in
                         Grape.shared.setHighRes3D(Grape.shared.useHighRes3D() == 1 ? 0 : 1)
                         
                         button.menu = self.menu(button)
                     }),
            UIMenu(title: "Upscaling Filter", image: .init(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"), children: [
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
                    UIMenu(title: "Nearest Neighbor", children: [
                        UIAction(title: "2x", state: isCurrentUpscalingOption(2, 2) ? .on : .off, handler: { _ in
                            Grape.shared.setUpscalingFilter(2)
                            Grape.shared.setUpscalingFactor(2)
                            
                            button.menu = self.menu(button)
                        }),
                        UIAction(title: "3x", state: isCurrentUpscalingOption(2, 3) ? .on : .off, handler: { _ in
                            Grape.shared.setUpscalingFilter(2)
                            Grape.shared.setUpscalingFactor(3)
                            
                            button.menu = self.menu(button)
                        }),
                        UIAction(title: "4x", state: isCurrentUpscalingOption(2, 4) ? .on : .off, handler: { _ in
                            Grape.shared.setUpscalingFilter(2)
                            Grape.shared.setUpscalingFactor(4)
                            
                            button.menu = self.menu(button)
                        }),
                        UIAction(title: "5x", state: isCurrentUpscalingOption(2, 5) ? .on : .off, handler: { _ in
                            Grape.shared.setUpscalingFilter(2)
                            Grape.shared.setUpscalingFactor(5)
                            
                            button.menu = self.menu(button)
                        }),
                        UIAction(title: "6x", state: isCurrentUpscalingOption(2, 6) ? .on : .off, handler: { _ in
                            Grape.shared.setUpscalingFilter(2)
                            Grape.shared.setUpscalingFactor(6)
                            
                            button.menu = self.menu(button)
                        })
                    ]),
                    UIMenu(title: "Scale", children: [
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
                    ])
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
