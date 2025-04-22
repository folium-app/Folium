//
//  CytrusSettingsController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 9/8/2024.
//

import Cytrus
import Foundation
import SettingsKit
import UIKit

enum CytrusSettingsHeaders : String, CaseIterable {
    case core = "Core"
    case debugging = "Debugging"
    case system = "System"
    case systemSaveGame = "System Save Game"
    case renderer = "Renderer"
    case defaultLayout = "Default Layout"
    case customLayout = "Custom Layout"
    case audio = "Audio"
    case miscellaneous = "Miscellaneous"
    
    var header: SettingHeader {
        switch self {
        case .core,
                .debugging,
                .system,
                .systemSaveGame,
                .renderer,
                .defaultLayout,
                .audio,
                .miscellaneous: .init(text: rawValue)
        case .customLayout: .init(text: rawValue,
                                  secondaryText: "Set Default Layout to Custom Layout")
        }
    }
    
    static var allHeaders: [SettingHeader] { allCases.map { $0.header } }
}

enum CytrusSettingsItems : String, CaseIterable {
    // Core
    case cpuJIT = "cytrus.cpuJIT"
    case cpuClockPercentage = "cytrus.cpuClockPercentage"
    case new3DS = "cytrus.new3DS"
    case lleApplets = "cytrus.lleApplets"
    case deterministicAsyncOperations = "cytrus.deterministicAsyncOperations"
    case enableRequiredOnlineLLEModules = "cytrus.enableRequiredOnlineLLEModules"

    // System
    case regionValue = "cytrus.regionValue"
    case pluginLoader = "cytrus.pluginLoader"
    case allowPluginLoader = "cytrus.allowPluginLoader"
    case stepsPerHour = "cytrus.stepsPerHour"

    // Renderer
    case spirvShaderGeneration = "cytrus.spirvShaderGeneration"
    case useAsyncShaderCompilation = "cytrus.useAsyncShaderCompilation"
    case useAsyncPresentation = "cytrus.useAsyncPresentation"
    case useHardwareShaders = "cytrus.useHardwareShaders"
    case useDiskShaderCache = "cytrus.useDiskShaderCache"
    case useShadersAccurateMul = "cytrus.useShadersAccurateMul"
    case useNewVSync = "cytrus.useNewVSync"
    case useShaderJIT = "cytrus.useShaderJIT"
    case resolutionFactor = "cytrus.resolutionFactor"
    case textureFilter = "cytrus.textureFilter"
    case textureSampling = "cytrus.textureSampling"
    case delayGameRenderThreadUS = "cytrus.delayGameRenderThreadUS"
    case layoutOption = "cytrus.layoutOption"
    case customTopX = "cytrus.customTopX"
    case customTopY = "cytrus.customTopY"
    case customTopWidth = "cytrus.customTopWidth"
    case customTopHeight = "cytrus.customTopHeight"
    case customBottomX = "cytrus.customBottomX"
    case customBottomY = "cytrus.customBottomY"
    case customBottomWidth = "cytrus.customBottomWidth"
    case customBottomHeight = "cytrus.customBottomHeight"
    case customSecondLayerOpacity = "cytrus.customSecondLayerOpacity"
    case render3D = "cytrus.render3D"
    case factor3D = "cytrus.factor3D"
    case monoRender = "cytrus.monoRender"
    case filterMode = "cytrus.filterMode"
    case ppShaderName = "cytrus.ppShaderName"
    case anaglyphShaderName = "cytrus.anaglyphShaderName"
    case dumpTextures = "cytrus.dumpTextures"
    case customTextures = "cytrus.customTextures"
    case preloadTextures = "cytrus.preloadTextures"
    case asyncCustomLoading = "cytrus.asyncCustomLoading"
    case disableRightEyeRender = "cytrus.disableRightEyeRender"

    // Audio
    case audioMuted = "cytrus.audioMuted"
    case audioEmulation = "cytrus.audioEmulation"
    case audioStretching = "cytrus.audioStretching"
    case realtimeAudio = "cytrus.realtimeAudio"
    case volume = "cytrus.volume"
    case outputType = "cytrus.outputType"
    case inputType = "cytrus.inputType"

