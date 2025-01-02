//
//  CytrusSettingsController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 9/8/2024.
//

import Cytrus
import Foundation
import UIKit

class BlankSetting : AnyHashableSendable, @unchecked Sendable {}

class BoolSetting : AnyHashableSendable, @unchecked Sendable {
    var key, title: String
    var details: String?
    var value: Bool
    
    var delegate: SettingDelegate? = nil
    
    init(key: String, title: String, details: String? = nil, value: Bool, delegate: SettingDelegate? = nil) {
        self.key = key
        self.title = title
        self.details = details
        self.value = value
        self.delegate = delegate
    }
}

class InputNumberSetting : AnyHashableSendable, @unchecked Sendable {
    var key, title: String
    var details: String?
    var min, max, value: Double
    
    var delegate: SettingDelegate? = nil
    
    init(key: String, title: String, details: String? = nil, min: Double, max: Double, value: Double, delegate: SettingDelegate? = nil) {
        self.key = key
        self.title = title
        self.details = details
        self.min = min
        self.max = max
        self.value = value
        self.delegate = delegate
    }
}

class InputStringSetting : AnyHashableSendable, @unchecked Sendable {
    var key, title: String
    var details: String?
    var placeholder, value: String?
    let action: () -> Void
    
    var delegate: SettingDelegate? = nil
    
    init(key: String, title: String, details: String? = nil, placeholder: String? = nil, value: String? = nil,
         action: @escaping () -> Void, delegate: SettingDelegate? = nil) {
        self.key = key
        self.title = title
        self.details = details
        self.placeholder = placeholder
        self.value = value
        self.action = action
        self.delegate = delegate
    }
}

class StepperSetting : AnyHashableSendable, @unchecked Sendable {
    var key, title: String
    var details: String?
    var min, max, value: Double
    
    var delegate: SettingDelegate? = nil
    
    init(key: String, title: String, details: String? = nil, min: Double, max: Double, value: Double, delegate: SettingDelegate? = nil) {
        self.key = key
        self.title = title
        self.details = details
        self.min = min
        self.max = max
        self.value = value
        self.delegate = delegate
    }
}

class SelectionSetting : AnyHashableSendable, @unchecked Sendable {
    var key, title: String
    var details: String?
    var values: [String : Any]
    var selectedValue: Any? = nil
    
    var delegate: SettingDelegate? = nil
    
    init(key: String, title: String, details: String? = nil, values: [String : Any], selectedValue: Any? = nil, delegate: SettingDelegate? = nil) {
        self.key = key
        self.title = title
        self.details = details
        self.values = values
        self.selectedValue = selectedValue
        self.delegate = delegate
    }
}

protocol SettingDelegate {
    func didChangeSetting(at indexPath: IndexPath)
}

class CytrusSettingsController : UICollectionViewController {
    var dataSource: UICollectionViewDiffableDataSource<String, AnyHashableSendable>! = nil
    var snapshot: NSDiffableDataSourceSnapshot<String, AnyHashableSendable>! = nil
    
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
        
        let blankSettingsCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, AnyHashableSendable> { cell, indexPath, itemIdentifier in
            cell.contentConfiguration = UIListContentConfiguration.cell()
        }
        
        let headerCellRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            var contentConfiguration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            contentConfiguration.text = self.snapshot.sectionIdentifiers[indexPath.section]
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
        snapshot.appendSections([
            "Core",
            "Renderer",
            "Audio",
            "Networking"
        ])
        
        var coreItems = [
            InputNumberSetting(key: "cytrus.cpuClockPercentage",
                               title: "CPU Clock Percentage",
                               details: "Change the Clock Frequency of the emulated 3DS CPU\n\nUnderclocking can increase the performance of the game at the risk of freezing\n\nOverclocking may fix lag that happens on console, but also comes with the risk of freezing",
                               min: 5,
                               max: 200,
                               value: UserDefaults.standard.double(forKey: "cytrus.cpuClockPercentage"),
                               delegate: self),
            BoolSetting(key: "cytrus.new3DS",
                        title: "New 3DS",
                        details: "The system model that Cytrus will try to emulate",
                        value: UserDefaults.standard.bool(forKey: "cytrus.new3DS"),
                        delegate: self),
            BoolSetting(key: "cytrus.lleApplets",
                        title: "LLE Applets",
                        details: "Whether to use LLE system applets, if installed",
                        value: UserDefaults.standard.bool(forKey: "cytrus.lleApplets"),
                        delegate: self),
            SelectionSetting(key: "cytrus.regionValue",
                             title: "Console Region",
                             details: "The system region that Cytrus will use during emulation",
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
                             selectedValue: UserDefaults.standard.value(forKey: "cytrus.regionValue"),
                             delegate: self),
            
            BlankSetting(),
            
            SelectionSetting(key: "cytrus.logLevel",
                             title: "Log Level",
                             details: "Select the level of the information to be logged",
                             values: [
                                "Trace" : 0,
                                "Debug" : 1,
                                "Info" : 2,
                                "Warning" : 3,
                                "Error" : 4,
                                "Critical" : 5
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: "cytrus.logLevel"),
                             delegate: self)
        ]
        
