//
//  CytrusSettingsController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 9/8/2024.
//

import Foundation
import UIKit

class BoolSetting : AnyHashableSendable, @unchecked Sendable {
    var key, title: String
    var value: Bool
    
    var delegate: SettingDelegate? = nil
    
    init(key: String, title: String, value: Bool, delegate: SettingDelegate? = nil) {
        self.key = key
        self.title = title
        self.value = value
        self.delegate = delegate
    }
}

class StepperSetting : AnyHashableSendable, @unchecked Sendable {
    var key, title: String
    var min, max, value: Double
    
    var delegate: SettingDelegate? = nil
    
    init(key: String, title: String, min: Double, max: Double, value: Double, delegate: SettingDelegate? = nil) {
        self.key = key
        self.title = title
        self.min = min
        self.max = max
        self.value = value
        self.delegate = delegate
    }
}

class SelectionSetting : AnyHashableSendable, @unchecked Sendable {
    var key, title: String
    var values: [String : Any]
    var selectedValue: Any? = nil
    
    var delegate: SettingDelegate? = nil
    
    init(key: String, title: String, values: [String : Any], selectedValue: Any? = nil, delegate: SettingDelegate? = nil) {
        self.key = key
        self.title = title
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
        navigationItem.setLeftBarButton(.init(systemItem: .cancel, primaryAction: .init(handler: { _ in
            self.dismiss(animated: true)
        })), animated: true)
        prefersLargeTitles(true)
        title = "Cytrus Settings"
        
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
            
            cell.accessories = [
                .customView(configuration: .init(customView: toggle, placement: .trailing()))
            ]
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
            
            cell.accessories = [
                .customView(configuration: .init(customView: stepper, placement: .trailing(), reservedLayoutWidth: .actual))
            ]
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
            
            cell.accessories = [
                .label(text: title),
                .popUpMenu(UIMenu(children: children.sorted(by: { $0.title < $1.title })))
            ]
        }
        
        let headerCellRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            var contentConfiguration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            contentConfiguration.text = self.snapshot.sectionIdentifiers[indexPath.section]
            supplementaryView.contentConfiguration = contentConfiguration
        }
        
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case let boolSetting as BoolSetting:
                collectionView.dequeueConfiguredReusableCell(using: boolCellRegistration, for: indexPath, item: boolSetting)
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
            "Renderer"
        ])
        
        snapshot.appendItems([
            StepperSetting(key: "cytrus.v1.7.cpuClockPercentage",
                           title: "CPU Clock Percentage",
                           min: 5,
                           max: 200,
                           value: UserDefaults.standard.double(forKey: "cytrus.v1.7.cpuClockPercentage"),
                           delegate: self),
            BoolSetting(key: "cytrus.v1.7.useNew3DS",
                        title: "New 3DS",
                        value: UserDefaults.standard.bool(forKey: "cytrus.v1.7.useNew3DS"),
                        delegate: self),
            // SelectionSetting(key: "",
            //                  title: "LLE Applets",
            //                  values: [
            //                     ""
            //                  ], delegate: self),
            SelectionSetting(key: "cytrus.v1.7.regionValue",
                             title: "Console Region",
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
                             selectedValue: UserDefaults.standard.value(forKey: "cytrus.v1.7.regionValue"),
                             delegate: self)
        ], toSection: "Core")
        
        snapshot.appendItems([
            BoolSetting(key: "cytrus.v1.7.spirvShaderGeneration",
                        title: "SPIRV Shader Generation",
                        value: UserDefaults.standard.bool(forKey: "cytrus.v1.7.spirvShaderGeneration"),
                        delegate: self),
            BoolSetting(key: "cytrus.v1.7.useAsyncShaderCompilation",
                        title: "Asynchronous Shader Compilation",
                        value: UserDefaults.standard.bool(forKey: "cytrus.v1.7.useAsyncShaderCompilation"),
                        delegate: self),
            BoolSetting(key: "cytrus.v1.7.useAsyncPresentation",
                        title: "Asynchronous Presentation",
                        value: UserDefaults.standard.bool(forKey: "cytrus.v1.7.useAsyncPresentation"),
                        delegate: self),
            BoolSetting(key: "cytrus.v1.7.useHardwareShaders",
                        title: "Hardware Shaders",
                        value: UserDefaults.standard.bool(forKey: "cytrus.v1.7.useHardwareShaders"),
                        delegate: self),
            BoolSetting(key: "cytrus.v1.7.useDiskShaderCache",
                        title: "Disk Shader Cache",
                        value: UserDefaults.standard.bool(forKey: "cytrus.v1.7.useDiskShaderCache"),
                        delegate: self),
            BoolSetting(key: "cytrus.v1.7.useShadersAccurateMul",
                        title: "Accurate Shader Multiplication",
                        value: UserDefaults.standard.bool(forKey: "cytrus.v1.7.useShadersAccurateMul"),
                        delegate: self),
            BoolSetting(key: "cytrus.v1.7.useNewVSync",
                        title: "New Vertical Sync",
                        value: UserDefaults.standard.bool(forKey: "cytrus.v1.7.useNewVSync"),
                        delegate: self)
        ], toSection: "Renderer")
        
        Task {
            await dataSource.apply(snapshot)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension CytrusSettingsController : SettingDelegate {
    func didChangeSetting(at indexPath: IndexPath) {
        guard let sectionIdentifier = dataSource.sectionIdentifier(for: indexPath.section) else {
            return
        }
        
        var snapshot = dataSource.snapshot()
        let item = snapshot.itemIdentifiers(inSection: sectionIdentifier)[indexPath.item]
        
        switch item {
        case let boolSetting as BoolSetting:
            boolSetting.value = UserDefaults.standard.bool(forKey: boolSetting.key)
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
