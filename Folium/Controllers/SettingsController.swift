//
//  SettingsController.swift
//  Folium
//
//  Created by Jarrod Norwell on 3/6/2026.
//

import Mandarine
import SettingsKit
import UIKit

class SettingsController : UICollectionViewController {
    var selectedSnapshot: SelectedSnapshot = .application {
        didSet {
            guard let dataSource: UICollectionViewDiffableDataSource<SettingsHeaders, BaseSetting> else {
                return
            }
            
            navigationItem.largeSubtitle = selectedSnapshot.string
            navigationItem.subtitle = navigationItem.largeSubtitle
            
            Task {
                switch selectedSnapshot {
                case .application:
                    guard let applicationSnapshot else {
                        return
                    }
                    
                    await dataSource.apply(applicationSnapshot)
                case .cytrus:
                    guard let cytrusSnapshot else {
                        return
                    }
                    
                    await dataSource.apply(cytrusSnapshot)
                case .grape:
                    guard let grapeSnapshot else {
                        return
                    }
                    
                    await dataSource.apply(grapeSnapshot)
                case .mandarine:
                    guard let mandarineSnapshot else {
                        return
                    }
                    
                    await dataSource.apply(mandarineSnapshot)
                case .tomato:
                    guard let tomatoSnapshot else {
                        return
                    }
                    
                    await dataSource.apply(tomatoSnapshot)
                default:
                    break
                }
            }
        }
    }
    
    var dataSource: UICollectionViewDiffableDataSource<SettingsHeaders, BaseSetting>? = nil
    
    var applicationSnapshot: NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>? = nil
    var cytrusSnapshot: NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>? = nil
    var grapeSnapshot: NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>? = nil
    var mandarineSnapshot: NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>? = nil
    var tomatoSnapshot: NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController {
            navigationController.navigationBar.prefersLargeTitles = true
        }
        