        if AppStoreCheck.shared.debugging {
            coreItems.insert(BoolSetting(key: "cytrus.cpuJIT",
                                         title: "CPU JIT",
                                         value: UserDefaults.standard.bool(forKey: "cytrus.cpuJIT"),
                                         delegate: self),
                             at: 0)
        }
        
        snapshot.appendItems(coreItems, toSection: "Core")
        
        snapshot.appendItems([
            BoolSetting(key: "cytrus.customLayout",
                        title: "Custom Layout",
                        details: "Enabled the below custom layout values",
                        value: UserDefaults.standard.bool(forKey: "cytrus.customLayout"),
                        delegate: self),
            InputNumberSetting(key: "cytrus.customTopLeft",
                               title: "Custom Top Left",
                               min: 0,
                               max: 9999,
                               value: UserDefaults.standard.double(forKey: "cytrus.customTopLeft"),
                               delegate: self),
            InputNumberSetting(key: "cytrus.customTopTop",
                               title: "Custom Top Top",
                               min: 0,
                               max: 9999,
                               value: UserDefaults.standard.double(forKey: "cytrus.customTopTop"),
                               delegate: self),
            InputNumberSetting(key: "cytrus.customTopRight",
                               title: "Custom Top Right",
                               min: 0,
                               max: 9999,
                               value: UserDefaults.standard.double(forKey: "cytrus.customTopRight"),
                               delegate: self),
            InputNumberSetting(key: "cytrus.customTopBottom",
                               title: "Custom Top Bottom",
                               min: 0,
                               max: 9999,
                               value: UserDefaults.standard.double(forKey: "cytrus.customTopBottom"),
                               delegate: self),
            
            InputNumberSetting(key: "cytrus.customBottomLeft",
                               title: "Custom Bottom Left",
                               min: 0,
                               max: 9999,
                               value: UserDefaults.standard.double(forKey: "cytrus.customBottomLeft"),
                               delegate: self),
            InputNumberSetting(key: "cytrus.customBottomTop",
                               title: "Custom Bottom Top",
                               min: 0,
                               max: 9999,
                               value: UserDefaults.standard.double(forKey: "cytrus.customBottomTop"),
                               delegate: self),
            InputNumberSetting(key: "cytrus.customBottomRight",
                               title: "Custom Bottom Right",
                               min: 0,
                               max: 9999,
                               value: UserDefaults.standard.double(forKey: "cytrus.customBottomRight"),
                               delegate: self),
            InputNumberSetting(key: "cytrus.customBottomBottom",
                               title: "Custom Bottom Bottom",
                               min: 0,
                               max: 9999,
                               value: UserDefaults.standard.double(forKey: "cytrus.customBottomBottom"),
                               delegate: self),
            
            BlankSetting(),
            
            BoolSetting(key: "cytrus.spirvShaderGeneration",
                        title: "SPIRV Shader Generation",
                        details: "Emits the fragment shader used to emulate PICA using SPIR-V instead of GLSL",
                        value: UserDefaults.standard.bool(forKey: "cytrus.spirvShaderGeneration"),
                        delegate: self),
            BoolSetting(key: "cytrus.useAsyncShaderCompilation",
                        title: "Asynchronous Shader Compilation",
                        details: "Compiles shaders in the background to reduce stuttering during gameplay. When enabled expect temporary graphical glitches",
                        value: UserDefaults.standard.bool(forKey: "cytrus.useAsyncShaderCompilation"),
                        delegate: self),
            BoolSetting(key: "cytrus.useAsyncPresentation",
                        title: "Asynchronous Presentation",
                        value: UserDefaults.standard.bool(forKey: "cytrus.useAsyncPresentation"),
                        delegate: self),
            BoolSetting(key: "cytrus.useHardwareShaders",
                        title: "Hardware Shaders",
                        details: "Uses hardware to emulate 3DS shaders. When enabled, game performance will be significantly improved",
                        value: UserDefaults.standard.bool(forKey: "cytrus.useHardwareShaders"),
                        delegate: self),
            BoolSetting(key: "cytrus.useDiskShaderCache",
                        title: "Disk Shader Cache",
                        details: "Reduce stuttering by storing and loading generated shaders to disk. It cannot be used without Enabling Hardware Shader",
                        value: UserDefaults.standard.bool(forKey: "cytrus.useDiskShaderCache"),
                        delegate: self),
            BoolSetting(key: "cytrus.useShadersAccurateMul",
                        title: "Accurate Shader Multiplication",
                        details: "Uses more accurate multiplication in hardware shaders, which may fix some graphical bugs. When enabled, performance will be reduced",
                        value: UserDefaults.standard.bool(forKey: "cytrus.useShadersAccurateMul"),
                        delegate: self),
            BoolSetting(key: "cytrus.useNewVSync",
                        title: "New Vertical Sync",
                        details: "Synchronizes the game frame rate to the refresh rate of your device",
                        value: UserDefaults.standard.bool(forKey: "cytrus.useNewVSync"),
                        delegate: self),
            BoolSetting(key: "cytrus.useShaderJIT",
                        title: "Shader JIT",
                        details: "Whether to use the Just-In-Time (JIT) compiler for shader emulation",
                        value: UserDefaults.standard.bool(forKey: "cytrus.useShaderJIT"),
                        delegate: self),
            StepperSetting(key: "cytrus.resolutionFactor",
                           title: "Resolution Factor",
                           details: "Factor for the 3DS resolution",
                           min: 0,
                           max: 10,
                           value: UserDefaults.standard.double(forKey: "cytrus.resolutionFactor"),
                           delegate: self),
            SelectionSetting(key: "cytrus.textureFilter",
                             title: "Texture Filter",
                             details: "Enhances the visuals of games by applying a filter to textures. The supported filters are Anime4K Ultrafast, Bicubic, ScaleForce, and xBRZ freescale",
                             values: [
                                "None" : 0,
                                "Anime4K" : 1,
                                "Bicubic" : 2,
                                "ScaleForce" : 3,
                                "xBRZ" : 4,
                                "MMPX" : 5
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: "cytrus.textureFilter"),
                             delegate: self),
            SelectionSetting(key: "cytrus.textureSampling",
                             title: "Texture Sampling",
                             values: [
                                "Game Controlled" : 0,
                                "Nearest Neighbor" : 1,
                                "Linear" : 2
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: "cytrus.textureSampling"),
                             delegate: self),
            SelectionSetting(key: "cytrus.render3D",
                             title: "Render 3D",
                             details: "Whether and how Stereoscopic 3D should be rendered",
                             values: [
                                "Off" : 0,
                                "Side by Side" : 1,
                                "Anaglyph" : 2,
                                "Interlaced" : 3,
                                "ReverseInterlaced" : 4,
                                "CardboardVR" : 5
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: "cytrus.render3D"),
                             delegate: self),
            StepperSetting(key: "cytrus.factor3D",
                           title: "3D Factor",
                           details: "Specifies the value of the 3D slider. This should be set to higher than 0% when Stereoscopic 3D is enabled",
                           min: 0,
                           max: 100,
                           value: UserDefaults.standard.double(forKey: "cytrus.factor3D"),
                           delegate: self),
            SelectionSetting(key: "cytrus.monoRender",
                             title: "Mono Render",
                             details: "Change Default Eye to Render When in Monoscopic Mode",
                             values: [
                                "Left Eye" : 0,
                                "Right Eye" : 1
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: "cytrus.monoRender"),
                             delegate: self),
            BoolSetting(key: "cytrus.preloadTextures",
                        title: "Preload textures",
                        details: "Loads all custom textures into memory. This feature can use a lot of memory",
                        value: UserDefaults.standard.bool(forKey: "cytrus.preloadTextures"),
                        delegate: self)
        ], toSection: "Renderer")
        