    // Miscellaneous
    case logLevel = "cytrus.logLevel"
    case webAPIURL = "cytrus.webAPIURL"
    
    case systemLanguage = "cytrus.systemLanguage"
    case username = "cytrus.username"
    
    var title: String {
        switch self {
        case .cpuJIT: "CPU JIT"
        case .cpuClockPercentage: "CPU Clock Percentage"
        case .new3DS: "New 3DS"
        case .lleApplets: "LLE Applets"
        case .deterministicAsyncOperations: "Deterministic Async Operations"
        case .enableRequiredOnlineLLEModules: "Required Online LLE Modules"
        case .regionValue: "Region Value"
        case .pluginLoader: "Plugin Loader"
        case .allowPluginLoader: "Allow Plugin Loader"
        case .stepsPerHour: "Steps Per Hour"
        case .spirvShaderGeneration: "SPIR-V Shader Generation"
        case .useAsyncShaderCompilation: "Async Shader Compilation"
        case .useAsyncPresentation: "Async Presentation"
        case .useHardwareShaders: "Hardware Shaders"
        case .useDiskShaderCache: "Disk Shader Cache"
        case .useShadersAccurateMul: "Shaders Accurate Mul"
        case .useNewVSync: "New VSync"
        case .useShaderJIT: "Shader JIT"
        case .resolutionFactor: "Resolution Factor"
        case .textureFilter: "Texture Filter"
        case .textureSampling: "Texture Sampling"
        case .delayGameRenderThreadUS: "Delay Game Render Thread US"
        case .layoutOption: "Layout Option"
        case .customTopX: "Custom Top X"
        case .customTopY: "Custom Top Y"
        case .customTopWidth: "Custom Top Width"
        case .customTopHeight: "Custom Top Height"
        case .customBottomX: "Custom Bottom X"
        case .customBottomY: "Custom Bottom Y"
        case .customBottomWidth: "Custom Bottom Width"
        case .customBottomHeight: "Custom Bottom Height"
        case .customSecondLayerOpacity: "Custom Second Layer Opacity"
        case .render3D: "Render 3D"
        case .factor3D: "Factor 3D"
        case .monoRender: "Mono Render"
        case .filterMode: "Filter Mode"
        case .ppShaderName: "PP Shader Name"
        case .anaglyphShaderName: "Anaglyph Shader Name"
        case .dumpTextures: "Dump Textures"
        case .customTextures: "Custom Textures"
        case .preloadTextures: "Preload Textures"
        case .asyncCustomLoading: "Async Custom Loading"
        case .disableRightEyeRender: "Disable Right Eye Render"
        case .audioMuted: "Audio Muted"
        case .audioEmulation: "Audio Emulation"
        case .audioStretching: "Audio Stretching"
        case .realtimeAudio: "Realtime Audio"
        case .volume: "Volume"
        case .outputType: "Output Type"
        case .inputType: "Input Type"
        case .logLevel: "Log Level"
        case .webAPIURL: "Web API URL"
        case .systemLanguage: "System Language"
        case .username: "Username"
        }
    }
    