        navigationItem.largeTitle = "Settings"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: UIMenu(children: [
            UIMenu(options: .displayInline, children: [
                UIAction(title: "Application", image: UIImage(systemName: "app.grid")) { action in
                    self.selectedSnapshot = .application
                }
            ]),
            UIMenu(title: "Coleco", image: UIImage(systemName: "cpu"), children: [
                UIAction(title: "CV", subtitle: "ColecoVision", attributes: .disabled) { action in }
            ]),
            UIMenu(title: "Nintendo", image: UIImage(systemName: "cpu"), children: [
                UIAction(title: "3DS", subtitle: "Nintendo 3DS") { action in
                    self.selectedSnapshot = .cytrus
                },
                UIAction(title: "DS/DSi", subtitle: "Nintendo DS/DSi") { action in
                    self.selectedSnapshot = .grape
                },
                UIAction(title: "GBA", subtitle: "Game Boy Advance") { action in
                    self.selectedSnapshot = .tomato
                },
                UIAction(title: "NES", subtitle: "Nintendo Entertainment System", attributes: .disabled) { action in },
                UIAction(title: "SNES", subtitle: "Super Nintendo Entertainment System", attributes: .disabled) { action in }
            ]),
            UIMenu(title: "PlayStation", image: UIImage(systemName: "cpu"), children: [
                UIAction(title: "PS1", subtitle: "PlayStation 1") { action in
                    self.selectedSnapshot = .mandarine
                }
            ]),
            UIMenu(title: "SEGA", image: UIImage(systemName: "cpu"), children: [
                UIAction(title: "GEN/MD", subtitle: "SEGA Genesis/Mega Drive", attributes: .disabled) { action in }
            ])
        ]))
        navigationItem.title = navigationItem.largeTitle
        navigationItem.style = .browser
        view.backgroundColor = .systemBackground
        
        var configuration: UICollectionLayoutListConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .supplementary
        configuration.trailingSwipeActionsConfigurationProvider = { indexPath in
            guard let dataSource = self.dataSource, let item: BaseSetting = dataSource.itemIdentifier(for: indexPath) else {
                return UISwipeActionsConfiguration()
            }
            
            let informationContextualAction: UIContextualAction = UIContextualAction(style: .normal, title: nil, handler: { action, view, performed in
                let alertController: UIAlertController = UIAlertController(title: item.title, message: item.details, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel) { action in
                    performed(true)
                })
                self.present(alertController, animated: true)
            })
            informationContextualAction.backgroundColor = .systemBlue
            informationContextualAction.image = UIImage(systemName: "info")
            
            return UISwipeActionsConfiguration(actions: [
                informationContextualAction
            ])
        }
        
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
        
        let blankSettingsCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, BlankSetting> { cell, indexPath, itemIdentifier in
            cell.contentConfiguration = UIListContentConfiguration.cell()
        }
        
        let headerCellRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            var contentConfiguration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            
            if let dataSource = self.dataSource {
                let snapshot = dataSource.snapshot()
                
                contentConfiguration.text = snapshot.sectionIdentifiers[indexPath.section].header.text
                contentConfiguration.secondaryText = snapshot.sectionIdentifiers[indexPath.section].header.secondaryText
            }
            
            contentConfiguration.secondaryTextProperties.color = .secondaryLabel
            supplementaryView.contentConfiguration = contentConfiguration
        }
        
        let boolCell: UICollectionView.CellRegistration<UICollectionViewListCell, BoolSetting> = CellManager.Settings.boolCell
        let inputNumberCell: UICollectionView.CellRegistration<UICollectionViewListCell, InputNumberSetting> = CellManager.Settings.inputNumberCell
        let inputStringCell: UICollectionView.CellRegistration<UICollectionViewListCell, InputStringSetting> = CellManager.Settings.inputStringCell
        let segmentedCell: UICollectionView.CellRegistration<UICollectionViewListCell, SegmentedSetting> = CellManager.Settings.segmentedCell(self)
        let selectionCell: UICollectionView.CellRegistration<UICollectionViewListCell, SelectionSetting> = CellManager.Settings.selectionCell
        let stepperCell: UICollectionView.CellRegistration<UICollectionViewListCell, StepperSetting> = CellManager.Settings.stepperCell
        
        dataSource = UICollectionViewDiffableDataSource<SettingsHeaders, BaseSetting>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case let blankSetting as BlankSetting:
                collectionView.dequeueConfiguredReusableCell(using: blankSettingsCellRegistration, for: indexPath, item: blankSetting)
            case let boolSetting as BoolSetting:
                collectionView.dequeueConfiguredReusableCell(using: boolCell, for: indexPath, item: boolSetting)
            case let inputNumberSetting as InputNumberSetting:
                collectionView.dequeueConfiguredReusableCell(using: inputNumberCell, for: indexPath, item: inputNumberSetting)
            case let inputStringSetting as InputStringSetting:
                collectionView.dequeueConfiguredReusableCell(using: inputStringCell, for: indexPath, item: inputStringSetting)
            case let segmentedSetting as SegmentedSetting:
                collectionView.dequeueConfiguredReusableCell(using: segmentedCell, for: indexPath, item: segmentedSetting)
            case let stepperSetting as StepperSetting:
                collectionView.dequeueConfiguredReusableCell(using: stepperCell, for: indexPath, item: stepperSetting)
            case let selectionSetting as SelectionSetting:
                collectionView.dequeueConfiguredReusableCell(using: selectionCell, for: indexPath, item: selectionSetting)
            default:
                nil
            }
        }
        
        guard let dataSource else {
            return
        }
        
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerCellRegistration, for: indexPath)
        }
        
        applicationSnapshot = NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>()
        cytrusSnapshot = NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>()
        grapeSnapshot = NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>()
        mandarineSnapshot = NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>()
        tomatoSnapshot = NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>()
        guard var applicationSnapshot, var cytrusSnapshot, var grapeSnapshot, var mandarineSnapshot, var tomatoSnapshot else {
            return
        }
        
        generateSnapshot(for: &applicationSnapshot, with: [.general], type: ApplicationSettingsItems.self)
        self.applicationSnapshot = applicationSnapshot
        
        generateSnapshot(for: &cytrusSnapshot, with: [
            .coreGeneral,
            .debuggingGeneral,
            .graphics3D,
            .graphicsGeneral,
            .graphicsResolution,
            .graphicsShader,
            .soundGeneral,
            .systemGeneral,
            .systemRegion
        ], type: CytrusSettingsItems.self)
        self.cytrusSnapshot = cytrusSnapshot
        
        generateSnapshot(for: &grapeSnapshot, with: [.coreGeneral], type: GrapeSettingsItems.self)
        self.grapeSnapshot = grapeSnapshot
        
        generateSnapshot(for: &mandarineSnapshot, with: [
            .graphicsGeneral,
            .graphicsResolution,
            .soundGeneral,
            .systemGeneral
        ], type: MandarineSettingsItems.self)
        self.mandarineSnapshot = mandarineSnapshot
        
        generateSnapshot(for: &tomatoSnapshot, with: [
            .cartridgeGeneral,
            .general,
            .graphicsGeneral,
            .soundGeneral
        ], type: TomatoSettingsItems.self)
        self.tomatoSnapshot = tomatoSnapshot
        
        Task {
            navigationItem.largeSubtitle = selectedSnapshot.string
            navigationItem.subtitle = navigationItem.largeSubtitle
            
            switch selectedSnapshot {
            case .application:
                await dataSource.apply(applicationSnapshot)
            case .cytrus:
                await dataSource.apply(cytrusSnapshot)
            case .grape:
                await dataSource.apply(grapeSnapshot)
            case .kiwi:
                break
            case .mandarine:
                await dataSource.apply(mandarineSnapshot)
            case .tomato:
                await dataSource.apply(tomatoSnapshot)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tabBarController {
            tabBarController.setTabBarHidden(false, animated: true)
        }
    }
    
    func generateSnapshot<T>(for snapshot: inout NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>, with headers: [SettingsHeaders], type: T.Type) {
        snapshot.appendSections(headers)
        
        snapshot.sectionIdentifiers.forEach { header in
            switch T.self {
            case is ApplicationSettingsItems.Type:
                snapshot.appendItems(ApplicationSettingsItems.settings(header).map { item in
                    item.setting(self)
                }, toSection: header)
            case is CytrusSettingsItems.Type:
                snapshot.appendItems(CytrusSettingsItems.settings(header).map { item in
                    item.setting(self)
                }, toSection: header)
            case is GrapeSettingsItems.Type:
                snapshot.appendItems(GrapeSettingsItems.settings(header).map { item in
                    item.setting(self)
                }, toSection: header)
            case is MandarineSettingsItems.Type:
                snapshot.appendItems(MandarineSettingsItems.settings(header).map { item in
                    item.setting(self)
                }, toSection: header)
            case is TomatoSettingsItems.Type:
                snapshot.appendItems(TomatoSettingsItems.settings(header).map { item in
                    item.setting(self)
                }, toSection: header)
            default:
                break
            }
        }
    }
}

