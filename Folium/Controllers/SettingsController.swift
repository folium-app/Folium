//
//  SettingsController.swift
//  Folium
//
//  Created by Jarrod Norwell on 3/6/2026.
//

import SettingsKit
import StoreKit
import UIKit

import Cytrus
import Durian
import Grape
import Kiwi
import Mandarine
import Tomato

class SettingsController : UICollectionViewController {
    var selectedSnapshot: SelectedSnapshot = .application {
        didSet {
            guard let dataSource: UICollectionViewDiffableDataSource<SettingsHeaders, BaseSetting> else {
                return
            }
            
            if #available(iOS 26.0, *) {
                navigationItem.largeSubtitle = selectedSnapshot.system?.console ?? selectedSnapshot.string
                navigationItem.subtitle = navigationItem.largeSubtitle
            }
            
            Task {
                switch selectedSnapshot {
                case .application:
                    guard let applicationSnapshot else {
                        return
                    }
                    
                    await dataSource.apply(applicationSnapshot)
                case .durian:
                    guard let durianSnapshot else {
                        return
                    }
                    
                    await dataSource.apply(durianSnapshot)
                case .grape:
                    guard let grapeSnapshot else {
                        return
                    }
                    
                    await dataSource.apply(grapeSnapshot)
                case .kiwi:
                    guard let kiwiSnapshot else {
                        return
                    }
                    
                    await dataSource.apply(kiwiSnapshot)
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
    var durianSnapshot: NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>? = nil
    var grapeSnapshot: NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>? = nil
    var kiwiSnapshot: NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>? = nil
    var mandarineSnapshot: NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>? = nil
    var tomatoSnapshot: NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController {
            navigationController.navigationBar.prefersLargeTitles = true
        }
        
        if #available(iOS 26.0, *) {
            navigationItem.largeTitle = "Settings"
            navigationItem.title = navigationItem.largeTitle
        } else {
            navigationItem.title = "Settings"
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: UIMenu(children: [
            UIMenu(options: .displayInline, children: [
                UIAction(title: "Application", image: UIImage(systemName: "app.grid")) { action in
                    self.selectedSnapshot = .application
                }
            ]),
            UIMenu(title: "Bandai", image: UIImage(systemName: "cpu"), children: [
                UIAction(title: "WonderSwan", subtitle: "+ WonderSwan Color") { action in
                    self.selectedSnapshot = .durian
                }
            ]),
            UIMenu(title: "Coleco", image: UIImage(systemName: "cpu"), children: [
                UIAction(title: "ColecoVision", attributes: .disabled) { action in
                    self.selectedSnapshot = .cherry
                }
            ]),
            UIMenu(title: "Nintendo", image: UIImage(systemName: "cpu"), children: [
                UIAction(title: "3DS", subtitle: "+ New 3DS", attributes: .disabled) { action in
                    self.selectedSnapshot = .cytrus
                },
                UIAction(title: "DS", subtitle: "+ DSi") { action in
                    self.selectedSnapshot = .grape
                },
                UIAction(title: "Game Boy", subtitle: "+ Game Boy Color") { action in
                    self.selectedSnapshot = .kiwi
                },
                UIAction(title: "Game Boy Advance") { action in
                    self.selectedSnapshot = .tomato
                },
                UIAction(title: "Nintendo Entertainment System", attributes: .disabled) { action in
                    self.selectedSnapshot = .mango
                },
                UIAction(title: "Super Nintendo Entertainment System", attributes: .disabled) { action in
                    self.selectedSnapshot = .lychee
                }
            ]),
            UIMenu(title: "SEGA", image: UIImage(systemName: "cpu"), children: [
                UIAction(title: "Genesis", subtitle: "+ Mega Drive", attributes: .disabled) { action in
                    self.selectedSnapshot = .plum
                }
            ]),
            UIMenu(title: "Sony", image: UIImage(systemName: "cpu"), children: [
                UIAction(title: "PlayStation 1", attributes: .disabled) { action in
                    self.selectedSnapshot = .mandarine
                }
            ])
        ]))
        navigationItem.style = .browser
        view.backgroundColor = .systemBackground
        
        if #available(iOS 26.0, *) {
            collectionView.bottomEdgeEffect.style = .soft
            collectionView.topEdgeEffect.style = .soft
        }
        
        var configuration: UICollectionLayoutListConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .supplementary
        configuration.trailingSwipeActionsConfigurationProvider = { indexPath in
            guard let dataSource = self.dataSource, let item: BaseSetting = dataSource.itemIdentifier(for: indexPath), !item.details.isNil else {
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
        let tapCell: UICollectionView.CellRegistration<UICollectionViewListCell, TapSetting> = CellManager.Settings.tapCell
        
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
            case let tapSetting as TapSetting:
                collectionView.dequeueConfiguredReusableCell(using: tapCell, for: indexPath, item: tapSetting)
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
        
        // if let defaultSystemForLibrary: String = UserDefaults.standard.string(forKey: "folium.defaultSystemForLibrary"),
        //    let ss: SelectedSnapshot = SelectedSnapshot.from(string: defaultSystemForLibrary) {
        //     if [.application, .kiwi, .tomato].contains(ss) {
        //         selectedSnapshot = ss
        //     }
        // }
        
        populateSettings()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("extraFeaturesStatusDidChange"),
                                               object: nil,
                                               queue: .main) { notification in
            Task {
                await self.populateSettings()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 18.0, *), let tabBarController {
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
            case is DurianSettingsItems.Type:
                snapshot.appendItems(DurianSettingsItems.settings(header).map { item in
                    item.setting(self)
                }, toSection: header)
            case is GrapeSettingsItems.Type:
                snapshot.appendItems(GrapeSettingsItems.settings(header).map { item in
                    item.setting(self)
                }, toSection: header)
            case is KiwiSettingsItems.Type:
                snapshot.appendItems(KiwiSettingsItems.settings(header).map { item in
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
    
    func populateSettings() {
        guard let dataSource else {
            return
        }
        
        applicationSnapshot = NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>()
        cytrusSnapshot = NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>()
        durianSnapshot = NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>()
        grapeSnapshot = NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>()
        kiwiSnapshot = NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>()
        mandarineSnapshot = NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>()
        tomatoSnapshot = NSDiffableDataSourceSnapshot<SettingsHeaders, BaseSetting>()
        guard var applicationSnapshot, var cytrusSnapshot, var durianSnapshot, var grapeSnapshot,
              var kiwiSnapshot, var mandarineSnapshot, var tomatoSnapshot else {
            return
        }
        
        generateSnapshot(for: &applicationSnapshot, with: [
            .premiumExtraFeatures,
            .general,
            .libraryGeneral
        ], type: ApplicationSettingsItems.self)
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
        
        generateSnapshot(for: &durianSnapshot, with: [
            .coreGeneral,
            .graphicsGeneral
        ], type: DurianSettingsItems.self)
        self.durianSnapshot = durianSnapshot
        
        generateSnapshot(for: &grapeSnapshot, with: [
            .general,
            .coreGeneral
        ], type: GrapeSettingsItems.self)
        self.grapeSnapshot = grapeSnapshot
        
        generateSnapshot(for: &kiwiSnapshot, with: [
            .graphicsGeneral
        ], type: KiwiSettingsItems.self)
        self.kiwiSnapshot = kiwiSnapshot
        
        generateSnapshot(for: &mandarineSnapshot, with: [
            .debuggingGeneral,
            .graphicsGeneral,
            .graphicsResolution,
            .soundGeneral,
            .systemGeneral
        ], type: MandarineSettingsItems.self)
        self.mandarineSnapshot = mandarineSnapshot
        
        generateSnapshot(for: &tomatoSnapshot, with: [
            .general,
            .graphicsGeneral
        ], type: TomatoSettingsItems.self)
        self.tomatoSnapshot = tomatoSnapshot
        
        Task {
            if #available(iOS 26.0, *) {
                navigationItem.largeSubtitle = selectedSnapshot.system?.console ?? selectedSnapshot.string
                navigationItem.subtitle = navigationItem.largeSubtitle
            }
            
            switch selectedSnapshot {
            case .application:
                await dataSource.apply(applicationSnapshot)
            case .cherry:
                break
            case .cytrus:
                // await dataSource.apply(cytrusSnapshot)
                break
            case .durian:
                await dataSource.apply(durianSnapshot)
            case .grape:
                await dataSource.apply(grapeSnapshot)
            case .kiwi:
                await dataSource.apply(kiwiSnapshot)
            case .lychee:
                break
            case .mandarine:
                // await dataSource.apply(mandarineSnapshot)
                break
            case .mango:
                break
            case .plum:
                break
            case .tomato:
                await dataSource.apply(tomatoSnapshot)
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
        case let tapSetting as TapSetting:
            tapSetting.handler(self)
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
            Task {
                switch item {
                case let boolSetting as BoolSetting:
                    boolSetting.value = UserDefaults.standard.bool(forKey: boolSetting.key)
                case let selectionSetting as SelectionSetting:
                    selectionSetting.selectedValue = UserDefaults.standard.value(forKey: selectionSetting.key)
                default:
                    break
                }
            }
        case .cherry:
            break
        case .cytrus:
            Task {
                switch item {
                case let boolSetting as BoolSetting:
                    boolSetting.value = UserDefaults.standard.bool(forKey: boolSetting.key)
                    
                    guard let setting: cytrus.SETTING = [
                        CytrusSettingsItems.lleApplets.rawValue : cytrus.SETTING.LLE_APPLETS,
                        CytrusSettingsItems.deterministicAsyncOperations.rawValue : cytrus.SETTING.DETERMINISTIC_ASYNC_OPERATIONS,
                        CytrusSettingsItems.requiredOnlineLLEModules.rawValue : cytrus.SETTING.REQUIRED_ONLINE_LLE_MODULES,
                        CytrusSettingsItems.regionFreePatch.rawValue : cytrus.SETTING.REGION_PREF_PATCH,
                        CytrusSettingsItems.swapEyes3D.rawValue : cytrus.SETTING.SWAP_EYES_3D,
                        CytrusSettingsItems.spirvShaderGen.rawValue : cytrus.SETTING.SPIRV_SHADER_GEN,
                        CytrusSettingsItems.spirvOptimizer.rawValue : cytrus.SETTING.SPIRV_OPTIMIZER,
                        CytrusSettingsItems.asyncShaderCompilation.rawValue : cytrus.SETTING.ASYNC_SHADER_COMPILATION,
                        CytrusSettingsItems.asyncPresentation.rawValue : cytrus.SETTING.ASYNC_PRESENTATION,
                        CytrusSettingsItems.diskShaderCache.rawValue : cytrus.SETTING.DISK_SHADER_CACHE,
                        CytrusSettingsItems.vsync.rawValue : cytrus.SETTING.VSYNC,
                        CytrusSettingsItems.shaderAccurateMultiplication.rawValue : cytrus.SETTING.SHADER_ACCURATE_MULTIPLICATION,
                        CytrusSettingsItems.soundStretching.rawValue : cytrus.SETTING.SOUND_STRETCHING,
                        CytrusSettingsItems.realtimeSound.rawValue : cytrus.SETTING.REALTIME_SOUND
                    ][boolSetting.key] else {
                        return
                    }
                    
                    await tabController.gamesManager.cytrusSystem.setSetting(setting: setting, value: boolSetting.value)
                case let inputNumberSetting as InputNumberSetting:
                    inputNumberSetting.value = UserDefaults.standard.double(forKey: inputNumberSetting.key)
                case let inputStringSetting as InputStringSetting:
                    inputStringSetting.value = UserDefaults.standard.string(forKey: inputStringSetting.key)
                case let segmentedSetting as SegmentedSetting:
                    segmentedSetting.selectedValue = UserDefaults.standard.value(forKey: segmentedSetting.key)
                case let stepperSetting as StepperSetting:
                    stepperSetting.value = UserDefaults.standard.double(forKey: stepperSetting.key)
                case let selectionSetting as SelectionSetting:
                    selectionSetting.selectedValue = UserDefaults.standard.value(forKey: selectionSetting.key)
                default:
                    break
                }
            }
        case .durian:
            Task {
                switch item {
                case let boolSetting as BoolSetting:
                    boolSetting.value = UserDefaults.standard.bool(forKey: boolSetting.key)
                    
                    guard let setting: durian.SETTING = [
                        DurianSettingsItems.adjustColours.rawValue : durian.SETTING.ADJUST_COLOURS,
                        DurianSettingsItems.blendFrames.rawValue : durian.SETTING.BLEND_FRAMES,
                        DurianSettingsItems.showIcons.rawValue : durian.SETTING.SHOW_ICONS
                    ][boolSetting.key] else {
                        return
                    }
                    
                    await tabController.gamesManager.durianSystem.setSetting(setting: setting, value: boolSetting.value)
                case let selectionSetting as SelectionSetting:
                    selectionSetting.selectedValue = UserDefaults.standard.integer(forKey: selectionSetting.key)
                    
                    guard let setting: durian.SETTING = [
                        DurianSettingsItems.consoleModel.rawValue : durian.SETTING.CONSOLE_MODEL
                    ][selectionSetting.key] else {
                        return
                    }
                    
                    switch selectionSetting.selectedValue {
                    case let int as Int:
                        await tabController.gamesManager.durianSystem.setSetting(setting: setting, value: int)
                    default:
                        break
                    }
                default:
                    break
                }
            }
        case .grape:
            Task {
                switch item {
                case let boolSetting as BoolSetting:
                    boolSetting.value = UserDefaults.standard.bool(forKey: boolSetting.key)
                    
                    guard let setting: grape.SETTING = [
                        GrapeSettingsItems.skipBootScreen.rawValue : grape.SETTING.SKIP_BOOT_SCREEN
                    ][boolSetting.key] else {
                        return
                    }
                    
                    await tabController.gamesManager.grapeSystem.setSetting(setting: setting, value: boolSetting.value)
                case let selectionSetting as SelectionSetting:
                    selectionSetting.selectedValue = UserDefaults.standard.integer(forKey: selectionSetting.key)
                    
                    guard let setting: grape.SETTING = [
                        GrapeSettingsItems.consoleModel.rawValue : grape.SETTING.CONSOLE_MODEL
                    ][selectionSetting.key] else {
                        return
                    }
                    
                    switch selectionSetting.selectedValue {
                    case let int as Int:
                        await tabController.gamesManager.grapeSystem.setSetting(setting: setting, value: int)
                    default:
                        break
                    }
                default:
                    break
                }
            }
        case .kiwi:
            Task {
                switch item {
                case let boolSetting as BoolSetting:
                    boolSetting.value = UserDefaults.standard.bool(forKey: boolSetting.key)
                    
                    guard let setting: kiwi.SETTING = [
                        KiwiSettingsItems.adjustColours.rawValue : kiwi.SETTING.ADJUST_COLOURS,
                        KiwiSettingsItems.blendFrames.rawValue : kiwi.SETTING.BLEND_FRAMES
                    ][boolSetting.key] else {
                        return
                    }
                    
                    await tabController.gamesManager.kiwiSystem.setSetting(setting: setting, value: boolSetting.value)
                default:
                    break
                }
            }
        case .lychee:
            break
        case .mandarine:
            Task {
                switch item {
                case let boolSetting as BoolSetting:
                    boolSetting.value = UserDefaults.standard.bool(forKey: boolSetting.key)
                    
                    guard let setting: mandarine.SETTING = [
                        MandarineSettingsItems.extendedMemory.rawValue : mandarine.SETTING.EXTENDED_MEMORY,
                        MandarineSettingsItems.forceNTSC.rawValue : mandarine.SETTING.FORCE_NTSC,
                        MandarineSettingsItems.forceWidescreen.rawValue : mandarine.SETTING.FORCE_WIDESCREEN,
                        MandarineSettingsItems.logBios.rawValue : mandarine.SETTING.LOG_BIOS,
                        MandarineSettingsItems.logCdrom.rawValue : mandarine.SETTING.LOG_CDROM,
                        MandarineSettingsItems.logController.rawValue : mandarine.SETTING.LOG_CONTROLLER,
                        MandarineSettingsItems.logDma.rawValue : mandarine.SETTING.LOG_DMA,
                        MandarineSettingsItems.logGpu.rawValue : mandarine.SETTING.LOG_GPU,
                        MandarineSettingsItems.logGte.rawValue : mandarine.SETTING.LOG_GTE,
                        MandarineSettingsItems.logMdec.rawValue : mandarine.SETTING.LOG_MDEC,
                        MandarineSettingsItems.logMemoryCard.rawValue : mandarine.SETTING.LOG_MEMORY_CARD,
                        MandarineSettingsItems.logMemoryControl.rawValue : mandarine.SETTING.LOG_MEMORY_CONTROL,
                        MandarineSettingsItems.logSpu.rawValue : mandarine.SETTING.LOG_SPU,
                        MandarineSettingsItems.logSystem.rawValue : mandarine.SETTING.LOG_SYSTEM,
                        MandarineSettingsItems.nativeTextureFormat.rawValue : mandarine.SETTING.NATIVE_TEXTURE_FORMAT,
                        MandarineSettingsItems.preserveState.rawValue : mandarine.SETTING.PRESERVE_STATE,
                        MandarineSettingsItems.soundEnabled.rawValue : mandarine.SETTING.SOUND_ENABLED,
                        MandarineSettingsItems.timeTravel.rawValue : mandarine.SETTING.TIME_TRAVEL,
                        MandarineSettingsItems.vsync.rawValue : mandarine.SETTING.VSYNC,
                        MandarineSettingsItems.widescreen.rawValue : mandarine.SETTING.WIDESCREEN
                    ][boolSetting.key] else {
                        return
                    }
                    
                    await tabController.gamesManager.mandarineSystem.setSetting(setting: setting, value: boolSetting.value)
                default:
                    break
                }
            }
        case .mango:
            break
        case .plum:
            break
        case .tomato:
            Task {
                switch item {
                case let boolSetting as BoolSetting:
                    boolSetting.value = UserDefaults.standard.bool(forKey: boolSetting.key)
                    
                    guard let setting: tomato.SETTING = [
                        TomatoSettingsItems.skipBootScreen.rawValue : tomato.SETTING.SKIP_BOOT_SCREEN,
                        
                        TomatoSettingsItems.adjustColours.rawValue : tomato.SETTING.ADJUST_COLOURS,
                        TomatoSettingsItems.blendFrames.rawValue : tomato.SETTING.BLEND_FRAMES,
                        TomatoSettingsItems.frameSkipping.rawValue : tomato.SETTING.FRAME_SKIPPING
                    ][boolSetting.key] else {
                        return
                    }
                    
                    await tabController.gamesManager.tomatoSystem.setSetting(setting: setting, value: boolSetting.value)
                default:
                    break
                }
            }
        }
        
        snapshot.reloadItems([item])
        Task {
            await dataSource.apply(snapshot)
        }
    }
}
