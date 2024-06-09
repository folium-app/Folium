//
//  CytrusManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 15/5/2024.
//

import Cytrus
import Foundation
import UIKit

class CytrusManager {
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
    
    static let shared = CytrusManager()
    
    var library: Library
    init() {
        library = .init(games: [], missingFiles: [])
    }
    
    func menu(_ button: UIButton, _ viewController: UIViewController, _ isInGame: Bool = false) -> UIMenu {
        let resetSettingsSystemName = if #available(iOS 16, *) { "gearshape.arrow.triangle.2.circlepath" } else { "arrow.triangle.2.circlepath" }
        
        var children = [
            UIMenu(title: "Core", image: .init(systemName: "cpu"), children: [
                UIAction(title: "CPU Clock (\(CytrusSettings.Settings.cpuClockPercentage)%)", handler: { action in
                    let alertController = UIAlertController(title: "CPU Clock", message: "5% - 400%", preferredStyle: .alert)
                    alertController.addTextField { textField in
                        textField.keyboardType = .numberPad
                    }
                    alertController.addAction(.init(title: "Cancel", style: .cancel))
                    alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                        guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text, let intValue = Int(value) else {
                            return
                        }
                        
                        CytrusSettings.Settings.shared.set(intValue, for: .cpuClockPercentage)
                        button.menu = self.menu(button, viewController, isInGame)
                    }))
                    viewController.present(alertController, animated: true)
                }),
                UIAction(title: "Use New 3DS", state: CytrusSettings.Settings.useNew3DS ? .on : .off, handler: { action in
                    CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useNew3DS, for: .useNew3DS)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIAction(title: "Use LLE Applets", state: CytrusSettings.Settings.useLLEApplets ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useLLEApplets, for: .useLLEApplets)
                    button.menu = self.menu(button, viewController, isInGame)
                })
            ]),
            UIMenu(title: "Region", image: .init(systemName: "globe.asia.australia"), children: [
                UIAction(title: "Auto", state: CytrusSettings.Settings.regionSelect == -1 ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(-1, for: .regionSelect)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIAction(title: "Japan", state: CytrusSettings.Settings.regionSelect == 0 ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(0, for: .regionSelect)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIAction(title: "United States of America", state: CytrusSettings.Settings.regionSelect == 1 ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(1, for: .regionSelect)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIAction(title: "Europe", state: CytrusSettings.Settings.regionSelect == 2 ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(2, for: .regionSelect)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIAction(title: "Australia", state: CytrusSettings.Settings.regionSelect == 3 ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(3, for: .regionSelect)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIAction(title: "China", state: CytrusSettings.Settings.regionSelect == 4 ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(4, for: .regionSelect)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIAction(title: "Korea", state: CytrusSettings.Settings.regionSelect == 5 ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(5, for: .regionSelect)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIAction(title: "Taiwan", state: CytrusSettings.Settings.regionSelect == 6 ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(6, for: .regionSelect)
                    button.menu = self.menu(button, viewController, isInGame)
                })
            ]),
            UIMenu(title: "Renderer", image: .init(systemName: "video"), children: [
                UIMenu(title: "Shaders", children: [
                    UIAction(title: "SPIRV Shader Generation", state: CytrusSettings.Settings.useSpirvShaderGeneration ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useSpirvShaderGeneration, for: .useSpirvShaderGeneration)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Async Shader Compilation", state: CytrusSettings.Settings.useAsyncShaderCompilation ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useAsyncShaderCompilation, for: .useAsyncShaderCompilation)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Use Hardware Shaders", state: CytrusSettings.Settings.useHardwareShaders ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useHardwareShaders, for: .useHardwareShaders)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Accurate Shader Mul", state: CytrusSettings.Settings.useShadersAccurateMul ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useShadersAccurateMul, for: .useShadersAccurateMul)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Use Shader JIT", state: CytrusSettings.Settings.useShaderJIT ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useShaderJIT, for: .useShaderJIT)
                        button.menu = self.menu(button, viewController, isInGame)
                    })
                ]),
                UIAction(title: "Async Presentation", state: CytrusSettings.Settings.useAsyncPresentation ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useAsyncPresentation, for: .useAsyncPresentation)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIAction(title: "Use New VSync", state: CytrusSettings.Settings.useNewVSync ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useNewVSync, for: .useNewVSync)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIAction(title: "Resolution Factor (\(CytrusSettings.Settings.resolutionFactor))", handler: { action in
                    let alertController = UIAlertController(title: "Resolution Factor", message: "0 - 10", preferredStyle: .alert)
                    alertController.addTextField { textField in
                        textField.keyboardType = .numberPad
                    }
                    alertController.addAction(.init(title: "Cancel", style: .cancel))
                    alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                        guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text, let intValue = Int(value) else {
                            return
                        }
                        
                        CytrusSettings.Settings.shared.set(intValue, for: .resolutionFactor)
                        button.menu = self.menu(button, viewController, isInGame)
                    }))
                    viewController.present(alertController, animated: true)
                }),
                UIMenu(title: "Textures", children: [
                    UIMenu(title: "Texture Filter", children: [
                        UIAction(title: "None", state: CytrusSettings.Settings.textureFilter == 0 ? .on : .off, handler: { _ in
                            CytrusSettings.Settings.shared.set(0, for: .textureFilter)
                            button.menu = self.menu(button, viewController, isInGame)
                        }),
                        UIAction(title: "Anime4K", state: CytrusSettings.Settings.textureFilter == 1 ? .on : .off, handler: { _ in
                            CytrusSettings.Settings.shared.set(1, for: .textureFilter)
                            button.menu = self.menu(button, viewController, isInGame)
                        }),
                        UIAction(title: "Bicubic", state: CytrusSettings.Settings.textureFilter == 2 ? .on : .off, handler: { _ in
                            CytrusSettings.Settings.shared.set(2, for: .textureFilter)
                            button.menu = self.menu(button, viewController, isInGame)
                        }),
                        UIAction(title: "ScaleForce", state: CytrusSettings.Settings.textureFilter == 3 ? .on : .off, handler: { _ in
                            CytrusSettings.Settings.shared.set(3, for: .textureFilter)
                            button.menu = self.menu(button, viewController, isInGame)
                        }),
                        UIAction(title: "xBRZ", state: CytrusSettings.Settings.textureFilter == 4 ? .on : .off, handler: { _ in
                            CytrusSettings.Settings.shared.set(4, for: .textureFilter)
                            button.menu = self.menu(button, viewController, isInGame)
                        }),
                        UIAction(title: "MMPX", state: CytrusSettings.Settings.textureFilter == 5 ? .on : .off, handler: { _ in
                            CytrusSettings.Settings.shared.set(5, for: .textureFilter)
                            button.menu = self.menu(button, viewController, isInGame)
                        })
                    ]),
                    UIMenu(title: "Texture Sampling", children: [
                        UIAction(title: "Game Controlled", state: CytrusSettings.Settings.textureSampling == 0 ? .on : .off, handler: { _ in
                            CytrusSettings.Settings.shared.set(0, for: .textureSampling)
                            button.menu = self.menu(button, viewController, isInGame)
                        }),
                        UIAction(title: "Nearest Neighbor", state: CytrusSettings.Settings.textureSampling == 1 ? .on : .off, handler: { _ in
                            CytrusSettings.Settings.shared.set(1, for: .textureSampling)
                            button.menu = self.menu(button, viewController, isInGame)
                        }),
                        UIAction(title: "Linear", state: CytrusSettings.Settings.textureSampling == 2 ? .on : .off, handler: { _ in
                            CytrusSettings.Settings.shared.set(2, for: .textureSampling)
                            button.menu = self.menu(button, viewController, isInGame)
                        })
                    ]),
                    UIAction(title: "Use Custom Textures", state: CytrusSettings.Settings.useCustomTextures ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useCustomTextures, for: .useCustomTextures)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Preload Textures", state: CytrusSettings.Settings.preloadTextures ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.preloadTextures, for: .preloadTextures)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Async Custom Loading", state: CytrusSettings.Settings.asyncCustomLoading ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.asyncCustomLoading, for: .asyncCustomLoading)
                        button.menu = self.menu(button, viewController, isInGame)
                    })
                ]),
                UIMenu(title: "Layout", children: [
                    UIMenu(title: "Layout Option", children: [
                        UIAction(title: "Default", state: CytrusSettings.Settings.layoutOption == 0 ? .on : .off, handler: { _ in
                            CytrusSettings.Settings.shared.set(0, for: .layoutOption)
                            button.menu = self.menu(button, viewController, isInGame)
                        }),
                        UIAction(title: "Single Screen", state: CytrusSettings.Settings.layoutOption == 1 ? .on : .off, handler: { _ in
                            CytrusSettings.Settings.shared.set(1, for: .layoutOption)
                            button.menu = self.menu(button, viewController, isInGame)
                        }),
                        UIAction(title: "Large Screen", state: CytrusSettings.Settings.layoutOption == 2 ? .on : .off, handler: { _ in
                            CytrusSettings.Settings.shared.set(2, for: .layoutOption)
                            button.menu = self.menu(button, viewController, isInGame)
                        }),
                        UIAction(title: "Side Screen", state: CytrusSettings.Settings.layoutOption == 3 ? .on : .off, handler: { _ in
                            CytrusSettings.Settings.shared.set(3, for: .layoutOption)
                            button.menu = self.menu(button, viewController, isInGame)
                        }),
                        UIAction(title: "Hybrid Screen", state: CytrusSettings.Settings.layoutOption == 5 ? .on : .off, handler: { _ in
                            CytrusSettings.Settings.shared.set(5, for: .layoutOption)
                            button.menu = self.menu(button, viewController, isInGame)
                        }),
                        UIAction(title: "Mobile Portrait", state: CytrusSettings.Settings.layoutOption == 6 ? .on : .off, handler: { _ in
                            CytrusSettings.Settings.shared.set(6, for: .layoutOption)
                            button.menu = self.menu(button, viewController, isInGame)
                        }),
                        UIAction(title: "Mobile Landscape", state: CytrusSettings.Settings.layoutOption == 7 ? .on : .off, handler: { _ in
                            CytrusSettings.Settings.shared.set(7, for: .layoutOption)
                            button.menu = self.menu(button, viewController, isInGame)
                        })
                    ]),
                    UIMenu(title: "Custom Layout", children: [
                        UIAction(title: "Use Custom Layout", state: CytrusSettings.Settings.useCustomLayout ? .on : .off, handler: { _ in
                            CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useCustomLayout, for: .useCustomLayout)
                            button.menu = self.menu(button, viewController, isInGame)
                        }),
                        UIMenu(title: "Layout Settings", children: [
                            UIAction(title: "Top Left (\(CytrusSettings.Settings.customLayoutTopLeft))", handler: { action in
                                let alertController = UIAlertController(title: "Custom Layout", message: action.title, preferredStyle: .alert)
                                alertController.addTextField { textField in
                                    textField.keyboardType = .numberPad
                                }
                                alertController.addAction(.init(title: "Cancel", style: .cancel))
                                alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                                    guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text, let intValue = Int(value) else {
                                        return
                                    }
                                    
                                    CytrusSettings.Settings.shared.set(intValue, for: .customLayoutTopLeft)
                                    button.menu = self.menu(button, viewController, isInGame)
                                }))
                                viewController.present(alertController, animated: true)
                            }),
                            UIAction(title: "Top Top (\(CytrusSettings.Settings.customLayoutTopTop))", handler: { action in
                                let alertController = UIAlertController(title: "Custom Layout", message: action.title, preferredStyle: .alert)
                                alertController.addTextField { textField in
                                    textField.keyboardType = .numberPad
                                }
                                alertController.addAction(.init(title: "Cancel", style: .cancel))
                                alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                                    guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text, let intValue = Int(value) else {
                                        return
                                    }
                                    
                                    CytrusSettings.Settings.shared.set(intValue, for: .customLayoutTopTop)
                                    button.menu = self.menu(button, viewController, isInGame)
                                }))
                                viewController.present(alertController, animated: true)
                            }),
                            UIAction(title: "Top Right (\(CytrusSettings.Settings.customLayoutTopRight))", handler: { action in
                                let alertController = UIAlertController(title: "Custom Layout", message: action.title, preferredStyle: .alert)
                                alertController.addTextField { textField in
                                    textField.keyboardType = .numberPad
                                }
                                alertController.addAction(.init(title: "Cancel", style: .cancel))
                                alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                                    guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text, let intValue = Int(value) else {
                                        return
                                    }
                                    
                                    CytrusSettings.Settings.shared.set(intValue, for: .customLayoutTopRight)
                                    button.menu = self.menu(button, viewController, isInGame)
                                }))
                                viewController.present(alertController, animated: true)
                            }),
                            UIAction(title: "Top Bottom (\(CytrusSettings.Settings.customLayoutTopBottom))", handler: { action in
                                let alertController = UIAlertController(title: "Custom Layout", message: action.title, preferredStyle: .alert)
                                alertController.addTextField { textField in
                                    textField.keyboardType = .numberPad
                                }
                                alertController.addAction(.init(title: "Cancel", style: .cancel))
                                alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                                    guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text, let intValue = Int(value) else {
                                        return
                                    }
                                    
                                    CytrusSettings.Settings.shared.set(intValue, for: .customLayoutTopBottom)
                                    button.menu = self.menu(button, viewController, isInGame)
                                }))
                                viewController.present(alertController, animated: true)
                            }),
                            UIAction(title: "Bottom Left (\(CytrusSettings.Settings.customLayoutBottomLeft))", handler: { action in
                                let alertController = UIAlertController(title: "Custom Layout", message: action.title, preferredStyle: .alert)
                                alertController.addTextField { textField in
                                    textField.keyboardType = .numberPad
                                }
                                alertController.addAction(.init(title: "Cancel", style: .cancel))
                                alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                                    guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text, let intValue = Int(value) else {
                                        return
                                    }
                                    
                                    CytrusSettings.Settings.shared.set(intValue, for: .customLayoutBottomLeft)
                                    button.menu = self.menu(button, viewController, isInGame)
                                }))
                                viewController.present(alertController, animated: true)
                            }),
                            UIAction(title: "Bottom Top (\(CytrusSettings.Settings.customLayoutBottomTop))", handler: { action in
                                let alertController = UIAlertController(title: "Custom Layout", message: action.title, preferredStyle: .alert)
                                alertController.addTextField { textField in
                                    textField.keyboardType = .numberPad
                                }
                                alertController.addAction(.init(title: "Cancel", style: .cancel))
                                alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                                    guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text, let intValue = Int(value) else {
                                        return
                                    }
                                    
                                    CytrusSettings.Settings.shared.set(intValue, for: .customLayoutBottomTop)
                                    button.menu = self.menu(button, viewController, isInGame)
                                }))
                                viewController.present(alertController, animated: true)
                            }),
                            UIAction(title: "Bottom Right (\(CytrusSettings.Settings.customLayoutBottomRight))", handler: { action in
                                let alertController = UIAlertController(title: "Custom Layout", message: action.title, preferredStyle: .alert)
                                alertController.addTextField { textField in
                                    textField.keyboardType = .numberPad
                                }
                                alertController.addAction(.init(title: "Cancel", style: .cancel))
                                alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                                    guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text, let intValue = Int(value) else {
                                        return
                                    }
                                    
                                    CytrusSettings.Settings.shared.set(intValue, for: .customLayoutBottomRight)
                                    button.menu = self.menu(button, viewController, isInGame)
                                }))
                                viewController.present(alertController, animated: true)
                            }),
                            UIAction(title: "Bottom Bottom (\(CytrusSettings.Settings.customLayoutBottomBottom))", handler: { action in
                                let alertController = UIAlertController(title: "Custom Layout", message: action.title, preferredStyle: .alert)
                                alertController.addTextField { textField in
                                    textField.keyboardType = .numberPad
                                }
                                alertController.addAction(.init(title: "Cancel", style: .cancel))
                                alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                                    guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text, let intValue = Int(value) else {
                                        return
                                    }
                                    
                                    CytrusSettings.Settings.shared.set(intValue, for: .customLayoutBottomBottom)
                                    button.menu = self.menu(button, viewController, isInGame)
                                }))
                                viewController.present(alertController, animated: true)
                            })
                        ])
                    ])
                ])
            ]),
            UIMenu(title: "Audio", image: .init(systemName: "speaker.wave.3.fill"), children: [
                UIMenu(title: "Audio Emulation", children: [
                    UIAction(title: "HLE", state: CytrusSettings.Settings.audioEmulation == 0 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(0, for: .audioEmulation)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "LLE", state: CytrusSettings.Settings.audioEmulation == 1 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(1, for: .audioEmulation)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "LLE Multithreaded", state: CytrusSettings.Settings.audioEmulation == 2 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(2, for: .audioEmulation)
                        button.menu = self.menu(button, viewController, isInGame)
                    })
                ]),
                UIAction(title: "Use Audio Stretching", state: CytrusSettings.Settings.audioStretching ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.audioStretching, for: .audioStretching)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIMenu(title: "Output Device", children: [
                    UIAction(title: "Auto", state: CytrusSettings.Settings.audioOutputDevice == 0 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(0, for: .audioOutputDevice)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "NULL", state: CytrusSettings.Settings.audioOutputDevice == 1 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(1, for: .audioOutputDevice)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "OpenAL", state: CytrusSettings.Settings.audioOutputDevice == 2 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(2, for: .audioOutputDevice)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "SDL2", state: CytrusSettings.Settings.audioOutputDevice == 3 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(3, for: .audioOutputDevice)
                        button.menu = self.menu(button, viewController, isInGame)
                    })
                ]),
                UIMenu(title: "Input Device", children: [
                    UIAction(title: "Auto", state: CytrusSettings.Settings.audioInputDevice == 0 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(0, for: .audioInputDevice)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "NULL", state: CytrusSettings.Settings.audioInputDevice == 1 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(1, for: .audioInputDevice)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Static", state: CytrusSettings.Settings.audioInputDevice == 2 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(2, for: .audioInputDevice)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "OpenAL", state: CytrusSettings.Settings.audioInputDevice == 3 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(3, for: .audioInputDevice)
                        button.menu = self.menu(button, viewController, isInGame)
                    })
                ])
            ]),
            UIAction(title: "Reset Settings", image: .init(systemName: resetSettingsSystemName), attributes: [.destructive], handler: { _ in
                CytrusSettings.Settings.shared.resetSettings()
                button.menu = self.menu(button, viewController, isInGame)
            })
        ]
        
        if isInGame {
            guard let viewController = viewController as? CytrusEmulationController else {
                return .init(children: children.reversed())
            }
            
            children.insert(UIAction(title: viewController.cytrus.isPaused() ? "Play" : "Pause", image: .init(systemName: viewController.cytrus.isPaused() ? "play.fill" : "pause.fill"), handler: { _ in
                viewController.cytrus.pausePlay(viewController.cytrus.isPaused())
                button.menu = self.menu(button, viewController, isInGame)
            }), at: children.count - 1)
            children.insert(UIAction(title: "Stop & Exit", image: .init(systemName: "stop.fill"), attributes: [.destructive], handler: { _ in
                let alertController = UIAlertController(title: "Stop & Exit", message: "Are you sure?", preferredStyle: .alert)
                alertController.addAction(.init(title: "Cancel", style: .cancel))
                alertController.addAction(.init(title: "Stop & Exit", style: .destructive, handler: { _ in
                    viewController.cytrus.stop()
                    viewController.dismiss(animated: true)
                }))
                viewController.present(alertController, animated: true)
            }), at: children.count - 1)
        }
        
        return .init(children: isInGame ? children.reversed() : children)
        
        /*
        return .init(children: [
            UIMenu(title: "Core", children: [
                UIAction(title: "CPU Clock Percentage (\(CytrusSettings.Settings.cpuClockPercentage)%)", handler: { action in
                    let alertController = UIAlertController(title: "CPU Clock Percentage", message: "5% - 400%", preferredStyle: .alert)
                    alertController.addTextField { textField in
                        textField.keyboardType = .numberPad
                    }
                    alertController.addAction(.init(title: "Cancel", style: .cancel))
                    alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                        guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text, let intValue = Int(value) else {
                            return
                        }
                        
                        CytrusSettings.Settings.shared.set(intValue, for: .cpuClockPercentage)
                        button.menu = self.menu(button, viewController, isInGame)
                    }))
                    viewController.present(alertController, animated: true)
                }),
                UIAction(title: "Use New 3DS", state: CytrusSettings.Settings.useNew3DS ? .on : .off, handler: { action in
                    CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useNew3DS, for: .useNew3DS)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIAction(title: "Use LLE Applets", state: CytrusSettings.Settings.useLLEApplets ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useLLEApplets, for: .useLLEApplets)
                    button.menu = self.menu(button, viewController, isInGame)
                })
            ]),
            UIMenu(title: "System", children: [
                UIMenu(title: "Region", children: [
                    UIAction(title: "Auto", state: CytrusSettings.Settings.regionSelect == -1 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(-1, for: .regionSelect)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Japan", state: CytrusSettings.Settings.regionSelect == 0 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(0, for: .regionSelect)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "United States of America", state: CytrusSettings.Settings.regionSelect == 1 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(1, for: .regionSelect)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Europe", state: CytrusSettings.Settings.regionSelect == 2 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(2, for: .regionSelect)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Australia", state: CytrusSettings.Settings.regionSelect == 3 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(3, for: .regionSelect)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "China", state: CytrusSettings.Settings.regionSelect == 4 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(4, for: .regionSelect)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Korea", state: CytrusSettings.Settings.regionSelect == 5 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(5, for: .regionSelect)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Taiwan", state: CytrusSettings.Settings.regionSelect == 6 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(6, for: .regionSelect)
                        button.menu = self.menu(button, viewController, isInGame)
                    })
                ])
                /*,
                UIAction(title: "Use Plugin Loader", handler: { _ in
                    
                }),
                UIAction(title: "Allow Plugin Loader", handler: { _ in
                    
                })*/
            ]),
            UIMenu(title: "Renderer", children: [
                UIAction(title: "SPIRV Shader Generation", state: CytrusSettings.Settings.useSpirvShaderGeneration ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useSpirvShaderGeneration, for: .useSpirvShaderGeneration)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIAction(title: "Async Shader Compilation", state: CytrusSettings.Settings.useAsyncShaderCompilation ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useAsyncShaderCompilation, for: .useAsyncShaderCompilation)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIAction(title: "Async Presentation", state: CytrusSettings.Settings.useAsyncPresentation ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useAsyncPresentation, for: .useAsyncPresentation)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIAction(title: "Use Hardware Shader", state: CytrusSettings.Settings.useHardwareShaders ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useHardwareShaders, for: .useHardwareShaders)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIAction(title: "Accurate Shader Mul", state: CytrusSettings.Settings.useShadersAccurateMul ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useShadersAccurateMul, for: .useShadersAccurateMul)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIAction(title: "Use New VSync", state: CytrusSettings.Settings.useNewVSync ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useNewVSync, for: .useNewVSync)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIAction(title: "Resolution Factor (\(CytrusSettings.Settings.resolutionFactor))", handler: { action in
                    let alertController = UIAlertController(title: "Resolution Factor", message: "0 - 10", preferredStyle: .alert)
                    alertController.addTextField { textField in
                        textField.keyboardType = .numberPad
                    }
                    alertController.addAction(.init(title: "Cancel", style: .cancel))
                    alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                        guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text, let intValue = Int(value) else {
                            return
                        }
                        
                        CytrusSettings.Settings.shared.set(intValue, for: .resolutionFactor)
                        button.menu = self.menu(button, viewController, isInGame)
                    }))
                    viewController.present(alertController, animated: true)
                }),
                UIAction(title: "Use Shader JIT", state: CytrusSettings.Settings.useShaderJIT ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useShaderJIT, for: .useShaderJIT)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                // TODO: resolution factor
                // TODO: frame limit
                UIMenu(title: "Texture Filter", children: [
                    UIAction(title: "None", state: CytrusSettings.Settings.textureFilter == 0 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(0, for: .textureFilter)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Anime4K", state: CytrusSettings.Settings.textureFilter == 1 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(1, for: .textureFilter)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Bicubic", state: CytrusSettings.Settings.textureFilter == 2 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(2, for: .textureFilter)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "ScaleForce", state: CytrusSettings.Settings.textureFilter == 3 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(3, for: .textureFilter)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "xBRZ", state: CytrusSettings.Settings.textureFilter == 4 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(4, for: .textureFilter)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "MMPX", state: CytrusSettings.Settings.textureFilter == 5 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(5, for: .textureFilter)
                        button.menu = self.menu(button, viewController, isInGame)
                    })
                ]),
                UIMenu(title: "Texture Sampling", children: [
                    UIAction(title: "Game Controlled", state: CytrusSettings.Settings.textureSampling == 0 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(0, for: .textureSampling)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Nearest Neighbor", state: CytrusSettings.Settings.textureSampling == 1 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(1, for: .textureSampling)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Linear", state: CytrusSettings.Settings.textureSampling == 2 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(2, for: .textureSampling)
                        button.menu = self.menu(button, viewController, isInGame)
                    })
                ]),
                UIMenu(title: "Layout Option", children: [
                    UIAction(title: "Default", state: CytrusSettings.Settings.layoutOption == 0 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(0, for: .layoutOption)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Single Screen", state: CytrusSettings.Settings.layoutOption == 1 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(1, for: .layoutOption)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Large Screen", state: CytrusSettings.Settings.layoutOption == 2 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(2, for: .layoutOption)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Side Screen", state: CytrusSettings.Settings.layoutOption == 3 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(3, for: .layoutOption)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Hybrid Screen", state: CytrusSettings.Settings.layoutOption == 5 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(5, for: .layoutOption)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Mobile Portrait", state: CytrusSettings.Settings.layoutOption == 6 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(6, for: .layoutOption)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Mobile Landscape", state: CytrusSettings.Settings.layoutOption == 7 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(7, for: .layoutOption)
                        button.menu = self.menu(button, viewController, isInGame)
                    })
                ]),/*
                UIMenu(title: "Render 3D", children: [
                    // TODO: factor 3d
                    UIAction(title: "Off", state: CytrusSettings.Settings.render3D == 0 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(0, for: .render3D)
                        button.menu = self.menu(button)
                    }),
                    UIAction(title: "Side By Side", state: CytrusSettings.Settings.render3D == 1 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(1, for: .render3D)
                        button.menu = self.menu(button)
                    }),
                    UIAction(title: "Anaglyph", state: CytrusSettings.Settings.render3D == 2 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(2, for: .render3D)
                        button.menu = self.menu(button)
                    }),
                    UIAction(title: "Interlaced", state: CytrusSettings.Settings.render3D == 3 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(3, for: .render3D)
                        button.menu = self.menu(button)
                    }),
                    UIAction(title: "Reverse Interlaced", state: CytrusSettings.Settings.render3D == 4 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(4, for: .render3D)
                        button.menu = self.menu(button)
                    }),
                    UIAction(title: "Cardboard VR", state: CytrusSettings.Settings.render3D == 5 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(5, for: .render3D)
                        button.menu = self.menu(button)
                    })
                ]),
                UIMenu(title: "Mono Render", children: [
                    UIAction(title: "LeftEye", state: CytrusSettings.Settings.monoRender == 0 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(0, for: .monoRender)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "RightEye", state: CytrusSettings.Settings.monoRender == 1 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(1, for: .monoRender)
                        button.menu = self.menu(button, viewController, isInGame)
                    })
                ]),*/
                UIAction(title: "Use Custom Textures", state: CytrusSettings.Settings.useCustomTextures ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useCustomTextures, for: .useCustomTextures)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIAction(title: "Preload Textures", state: CytrusSettings.Settings.preloadTextures ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.preloadTextures, for: .preloadTextures)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIAction(title: "Async Custom Loading", state: CytrusSettings.Settings.asyncCustomLoading ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.asyncCustomLoading, for: .asyncCustomLoading)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIMenu(title: "Custom Layout", children: [
                    UIAction(title: "Use Custom Layout", state: CytrusSettings.Settings.useCustomLayout ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.useCustomLayout, for: .useCustomLayout)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIMenu(title: "Layout Settings", children: [
                        UIAction(title: "Top Left (\(CytrusSettings.Settings.customLayoutTopLeft))", handler: { action in
                            let alertController = UIAlertController(title: "Custom Layout", message: action.title, preferredStyle: .alert)
                            alertController.addTextField { textField in
                                textField.keyboardType = .numberPad
                            }
                            alertController.addAction(.init(title: "Cancel", style: .cancel))
                            alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                                guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text, let intValue = Int(value) else {
                                    return
                                }
                                
                                CytrusSettings.Settings.shared.set(intValue, for: .customLayoutTopLeft)
                                button.menu = self.menu(button, viewController, isInGame)
                            }))
                            viewController.present(alertController, animated: true)
                        }),
                        UIAction(title: "Top Top (\(CytrusSettings.Settings.customLayoutTopTop))", handler: { action in
                            let alertController = UIAlertController(title: "Custom Layout", message: action.title, preferredStyle: .alert)
                            alertController.addTextField { textField in
                                textField.keyboardType = .numberPad
                            }
                            alertController.addAction(.init(title: "Cancel", style: .cancel))
                            alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                                guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text, let intValue = Int(value) else {
                                    return
                                }
                                
                                CytrusSettings.Settings.shared.set(intValue, for: .customLayoutTopTop)
                                button.menu = self.menu(button, viewController, isInGame)
                            }))
                            viewController.present(alertController, animated: true)
                        }),
                        UIAction(title: "Top Right (\(CytrusSettings.Settings.customLayoutTopRight))", handler: { action in
                            let alertController = UIAlertController(title: "Custom Layout", message: action.title, preferredStyle: .alert)
                            alertController.addTextField { textField in
                                textField.keyboardType = .numberPad
                            }
                            alertController.addAction(.init(title: "Cancel", style: .cancel))
                            alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                                guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text, let intValue = Int(value) else {
                                    return
                                }
                                
                                CytrusSettings.Settings.shared.set(intValue, for: .customLayoutTopRight)
                                button.menu = self.menu(button, viewController, isInGame)
                            }))
                            viewController.present(alertController, animated: true)
                        }),
                        UIAction(title: "Top Bottom (\(CytrusSettings.Settings.customLayoutTopBottom))", handler: { action in
                            let alertController = UIAlertController(title: "Custom Layout", message: action.title, preferredStyle: .alert)
                            alertController.addTextField { textField in
                                textField.keyboardType = .numberPad
                            }
                            alertController.addAction(.init(title: "Cancel", style: .cancel))
                            alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                                guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text, let intValue = Int(value) else {
                                    return
                                }
                                
                                CytrusSettings.Settings.shared.set(intValue, for: .customLayoutTopBottom)
                                button.menu = self.menu(button, viewController, isInGame)
                            }))
                            viewController.present(alertController, animated: true)
                        }),
                        UIAction(title: "Bottom Left (\(CytrusSettings.Settings.customLayoutBottomLeft))", handler: { action in
                            let alertController = UIAlertController(title: "Custom Layout", message: action.title, preferredStyle: .alert)
                            alertController.addTextField { textField in
                                textField.keyboardType = .numberPad
                            }
                            alertController.addAction(.init(title: "Cancel", style: .cancel))
                            alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                                guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text, let intValue = Int(value) else {
                                    return
                                }
                                
                                CytrusSettings.Settings.shared.set(intValue, for: .customLayoutBottomLeft)
                                button.menu = self.menu(button, viewController, isInGame)
                            }))
                            viewController.present(alertController, animated: true)
                        }),
                        UIAction(title: "Bottom Top (\(CytrusSettings.Settings.customLayoutBottomTop))", handler: { action in
                            let alertController = UIAlertController(title: "Custom Layout", message: action.title, preferredStyle: .alert)
                            alertController.addTextField { textField in
                                textField.keyboardType = .numberPad
                            }
                            alertController.addAction(.init(title: "Cancel", style: .cancel))
                            alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                                guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text, let intValue = Int(value) else {
                                    return
                                }
                                
                                CytrusSettings.Settings.shared.set(intValue, for: .customLayoutBottomTop)
                                button.menu = self.menu(button, viewController, isInGame)
                            }))
                            viewController.present(alertController, animated: true)
                        }),
                        UIAction(title: "Bottom Right (\(CytrusSettings.Settings.customLayoutBottomRight))", handler: { action in
                            let alertController = UIAlertController(title: "Custom Layout", message: action.title, preferredStyle: .alert)
                            alertController.addTextField { textField in
                                textField.keyboardType = .numberPad
                            }
                            alertController.addAction(.init(title: "Cancel", style: .cancel))
                            alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                                guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text, let intValue = Int(value) else {
                                    return
                                }
                                
                                CytrusSettings.Settings.shared.set(intValue, for: .customLayoutBottomRight)
                                button.menu = self.menu(button, viewController, isInGame)
                            }))
                            viewController.present(alertController, animated: true)
                        }),
                        UIAction(title: "Bottom Bottom (\(CytrusSettings.Settings.customLayoutBottomBottom))", handler: { action in
                            let alertController = UIAlertController(title: "Custom Layout", message: action.title, preferredStyle: .alert)
                            alertController.addTextField { textField in
                                textField.keyboardType = .numberPad
                            }
                            alertController.addAction(.init(title: "Cancel", style: .cancel))
                            alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                                guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text, let intValue = Int(value) else {
                                    return
                                }
                                
                                CytrusSettings.Settings.shared.set(intValue, for: .customLayoutBottomBottom)
                                button.menu = self.menu(button, viewController, isInGame)
                            }))
                            viewController.present(alertController, animated: true)
                        })
                    ])
                ])
            ]),
            UIMenu(title: "Audio", children: [
                UIMenu(title: "Audio Emulation", children: [
                    UIAction(title: "HLE", state: CytrusSettings.Settings.audioEmulation == 0 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(0, for: .audioEmulation)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "LLE", state: CytrusSettings.Settings.audioEmulation == 1 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(1, for: .audioEmulation)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "LLE Multithreaded", state: CytrusSettings.Settings.audioEmulation == 2 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(2, for: .audioEmulation)
                        button.menu = self.menu(button, viewController, isInGame)
                    })
                ]),
                UIAction(title: "Use Audio Stretching", state: CytrusSettings.Settings.audioStretching ? .on : .off, handler: { _ in
                    CytrusSettings.Settings.shared.set(!CytrusSettings.Settings.audioStretching, for: .audioStretching)
                    button.menu = self.menu(button, viewController, isInGame)
                }),
                UIMenu(title: "Output Device", children: [
                    UIAction(title: "Auto", state: CytrusSettings.Settings.audioOutputDevice == 0 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(0, for: .audioOutputDevice)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "NULL", state: CytrusSettings.Settings.audioOutputDevice == 1 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(1, for: .audioOutputDevice)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "OpenAL", state: CytrusSettings.Settings.audioOutputDevice == 2 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(2, for: .audioOutputDevice)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "SDL2", state: CytrusSettings.Settings.audioOutputDevice == 3 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(3, for: .audioOutputDevice)
                        button.menu = self.menu(button, viewController, isInGame)
                    })
                ]),
                UIMenu(title: "Input Device", children: [
                    UIAction(title: "Auto", state: CytrusSettings.Settings.audioInputDevice == 0 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(0, for: .audioInputDevice)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "NULL", state: CytrusSettings.Settings.audioInputDevice == 1 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(1, for: .audioInputDevice)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "Static", state: CytrusSettings.Settings.audioInputDevice == 2 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(2, for: .audioInputDevice)
                        button.menu = self.menu(button, viewController, isInGame)
                    }),
                    UIAction(title: "OpenAL", state: CytrusSettings.Settings.audioInputDevice == 3 ? .on : .off, handler: { _ in
                        CytrusSettings.Settings.shared.set(3, for: .audioInputDevice)
                        button.menu = self.menu(button, viewController, isInGame)
                    })
                ])
            ])
        ])
         */
    }
}