extension SettingsController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let dataSource else {
            return
        }
        
        switch dataSource.itemIdentifier(for: indexPath) {
        case let inputSetting as InputNumberSetting:
            if !inputSetting.isEnabled {
                return
            }
            
            let alertController = UIAlertController(title: inputSetting.title,
                                                    message: "Min: \(Int(inputSetting.min)), Max: \(Int(inputSetting.max))",
                                                    preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.keyboardType = .numberPad
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
            alertController.addTextField { textField in
                textField.placeholder = inputSetting.placeholder
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

extension SettingsController : SettingDelegate {
    func didChangeSetting(at indexPath: IndexPath) {
        guard let dataSource: UICollectionViewDiffableDataSource<SettingsHeaders, BaseSetting> else {
            return
        }
        
        guard let sectionIdentifier: SettingsHeaders = dataSource.sectionIdentifier(for: indexPath.section) else {
            return
        }
        
        var snapshot = dataSource.snapshot()
        let item = snapshot.itemIdentifiers(inSection: sectionIdentifier)[indexPath.item]
        
        guard let tabController: TabController = tabBarController as? TabController else {
            return
        }
        
        switch selectedSnapshot {
        case .application:
            break
        case .cytrus:
            break
        case .grape:
            break
        case .kiwi:
            break
        case .mandarine:
            guard let mandarineGame: MandarineGame = tabController.game as? MandarineGame else {
                return
            }
            
            Task {
                switch item {
                case let boolSetting as BoolSetting:
                    boolSetting.value = UserDefaults.standard.bool(forKey: boolSetting.key)
                    await mandarineGame.mandarineSystem.setSetting(setting: mandarine.SETTING.SOUND_ENABLED, value: boolSetting.value)
                default:
                    break
                }
            }
        case .tomato:
            break
        }
        
        snapshot.reloadItems([item])
        Task {
            await dataSource.apply(snapshot)
        }
    }
}
