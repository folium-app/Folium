//
//  GrapeSettingsController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 6/9/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation
import Grape
import NewGrape
import SettingsKit
import UIKit

enum GrapeSettingsHeaders : String, CaseIterable {
    case global = "Global"
    case melonds = "MelonDS"
    case noods = "NooDS"
    
    var header: SettingHeader {
        switch self {
        case .melonds,
                .noods: .init(text: rawValue)
        case .global: .init(text: rawValue,
                            secondaryText: "Settings used by both MelonDS and NooDS")
        }
    }
    
    static var allHeaders: [SettingHeader] { allCases.map { $0.header } }
}

enum GrapeSettingsItems : String, CaseIterable {
    // Global
    case directBoot = "grape.directBoot"
    case resolutionFactor = "grape.resolutionFactor"
    
    // MelonDS
    case dsiMode = "grape.dsiMode"
    
    // NooDS
    case threaded2D = "grape.threaded2D"
    case threaded3D = "grape.threaded3D"
    
    var title: String {
        switch self {
        case .directBoot: "Direct Boot"
        case .resolutionFactor: "Resolution Factor"
        case .dsiMode: "DSi Mode"
        case .threaded2D: "Threaded 2D"
        case .threaded3D: "Threaded 3D"
        }
    }
    
    func setting(_ delegate: SettingDelegate? = nil) -> BaseSetting {
        switch self {
        case .directBoot,
                .dsiMode,
                .threaded2D,
                .threaded3D:
            BoolSetting(key: rawValue,
                        title: title,
                        details: nil,
                        value: UserDefaults.standard.bool(forKey: rawValue),
                        delegate: delegate)
        case .resolutionFactor:
            StepperSetting(key: rawValue,
                                title: title,
                                details: nil,
                                min: 1,
                                max: 4,
                                value: UserDefaults.standard.double(forKey: rawValue),
                                delegate: delegate)
        }
    }
    
    static func settings(_ header: GrapeSettingsHeaders) -> [GrapeSettingsItems] {
        return switch header {
        case .global:
            [
                .directBoot,
                .resolutionFactor
            ]
        case .melonds:
            [
                .dsiMode
            ]
        case .noods:
            [
                .threaded2D,
                .threaded3D
            ]
        }
    }
}

class GrapeSettingsController : UICollectionViewController {
    var dataSource: UICollectionViewDiffableDataSource<GrapeSettingsHeaders, AHS>! = nil
    var snapshot: NSDiffableDataSourceSnapshot<GrapeSettingsHeaders, AHS>! = nil
    
    let settingsKit = SettingsKit.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setLeftBarButton(.init(systemItem: .close, primaryAction: .init(handler: { _ in
            self.dismiss(animated: true)
        })), animated: true)
        prefersLargeTitles(true)
        title = "Grape"
        
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
        
        let headerCellRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            var contentConfiguration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            contentConfiguration.text = self.snapshot.sectionIdentifiers[indexPath.section].header.text
            contentConfiguration.secondaryText = self.snapshot.sectionIdentifiers[indexPath.section].header.secondaryText
            contentConfiguration.secondaryTextProperties.color = .secondaryLabel
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
        snapshot.appendSections(GrapeSettingsHeaders.allCases)
        snapshot.sectionIdentifiers.forEach { header in
            snapshot.appendItems(GrapeSettingsItems.settings(header).map { $0.setting(self) }, toSection: header)
        }
        
        Task { await dataSource.apply(snapshot) }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension GrapeSettingsController : SettingDelegate {
    func didChangeSetting(at indexPath: IndexPath) {
        Grape.shared.updateSettings()
        NewGrape.shared.updateSettings()
        
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