        snapshot.appendItems([
            BoolSetting(key: "cytrus.audioMuted",
                        title: "Audio Muted",
                        value: UserDefaults.standard.bool(forKey: "cytrus.audioMuted")),
            SelectionSetting(key: "cytrus.audioEmulation",
                             title: "Audio Emulation",
                             values: [
                                "HLE" : 0,
                                "LLE" : 1,
                                "LLE (Multithreaded)" : 2
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: "cytrus.audioEmulation"),
                             delegate: self),
            BoolSetting(key: "cytrus.audioStretching",
                        title: "Audio Stretching",
                        details: "Stretches audio to reduce stuttering. When enabled, increases audio latency and slightly reduces performance",
                        value: UserDefaults.standard.bool(forKey: "cytrus.audioStretching")),
            BoolSetting(key: "cytrus.realtimeAudio",
                        title: "Realtime Audio",
                        value: UserDefaults.standard.bool(forKey: "cytrus.realtimeAudio")),
            SelectionSetting(key: "cytrus.outputType",
                             title: "Output Type",
                             values: [
                                "Automatic" : 0,
                                "None" : 1,
                                "OpenAL" : 2,
                                "SDL2" : 3
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: "cytrus.outputType"),
                             delegate: self),
            SelectionSetting(key: "cytrus.inputType",
                             title: "Input Type",
                             values: [
                                "Automatic" : 0,
                                "None" : 1,
                                "Static" : 2,
                                "OpenAL" : 3
                             ],
                             selectedValue: UserDefaults.standard.value(forKey: "cytrus.inputType"),
                             delegate: self)
        ], toSection: "Audio")
        
        snapshot.appendItems([
            InputStringSetting(key: "cytrus.webAPIURL",
                               title: "Web API URL",
                               details: "Enter the Web API URL that Cytrus will use when searching for rooms",
                               placeholder: "http(s)://address:port",
                               value: UserDefaults.standard.string(forKey: "cytrus.webAPIURL"),
                               action: {
                                   MultiplayerManager.shared().updateWebAPIURL()
                               },
                               delegate: self)
        ], toSection: "Networking")
        
        Task {
            await dataSource.apply(snapshot)
        }
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