    func setting(_ delegate: SettingDelegate? = nil) -> BaseSetting {
        switch self {
        case .cpuJIT,
                .new3DS,
                .lleApplets,
                .deterministicAsyncOperations,
                .enableRequiredOnlineLLEModules,
                .pluginLoader,
                .allowPluginLoader,
                .spirvShaderGeneration,
                .useAsyncShaderCompilation,
                .useAsyncPresentation,
                .useHardwareShaders,
                .useDiskShaderCache,
                .useShadersAccurateMul,
                .useNewVSync,
                .useShaderJIT,
                .filterMode,
                .dumpTextures,
                .customTextures,
                .preloadTextures,
                .asyncCustomLoading,
                .disableRightEyeRender,
                .audioMuted,
                .audioStretching,
                .realtimeAudio:
            BoolSetting(key: rawValue,
                        title: title,
                        details: nil,
                        value: UserDefaults.standard.bool(forKey: rawValue),
                        delegate: delegate)
        case .cpuClockPercentage:
            InputNumberSetting(key: rawValue,
                               title: title,
                               details: nil,
                               min: 5, max: 400,
                               value: UserDefaults.standard.double(forKey: rawValue),
                               delegate: delegate)
        case .regionValue:
            SelectionSetting(key: rawValue,
                             title: title,
                             details: nil,
                             values: [
                                "Automatic" : -1,
                                "Japan" : 0,
                                "USA" : 1,
                                "Europe" : 2,
                                "Australia" : 3,
                                "China" : 4,
                                "Korea" : 5,
                                "Taiwan" : 6
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
        case .stepsPerHour:
            InputNumberSetting(key: rawValue,
                               title: title,
                               details: nil,
                               min: 0, max: 9999,
                               value: UserDefaults.standard.double(forKey: rawValue),
                               delegate: delegate)
        case .resolutionFactor:
            StepperSetting(key: rawValue,
                                title: title,
                                details: nil,
                                min: 0,
                                max: 10,
                                value: UserDefaults.standard.double(forKey: rawValue),
                                delegate: delegate)
        case .textureFilter:
            SelectionSetting(key: rawValue,
                             title: title,
                             details: nil,
                             values: [
                               "None" : 0,
                               "Anime4K" : 1,
                               "Bicubic" : 2,
                               "ScaleForce" : 3,
                               "xBRZ" : 4,
                               "MMPX" : 5
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
        case .textureSampling:
            SelectionSetting(key: rawValue,
                             title: title,
                             values: [
                               "Game Controlled" : 0,
                               "Nearest Neighbor" : 1,
                               "Linear" : 2
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
        case .delayGameRenderThreadUS:
            InputNumberSetting(key: rawValue,
                               title: title,
                               details: nil,
                               min: 0, max: 16000,
                               value: UserDefaults.standard.double(forKey: rawValue),
                               delegate: delegate)
        case .layoutOption:
            SelectionSetting(key: rawValue,
                             title: title,
                             details: nil,
                             values: [
                               "Default" : 0,
                               "Single Screen" : 1,
                               "Large Screen" : 2,
                               "Side Screen" : 3,
                               "Hybrid Screen" : 5,
                               "Custom Layout" : 6
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
        case .customTopX,
                .customTopY,
                .customTopWidth,
                .customTopHeight,
                .customBottomX,
                .customBottomY,
                .customBottomWidth,
                .customBottomHeight:
            InputNumberSetting(key: rawValue,
                               title: title,
                               details: nil,
                               min: 0, max: 9999,
                               value: UserDefaults.standard.double(forKey: rawValue),
                               delegate: delegate)
        case .customSecondLayerOpacity:
            InputNumberSetting(key: rawValue,
                               title: title,
                               details: nil,
                               min: 0, max: 100,
                               value: UserDefaults.standard.double(forKey: rawValue),
                               delegate: delegate)
        case .render3D:
            SelectionSetting(key: rawValue,
                             title: title,
                             details: nil,
                             values: [
                               "Off" : 0,
                               "Side by Side" : 1,
                               "Anaglyph" : 2,
                               "Interlaced" : 3,
                               "ReverseInterlaced" : 4,
                               "CardboardVR" : 5
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
        case .factor3D:
            StepperSetting(key: rawValue,
                           title: title,
                           details: nil,
                           min: 0,
                           max: 100,
                           value: UserDefaults.standard.double(forKey: rawValue),
                           delegate: delegate)
        case .monoRender:
            SelectionSetting(key: rawValue,
                             title: title,
                             details: nil,
                             values: [
                               "Left Eye" : 0,
                               "Right Eye" : 1
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
        case .ppShaderName:
            InputStringSetting(key: rawValue,
                               title: title,
                               placeholder: "none (builtin)",
                               value: UserDefaults.standard.string(forKey: rawValue),
                               action: {},
                               delegate: delegate)
        case .anaglyphShaderName:
            InputStringSetting(key: rawValue,
                               title: title,
                               placeholder: "dubois (builtin)",
                               value: UserDefaults.standard.string(forKey: rawValue),
                               action: {},
                               delegate: delegate)
        case .audioEmulation:
            SelectionSetting(key: rawValue,
                             title: title,
                             values: [
                               "HLE" : 0,
                               "LLE" : 1,
                               "LLE (Multithreaded)" : 2
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
        case .volume:
            StepperSetting(key: rawValue,
                           title: title,
                           details: nil,
                           min: 0,
                           max: 1,
                           value: UserDefaults.standard.double(forKey: rawValue),
                           delegate: delegate)
        case .outputType:
            SelectionSetting(key: rawValue,
                             title: title,
                             values: [
                               "Automatic" : 0,
                               "None" : 1,
                               "CoreAudio" : 2,
                               "OpenAL" : 3,
                               "SDL3" : 4
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
        case .inputType:
            SelectionSetting(key: rawValue,
                             title: title,
                             values: [
                               "Automatic" : 0,
                               "None" : 1,
                               "Static" : 2,
                               "OpenAL" : 3
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
        case .logLevel:
            SelectionSetting(key: rawValue,
                             title: title,
                             details: nil,
                             values: [
                               "Trace" : 0,
                               "Debug" : 1,
                               "Info" : 2,
                               "Warning" : 3,
                               "Error" : 4,
                               "Critical" : 5
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {},
                             delegate: delegate)
        case .webAPIURL:
            InputStringSetting(key: rawValue,
                               title: title,
                               details: nil,
                               placeholder: "http(s)://address:port",
                               value: UserDefaults.standard.string(forKey: rawValue),
                               action: {
                                   MultiplayerManager.shared().updateWebAPIURL()
                               },
                               delegate: delegate)
        case .systemLanguage:
            SelectionSetting(key: rawValue,
                             title: title,
                             values: [
                               "Japanese" : 0,
                               "English" : 1,
                               "French" : 2,
                               "German" : 3,
                               "Italian" : 4,
                               "Spanish" : 5,
                               "Simplified Chinese" : 6,
                               "Korean" : 7,
                               "Dutch" : 8,
                               "Portuguese" : 9,
                               "Russian" : 10,
                               "Traditional Chinese" : 11
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: rawValue),
                             action: {
                                 guard let systemLanguage = UserDefaults.standard.value(forKey: rawValue) as? Int else { return }
                                 SystemSaveGame.shared.set(systemLanguage)
                             },
                             delegate: delegate)
        case .username:
            InputStringSetting(key: rawValue,
                               title: title,
                               placeholder: "Cytrus",
                               value: UserDefaults.standard.string(forKey: rawValue),
                               action: {
                                   guard let username = UserDefaults.standard.string(forKey: rawValue) else { return }
                                   SystemSaveGame.shared.set(username)
                               },
                               delegate: delegate)
        }
    }
    
    static func settings(_ header: CytrusSettingsHeaders) -> [CytrusSettingsItems] {
        var debugging: [CytrusSettingsItems] = [.logLevel]
        if AppStoreCheck.shared.debugging {
            debugging.insert(.cpuJIT, at: 0)
        }
        
        return switch header {
        case .core:
            [
                .cpuClockPercentage,
                .new3DS,
                .lleApplets,
                .deterministicAsyncOperations,
                .enableRequiredOnlineLLEModules
            ]
        case .debugging:
            debugging
        case .system:
            [
                .regionValue,
                .pluginLoader,
                .allowPluginLoader,
                .stepsPerHour
            ]
        case .systemSaveGame:
            [
                .systemLanguage,
                .username
            ]
        case .renderer:
            [
                .spirvShaderGeneration,
                .useAsyncShaderCompilation,
                .useAsyncPresentation,
                .useHardwareShaders,
                .useDiskShaderCache,
                .useShadersAccurateMul,
                .useNewVSync,
                .useShaderJIT,
                .resolutionFactor,
                .textureFilter,
                .textureSampling,
                .delayGameRenderThreadUS,
                .render3D,
                .factor3D,
                .monoRender,
                .filterMode,
                .ppShaderName,
                .anaglyphShaderName,
                .dumpTextures,
                .customTextures,
                .preloadTextures,
                .asyncCustomLoading,
                .disableRightEyeRender
            ]
        case .defaultLayout:
            [
                .layoutOption
            ]
        case .customLayout:
            [
                .customTopX,
                .customTopY,
                .customTopWidth,
                .customTopHeight,
                .customBottomX,
                .customBottomY,
                .customBottomWidth,
                .customBottomHeight,
                .customSecondLayerOpacity
            ]
        case .audio:
            [
                .audioMuted,
                .audioEmulation,
                .audioStretching,
                .realtimeAudio,
                .volume,
                .outputType,
                .inputType
            ]
        case .miscellaneous:
            [
                .webAPIURL
            ]
        }
    }
}

class CytrusSettingsController : UICollectionViewController {
    var dataSource: UICollectionViewDiffableDataSource<CytrusSettingsHeaders, AHS>! = nil
    var snapshot: NSDiffableDataSourceSnapshot<CytrusSettingsHeaders, AHS>! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setLeftBarButton(.init(systemItem: .close, primaryAction: .init(handler: { _ in
            self.dismiss(animated: true)
        })), animated: true)
        prefersLargeTitles(true)
        title = "Cytrus"
        
        let boolCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, BoolSetting> { cell, indexPath, itemIdentifier in
            var contentConfiguration = UIListContentConfiguration.cell()
            contentConfiguration.text = itemIdentifier.title
            cell.contentConfiguration = contentConfiguration
            
            let toggle = UISwitch(frame: .zero, primaryAction: .init(handler: { action in
                guard let toggle = action.sender as? UISwitch else {
                    return
                }
                
                UserDefaults.standard.set(toggle.isOn, forKey: itemIdentifier.key)
                if let delegate = itemIdentifier.delegate {
                    delegate.didChangeSetting(at: indexPath)
                }
            }))
            toggle.isOn = itemIdentifier.value
            
            cell.accessories = if let details = itemIdentifier.details {
                [
                    .customView(configuration: .init(customView: toggle, placement: .trailing())),
                    .detail(options: .init(tintColor: .systemBlue), actionHandler: {
                        let alertController = UIAlertController(title: "\(itemIdentifier.title) Details", message: details, preferredStyle: .alert)
                        alertController.addAction(.init(title: "Dismiss", style: .cancel))
                        self.present(alertController, animated: true)
                    })
                ]
            } else {
                [
                    .customView(configuration: .init(customView: toggle, placement: .trailing()))
                ]
            }
        }
        
        let inputNumberCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, InputNumberSetting> { cell, indexPath, itemIdentifier in
            var contentConfiguration = UIListContentConfiguration.valueCell()
            contentConfiguration.text = itemIdentifier.title
            contentConfiguration.secondaryText = "\(Int(itemIdentifier.value))"
            contentConfiguration.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = contentConfiguration
            
            cell.accessories = [
                .disclosureIndicator()
            ]
        }
        
        let inputStringCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, InputStringSetting> { cell, indexPath, itemIdentifier in
            var contentConfiguration = UIListContentConfiguration.valueCell()
            contentConfiguration.text = itemIdentifier.title
            contentConfiguration.secondaryText = itemIdentifier.value
            contentConfiguration.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = contentConfiguration
            
            cell.accessories = if let details = itemIdentifier.details {
                [
                    .detail(options: .init(tintColor: .systemBlue), actionHandler: {
                        let alertController = UIAlertController(title: "\(itemIdentifier.title) Details", message: details, preferredStyle: .alert)
                        alertController.addAction(.init(title: "Dismiss", style: .cancel))
                        self.present(alertController, animated: true)
                    }),
                    .disclosureIndicator()
                ]
            } else {
                [
                    .disclosureIndicator()
                ]
            }
        }
        
        let stepperCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, StepperSetting> { cell, indexPath, itemIdentifier in
            var contentConfiguration = UIListContentConfiguration.subtitleCell()
            contentConfiguration.text = itemIdentifier.title
            contentConfiguration.secondaryText = "Current: \(Int(itemIdentifier.value)), Min: \(Int(itemIdentifier.min)), Max: \(Int(itemIdentifier.max))"
            contentConfiguration.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = contentConfiguration
            
            let stepper = UIStepper(frame: .zero, primaryAction: .init(handler: { action in
                guard let stepper = action.sender as? UIStepper else {
                    return
                }
                
                UserDefaults.standard.set(stepper.value, forKey: itemIdentifier.key)
                if let delegate = itemIdentifier.delegate {
                    delegate.didChangeSetting(at: indexPath)
                }
            }))
            stepper.minimumValue = itemIdentifier.min
            stepper.maximumValue = itemIdentifier.max
            stepper.value = itemIdentifier.value
            
            cell.accessories = if let details = itemIdentifier.details {
                [
                    .customView(configuration: .init(customView: stepper, placement: .trailing(), reservedLayoutWidth: .actual)),
                    .detail(options: .init(tintColor: .systemBlue), actionHandler: {
                        let alertController = UIAlertController(title: "\(itemIdentifier.title) Details", message: details, preferredStyle: .alert)
                        alertController.addAction(.init(title: "Dismiss", style: .cancel))
                        self.present(alertController, animated: true)
                    })
                ]
            } else {
                [
                    .customView(configuration: .init(customView: stepper, placement: .trailing(), reservedLayoutWidth: .actual))
                ]
            }
        }
        
        let selectionCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SelectionSetting> { cell, indexPath, itemIdentifier in
            var contentConfiguration = UIListContentConfiguration.cell()
            contentConfiguration.text = itemIdentifier.title
            cell.contentConfiguration = contentConfiguration
            
            let children: [UIMenuElement] = switch itemIdentifier.values {
            case let stringInt as [String : Int]:
                stringInt.reduce(into: [UIAction](), { partialResult, element in
                    var state: UIMenuElement.State = .off
                    if let selectedValue = itemIdentifier.selectedValue as? Int {
                        state = element.value == selectedValue ? .on : .off
                    }
                    
                    partialResult.append(.init(title: element.key, state: state, handler: { _ in
                        UserDefaults.standard.set(element.value, forKey: itemIdentifier.key)
                        if let delegate = itemIdentifier.delegate {
                            delegate.didChangeSetting(at: indexPath)
                        }
                    }))
                })
            case let stringString as [String : String]:
                stringString.reduce(into: [UIAction](), { partialResult, element in
                    var state: UIMenuElement.State = .off
                    if let selectedValue = itemIdentifier.selectedValue as? String {
                        state = element.value == selectedValue ? .on : .off
                    }
                    
                    partialResult.append(.init(title: element.key, state: state, handler: { _ in
                        UserDefaults.standard.set(element.value, forKey: itemIdentifier.key)
                        if let delegate = itemIdentifier.delegate {
                            delegate.didChangeSetting(at: indexPath)
                        }
                    }))
                })
            default:
                []
            }
            
            var title = "Automatic"
            if let selectedValue = itemIdentifier.selectedValue {
                switch selectedValue {
                case let intValue as Int:
                    if let values = itemIdentifier.values as? [String : Int] {
                        title = values.first(where: { $0.value == intValue })?.key ?? title
                    }
                case let stringValue as String:
                    if let values = itemIdentifier.values as? [String : String] {
                        title = values.first(where: { $0.value == stringValue })?.key ?? title
                    }
                default:
                    break
                }
            }
            
            cell.accessories = if let details = itemIdentifier.details {
                [
                    .label(text: title),
                    .popUpMenu(UIMenu(children: children.sorted(by: { $0.title < $1.title }))),
                    .detail(options: .init(tintColor: .systemBlue), actionHandler: {
                        let alertController = UIAlertController(title: "\(itemIdentifier.title) Details", message: details, preferredStyle: .alert)
                        alertController.addAction(.init(title: "Dismiss", style: .cancel))
                        self.present(alertController, animated: true)
                    })
                ]
            } else {
                [
                    .label(text: title),
                    .popUpMenu(UIMenu(children: children.sorted(by: { $0.title < $1.title })))
                ]
            }
        }
        
        let blankSettingsCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, BlankSetting> { cell, indexPath, itemIdentifier in
            cell.contentConfiguration = UIListContentConfiguration.cell()
        }
        
        let headerCellRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            var contentConfiguration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            contentConfiguration.text = self.snapshot.sectionIdentifiers[indexPath.section].header.text
            contentConfiguration.secondaryText = self.snapshot.sectionIdentifiers[indexPath.section].header.secondaryText
            contentConfiguration.secondaryTextProperties.color = .secondaryLabel
            supplementaryView.contentConfiguration = contentConfiguration
        }
        
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case let blankSetting as BlankSetting:
                collectionView.dequeueConfiguredReusableCell(using: blankSettingsCellRegistration, for: indexPath, item: blankSetting)
            case let boolSetting as BoolSetting:
                collectionView.dequeueConfiguredReusableCell(using: boolCellRegistration, for: indexPath, item: boolSetting)
            case let inputNumberSetting as InputNumberSetting:
                collectionView.dequeueConfiguredReusableCell(using: inputNumberCellRegistration, for: indexPath, item: inputNumberSetting)
            case let inputStringSetting as InputStringSetting:
                collectionView.dequeueConfiguredReusableCell(using: inputStringCellRegistration, for: indexPath, item: inputStringSetting)
            case let stepperSetting as StepperSetting:
                collectionView.dequeueConfiguredReusableCell(using: stepperCellRegistration, for: indexPath, item: stepperSetting)
            case let selectionSetting as SelectionSetting:
                collectionView.dequeueConfiguredReusableCell(using: selectionCellRegistration, for: indexPath, item: selectionSetting)
            default:
                nil
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerCellRegistration, for: indexPath)
        }
        
        snapshot = .init()
        snapshot.appendSections(CytrusSettingsHeaders.allCases)
        snapshot.sectionIdentifiers.forEach { header in
            snapshot.appendItems(CytrusSettingsItems.settings(header).map { $0.setting(self) }, toSection: header)
        }
        
        Task { await dataSource.apply(snapshot) }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        switch dataSource.itemIdentifier(for: indexPath) {
        case let inputSetting as InputNumberSetting:
            let alertController = UIAlertController(title: inputSetting.title, message: inputSetting.details?
                .appending("\n\nMin: \(Int(inputSetting.min)), Max: \(Int(inputSetting.max))"),
                                                    preferredStyle: .alert)
            alertController.addTextField {
                $0.keyboardType = .numberPad
            }
            alertController.addAction(.init(title: "Cancel", style: .cancel))
            alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text as? NSString else {
                    return
                }
                
                UserDefaults.standard.set(value.doubleValue, forKey: inputSetting.key)
                if let delegate = inputSetting.delegate {
                    delegate.didChangeSetting(at: indexPath)
                }
            }))
            present(alertController, animated: true)
        case let inputSetting as InputStringSetting:
            let alertController = UIAlertController(title: inputSetting.title,
                                                    message: inputSetting.details,
                                                    preferredStyle: .alert)
            alertController.addTextField {
                $0.placeholder = inputSetting.placeholder
            }
            
            alertController.addAction(.init(title: "Cancel", style: .cancel))
            alertController.addAction(.init(title: "Save", style: .default, handler: { _ in
                guard let textFields = alertController.textFields, let textField = textFields.first, let value = textField.text else {
                    return
                }
                
                UserDefaults.standard.set(value, forKey: inputSetting.key)
                if let delegate = inputSetting.delegate {
                    inputSetting.action()
                    delegate.didChangeSetting(at: indexPath)
                }
            }))
            present(alertController, animated: true)
        default:
            break
        }
    }
}

extension CytrusSettingsController : SettingDelegate {
    func didChangeSetting(at indexPath: IndexPath) {
        Cytrus.shared.updateSettings()
        
        guard let sectionIdentifier = dataSource.sectionIdentifier(for: indexPath.section) else {
            return
        }
        
        var snapshot = dataSource.snapshot()
        let item = snapshot.itemIdentifiers(inSection: sectionIdentifier)[indexPath.item]
        
        switch item {
        case let boolSetting as BoolSetting:
            boolSetting.value = UserDefaults.standard.bool(forKey: boolSetting.key)
        case let inputNumberSetting as InputNumberSetting:
            inputNumberSetting.value = UserDefaults.standard.double(forKey: inputNumberSetting.key)
        case let inputStringSetting as InputStringSetting:
            inputStringSetting.value = UserDefaults.standard.string(forKey: inputStringSetting.key)
        case let stepperSetting as StepperSetting:
            stepperSetting.value = UserDefaults.standard.double(forKey: stepperSetting.key)
        case let selectionSetting as SelectionSetting:
            selectionSetting.selectedValue = UserDefaults.standard.value(forKey: selectionSetting.key)
        default:
            break
        }
        
        snapshot.reloadItems([item])
        Task {
            await dataSource.apply(snapshot)
        }
    }
}
