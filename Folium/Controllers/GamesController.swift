//
//  GamesController.swift
//  Folium
//
//  Created by Jarrod Norwell on 3/6/2026.
//

import ColourKit
import ExtensionsKit
import FontKit
import MultipeerConnectivity
import OnboardingKit
import UniformTypeIdentifiers
import UIKit

import Tomato

class GamesController : UICollectionViewController {
    var importFileType: ImportFileType = .game
    var selectedSnapshot: SelectedSnapshot = .cytrus {
        didSet {
            guard let dataSource: UICollectionViewDiffableDataSource<String, Game> else {
                return
            }
            
            if #available(iOS 26.0, *) {
                navigationItem.largeSubtitle = selectedSnapshot.string
                navigationItem.subtitle = navigationItem.largeSubtitle
            }
            
            Task {
                switch selectedSnapshot {
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
                case .kiwi:
                    guard let kiwiSnapshot else {
                        return
                    }
                    
                    await dataSource.apply(kiwiSnapshot)
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
    
    var dataSource: UICollectionViewDiffableDataSource<String, Game>? = nil
    var cytrusSnapshot: NSDiffableDataSourceSnapshot<String, Game>? = nil
    var grapeSnapshot: NSDiffableDataSourceSnapshot<String, Game>? = nil
    var kiwiSnapshot: NSDiffableDataSourceSnapshot<String, Game>? = nil
    var mandarineSnapshot: NSDiffableDataSourceSnapshot<String, Game>? = nil
    var tomatoSnapshot: NSDiffableDataSourceSnapshot<String, Game>? = nil
    
    nonisolated(unsafe) var advertiser: MCNearbyServiceAdvertiser? = nil
    nonisolated(unsafe) var browser: MCNearbyServiceBrowser? = nil
    nonisolated(unsafe) var session: MCSession? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController {
            navigationController.navigationBar.prefersLargeTitles = true
        }
        
        if #available(iOS 26.0, *) {
            navigationItem.largeTitle = "Games"
            navigationItem.title = navigationItem.largeTitle
        } else {
            navigationItem.title = "Games"
        }
        
        navigationItem.trailingItemGroups = [
            UIBarButtonItemGroup(barButtonItems: [
                UIBarButtonItem(image: UIImage(systemName: "plus"), menu: UIMenu(children: [
                    UIMenu(options: .displayInline, preferredElementSize: .medium, children: [
                        UIAction(title: "Game", image: UIImage(systemName: "opticaldisc")) { action in
                            self.importFileType = .game
                            var types: [UTType] = []
                            switch self.selectedSnapshot {
                            case .cytrus:
                                if let `3ds`: UTType = .`3ds`, let cci: UTType = .cci {
                                    types.append(contentsOf: [`3ds`, cci])
                                }
                            case .grape:
                                if let nds: UTType = .nds {
                                    types.append(nds)
                                }
                            case .kiwi:
                                if let gb: UTType = .gb, let gbc: UTType = .gbc {
                                    types.append(contentsOf: [gb, gbc])
                                }
                            case .mandarine:
                                if let bin: UTType = .bin, let cue: UTType = .cue {
                                    types.append(contentsOf: [bin, cue])
                                }
                            case .tomato:
                                if let gba: UTType = .gba {
                                    types.append(gba)
                                }
                            default:
                                break
                            }
                            
                            let documentPickerController: UIDocumentPickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
                            documentPickerController.allowsMultipleSelection = [.mandarine, .tomato].contains(self.selectedSnapshot)
                            documentPickerController.delegate = self
                            self.present(documentPickerController, animated: true)
                        },
                        UIAction(title: "System File", image: UIImage(systemName: "document"), attributes: .disabled) { action in
                            self.importFileType = .systemFile
                            var types: [UTType] = []
                            switch self.selectedSnapshot {
                            case .grape,
                                    .mandarine,
                                    .tomato:
                                if let bin: UTType = .bin {
                                    types.append(bin)
                                }
                            default:
                                break
                            }
                            
                            let documentPickerController: UIDocumentPickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
                            documentPickerController.allowsMultipleSelection = [.grape, .mandarine, .tomato].contains(self.selectedSnapshot)
                            documentPickerController.delegate = self
                            self.present(documentPickerController, animated: true)
                        }
                    ])
                ])),
                UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: UIMenu(children: [
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
                        UIAction(title: "GB/GBC", subtitle: "Game Boy/Game Boy Color") { action in
                            self.selectedSnapshot = .kiwi
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
            ], representativeItem: nil),
            UIBarButtonItemGroup(barButtonItems: [
                UIBarButtonItem(image: UIImage(systemName: "network"), menu: UIMenu(options: .displayInline, preferredElementSize: .medium, children: [
                    UIDeferredMenuElement.uncached { completion in
                        guard let advertiser: MCNearbyServiceAdvertiser = self.advertiser,
                              let browser: MCNearbyServiceBrowser = self.browser,
                              let session: MCSession = self.session else {
                                  completion([])
                                  return
                              }
                        
                        let barButtonItem: UIBarButtonItem? = self.navigationItem.trailingItemGroups.last?.barButtonItems.first
                        
                        let hostingOrJoined: Bool = session.connectedPeers.count > 0
                        
                        let leaveAction: UIAction = UIAction(title: "Leave", image: UIImage(systemName: "network.slash"), attributes: hostingOrJoined ? .destructive : [.destructive, .disabled]) { handler in
                            advertiser.stopAdvertisingPeer()
                            browser.stopBrowsingForPeers()
                            session.disconnect()
                            if let barButtonItem: UIBarButtonItem {
                                barButtonItem.tintColor = nil
                            }
                        }
                        
                        let hostAction: UIAction = UIAction(title: hostingOrJoined ? "Hosting" : "Host", image: UIImage(systemName: "wave.3.up"), attributes: hostingOrJoined ? .disabled : []) { handler in
                            advertiser.startAdvertisingPeer()
                            if let barButtonItem: UIBarButtonItem {
                                barButtonItem.tintColor = .tintColor
                            }
                        }
                        
                        let joinAction: UIAction = UIAction(title: hostingOrJoined ? "Joined" : "Join", image: UIImage(systemName: "wave.3.down"), attributes: hostingOrJoined ? .disabled : []) { handler in
                            browser.startBrowsingForPeers()
                            if let barButtonItem: UIBarButtonItem {
                                barButtonItem.tintColor = .tintColor
                            }
                        }
                        
                        var children: [UIMenuElement] = [hostAction, joinAction]
                        if hostingOrJoined {
                            children.prepend(element: leaveAction)
                        }
                        
                        completion(children)
                    }
                ]))
            ], representativeItem: nil)
        ]
        navigationItem.style = .browser
        view.backgroundColor = .systemBackground
        
        if #available(iOS 26.0, *) {
            collectionView.bottomEdgeEffect.style = .soft
            collectionView.topEdgeEffect.style = .soft
        }
        
        let cytrusCell: UICollectionView.CellRegistration<CytrusCell, CytrusGame> = CellManager.Library.cytrusCell(viewController: self)
        let grapeCell: UICollectionView.CellRegistration<GrapeCell, GrapeGame> = CellManager.Library.grapeCell(viewController: self)
        let kiwiCell: UICollectionView.CellRegistration<KiwiCell, KiwiGame> = CellManager.Library.kiwiCell(viewController: self)
        let mandarineCell: UICollectionView.CellRegistration<MandarineCell, MandarineGame> = CellManager.Library.mandarineCell(viewController: self)
        let tomatoCell: UICollectionView.CellRegistration<TomatoCell, TomatoGame> = CellManager.Library.tomatoCell(viewController: self)
        
        let supplementaryCell: UICollectionView.SupplementaryRegistration<UICollectionViewListCell> = UICollectionView.SupplementaryRegistration(elementKind: .header) { supplementaryView, elementKind, indexPath in
            var contentConfiguration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            if let dataSource: UICollectionViewDiffableDataSource<String, Game> = self.dataSource,
               let system: String = dataSource.sectionIdentifier(for: indexPath.section) {
                contentConfiguration.text = system
            }
            supplementaryView.contentConfiguration = contentConfiguration
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case let cytrusGame as CytrusGame:
                collectionView.dequeueConfiguredReusableCell(using: cytrusCell, for: indexPath, item: cytrusGame)
            case let grapeGame as GrapeGame:
                collectionView.dequeueConfiguredReusableCell(using: grapeCell, for: indexPath, item: grapeGame)
            case let kiwiGame as KiwiGame:
                collectionView.dequeueConfiguredReusableCell(using: kiwiCell, for: indexPath, item: kiwiGame)
            case let mandarineGame as MandarineGame:
                collectionView.dequeueConfiguredReusableCell(using: mandarineCell, for: indexPath, item: mandarineGame)
            case let tomatoGame as TomatoGame:
                collectionView.dequeueConfiguredReusableCell(using: tomatoCell, for: indexPath, item: tomatoGame)
            default:
                nil
            }
        }
        
        guard let dataSource else {
            return
        }
        
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryCell, for: indexPath)
        }
        
        Task {
            await populateGames()
        }
        
        var whatsNewController: OBControllerWithList {
            let textFont: UIFont = .regular(from: .extraLargeTitle)
            
            let image: UIImage? = UIImage(systemName: "sparkles")
            
            let textConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                           color: .label,
                                                                           font: textFont,
                                                                           text: "What's New")
            
            let secondaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                    color: .secondaryLabel,
                                                                                    font: UIFont.regular(from: .body),
                                                                                    text: "What's new in the latest version of Folium")
            
            let buttons: [(UIButton.Configuration, @MainActor (UIViewController) async -> Void)] = [
                (UIButton.Configuration.configuration(.large, .capsule, nil, "Continue"), { controller in
                    UserDefaults.standard.set(true, forKey: "folium.2.0.13.whatsNewComplete")
                    
                    onMainThread {
                        controller.dismiss(animated: true)
                    }
                })
            ]
            
            let appIconSystemName: String = if #available(iOS 26.0, *) {
                "app.grid"
            } else {
                "app.dashed"
            }
            
            let automaticMigrationSystemName: String = if #available(iOS 26.0, *) {
                "arrow.forward.folder.fill"
            } else {
                "folder.fill.badge.gearshape"
            }
            
            let cells: [CellConfiguration] = [
                CellConfiguration(image: UIImage(systemName: appIconSystemName), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "New App Icon"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Redesigned and changed the colour of the app icon breathing new life into it alongside the app itself")
                )),
                CellConfiguration(image: UIImage(systemName: "sparkles"), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "New Onboarding"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Rewrote and significantly improved the onboarding screens for both iPad and iPhone\n\nCurrently a Work in Progress")
                )),
                CellConfiguration(image: UIImage(systemName: "square.grid.2x2.fill"), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "New Library"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Rewrote and significantly improved the library screen, refreshing the game cards, separating systems and more"),
                )),
                CellConfiguration(image: UIImage(systemName: "gearshape.fill"), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "New Settings"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Rewrote and significantly improved the settings screen, adding descriptions, separating systems and more")
                )),
                CellConfiguration(image: UIImage(systemName: "circle.grid.2x1.left.filled"), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "New Tabs"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Changed how library, emulation and settings screens are handled by embedding them in tabs, allowing for real-time settings changes and more")
                )),
                CellConfiguration(image: UIImage(systemName: "cpu.fill"), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "New Grape"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Reimplemented most of Grape using direct C++ to Swift, updated sections of code to C++23 and more")
                )),
                CellConfiguration(image: UIImage(systemName: "cpu.fill"), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "New Kiwi"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Reimplemented Kiwi using direct C++ to Swift, updated sections of code to C++23 and more")
                )),
                CellConfiguration(image: UIImage(systemName: "cpu.fill"), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "New Mandarine"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Reimplemented Mandarine using direct C++ to Swift, updated sections of code to C++23 and more")
                )),
                CellConfiguration(image: UIImage(systemName: "cpu.fill"), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "New Tomato"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Reimplemented Tomato using direct C++ to Swift, updated sections of code to C++23 and more")
                )),
                CellConfiguration(image: UIImage(systemName: "xmark.bin.fill"), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "Delete"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Improved how games are deleted now allowing for all tracks, etc. to be deleted along with the folder they are nested in, if available")
                )),
                CellConfiguration(image: UIImage(systemName: "photo.badge.arrow.down.fill"), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "Boxart"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Improved how boxart is handled, fixing online searching, caching from online if one is found or loading from local if one is selected")
                )),
                CellConfiguration(image: UIImage(systemName: "playpause.fill"), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "Playback"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Added and improved pause, play and stop and exit to all available systems and enabled support for changing tabs with ongoing playback")
                )),
                CellConfiguration(image: UIImage(systemName: "circle.grid.cross.up.filled"), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "On-Screen Controls"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Improved the functionality and positioning of the on-screen controls, fixing ghost holds, etc")
                )),
                
                // (13)
                CellConfiguration(image: UIImage(systemName: "apps.iphone.badge.plus"), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "iOS 18+ Support"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Added support for iOS and iPadOS 18 and above, improving device support across the board")
                )),
                CellConfiguration(image: UIImage(systemName: automaticMigrationSystemName), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "Automatic Migration"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Automatically renames previous folders to their new, correct names as of 2.0")
                )),
                CellConfiguration(image: UIImage(systemName: "rectangle.and.pencil.and.ellipsis"), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "Grape to C++"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Rewrote a large portion of Grape in C++ conforming to the new bridging system between systems and the application itself")
                ))
            ]
            
            let configuration: OBControllerWithListConfiguration = OBControllerWithListConfiguration(image: image,
                                                                                                     textConfiguration: textConfiguration,
                                                                                                     secondaryConfiguration: secondaryTextConfiguration,
                                                                                                     tertiaryConfiguration: nil,
                                                                                                     buttons: buttons,
                                                                                                     cells: cells)
            
            let controller: OBControllerWithList = OBControllerWithList(configuration: configuration)
            controller.modalPresentationStyle = .overFullScreen
            return controller
        }
        
        if !UserDefaults.standard.bool(forKey: "folium.2.0.13.whatsNewComplete") {
            present(whatsNewController, animated: true)
        }
        
        let peerID: MCPeerID = MCPeerID(displayName: UIDevice.current.name)
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "foliumlink")
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: "foliumlink")
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        
        if let advertiser: MCNearbyServiceAdvertiser, let browser: MCNearbyServiceBrowser, let session: MCSession {
            advertiser.delegate = self
            browser.delegate = self
            session.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 18.0, *), let tabBarController {
            tabBarController.setTabBarHidden(false, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let tabController: TabController = tabBarController as? TabController,
              tabController.game == nil,
              let dataSource: UICollectionViewDiffableDataSource<String, Game>,
              let game: Game = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch game {
        case let cytrusGame as CytrusGame:
            tabController.game = cytrusGame
            
            let cytrusController: CytrusController = CytrusController()
            tabController.switchEmulationController(with: cytrusController)
            tabController.switchSettingsSnapshot(for: .cytrus)
        case let grapeGame as GrapeGame:
            tabController.game = grapeGame
            
            let grapeController: GrapeController = GrapeController()
            tabController.switchEmulationController(with: grapeController)
            tabController.switchSettingsSnapshot(for: .grape)
        case let kiwiGame as KiwiGame:
            tabController.game = kiwiGame
            
            let kiwiController: KiwiController = KiwiController()
            tabController.switchEmulationController(with: kiwiController)
            // tabController.switchSettingsSnapshot(for: .kiwi)
        case let mandarineGame as MandarineGame:
            tabController.game = mandarineGame
            
            let mandarineController: MandarineController = MandarineController()
            tabController.switchEmulationController(with: mandarineController)
            tabController.switchSettingsSnapshot(for: .mandarine)
        case let tomatoGame as TomatoGame:
            tabController.game = tomatoGame
            
            let tomatoController: TomatoController = TomatoController()
            tabController.switchEmulationController(with: tomatoController)
            tabController.switchSettingsSnapshot(for: .tomato)
        default:
            break
        }
    }
    
    func generateSnapshot<T>(for snapshot: inout NSDiffableDataSourceSnapshot<String, Game>, for games: [T], type: T.Type) {
        switch T.self {
        case is CytrusGame.Type:
            if let games: [CytrusGame] = games as? [CytrusGame] {
                let sections: [CytrusGame] = games.mapUniqueBy({ game in game }, key: { game in game.prefix })
                let sectionsStrings: [String] = sections.map(\.prefix)
                
                snapshot.appendSections(sectionsStrings.sorted())
                snapshot.sectionIdentifiers.forEach { section in
                    snapshot.appendItems(games.filter { game in game.prefix == section }.sorted(), toSection: section)
                }
            }
        case is GrapeGame.Type:
            if let games: [GrapeGame] = games as? [GrapeGame] {
                let sections: [GrapeGame] = games.mapUniqueBy({ game in game }, key: { game in game.prefix })
                let sectionsStrings: [String] = sections.map(\.prefix)
                
                snapshot.appendSections(sectionsStrings.sorted())
                snapshot.sectionIdentifiers.forEach { section in
                    snapshot.appendItems(games.filter { game in game.prefix == section }.sorted(), toSection: section)
                }
            }
        case is KiwiGame.Type:
            if let games: [KiwiGame] = games as? [KiwiGame] {
                let sections: [KiwiGame] = games.mapUniqueBy({ game in game }, key: { game in game.prefix })
                let sectionsStrings: [String] = sections.map(\.prefix)
                
                snapshot.appendSections(sectionsStrings.sorted())
                snapshot.sectionIdentifiers.forEach { section in
                    snapshot.appendItems(games.filter { game in game.prefix == section }.sorted(), toSection: section)
                }
            }
        case is MandarineGame.Type:
            if let games: [MandarineGame] = games as? [MandarineGame] {
                let sections: [MandarineGame] = games.mapUniqueBy({ game in game }, key: { game in game.prefix })
                let sectionsStrings: [String] = sections.map(\.prefix)
                
                snapshot.appendSections(sectionsStrings.sorted())
                snapshot.sectionIdentifiers.forEach { section in
                    snapshot.appendItems(games.filter { game in game.prefix == section }.sorted(), toSection: section)
                }
            }
        case is TomatoGame.Type:
            if let games: [TomatoGame] = games as? [TomatoGame] {
                let sections: [TomatoGame] = games.mapUniqueBy({ game in game }, key: { game in game.prefix })
                let sectionsStrings: [String] = sections.map(\.prefix)
                
                snapshot.appendSections(sectionsStrings.sorted())
                snapshot.sectionIdentifiers.forEach { section in
                    snapshot.appendItems(games.filter { game in game.prefix == section }.sorted(), toSection: section)
                }
            }
        default:
            break
        }
    }
    
    func populateGames() async {
        if let dataSource, let tabController: TabController = tabBarController as? TabController {
            cytrusSnapshot = NSDiffableDataSourceSnapshot<String, Game>()
            guard var cytrusSnapshot else {
                return
            }
            generateSnapshot(for: &cytrusSnapshot, for: await tabController.gamesManager.games(for: .cytrus), type: CytrusGame.self)
            self.cytrusSnapshot = cytrusSnapshot
            
            grapeSnapshot = NSDiffableDataSourceSnapshot<String, Game>()
            guard var grapeSnapshot else {
                return
            }
            generateSnapshot(for: &grapeSnapshot, for: await tabController.gamesManager.games(for: .grape), type: GrapeGame.self)
            self.grapeSnapshot = grapeSnapshot
            
            kiwiSnapshot = NSDiffableDataSourceSnapshot<String, Game>()
            guard var kiwiSnapshot else {
                return
            }
            generateSnapshot(for: &kiwiSnapshot, for: await tabController.gamesManager.games(for: .kiwi), type: KiwiGame.self)
            self.kiwiSnapshot = kiwiSnapshot
            
            mandarineSnapshot = NSDiffableDataSourceSnapshot<String, Game>()
            guard var mandarineSnapshot else {
                return
            }
            generateSnapshot(for: &mandarineSnapshot, for: await tabController.gamesManager.games(for: .mandarine), type: MandarineGame.self)
            self.mandarineSnapshot = mandarineSnapshot
            
            tomatoSnapshot = NSDiffableDataSourceSnapshot<String, Game>()
            guard var tomatoSnapshot else {
                return
            }
            generateSnapshot(for: &tomatoSnapshot, for: await tabController.gamesManager.games(for: .tomato), type: TomatoGame.self)
            self.tomatoSnapshot = tomatoSnapshot
            
            Task {
                if #available(iOS 26.0, *) {
                    navigationItem.largeSubtitle = selectedSnapshot.string
                    navigationItem.subtitle = navigationItem.largeSubtitle
                }
                
                switch selectedSnapshot {
                case .cytrus:
                    await dataSource.apply(cytrusSnapshot)
                case .grape:
                    await dataSource.apply(grapeSnapshot)
                case .kiwi:
                    await dataSource.apply(kiwiSnapshot)
                case .mandarine:
                    await dataSource.apply(mandarineSnapshot)
                case .tomato:
                    await dataSource.apply(tomatoSnapshot)
                default:
                    break
                }
            }
        }
    }
}

extension GamesController : UIDocumentPickerDelegate, UINavigationControllerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let documentDirectoryURL: URL = .documentDirectoryURL else {
            return
        }
        
        var gamesDirectoryURL: URL = documentDirectoryURL
        switch selectedSnapshot {
        case .cytrus,
                .grape,
                .kiwi,
                .mandarine,
                .tomato:
            gamesDirectoryURL.append(component: selectedSnapshot.string)
        default:
            break
        }
        
        gamesDirectoryURL.append(component: "games")
        
        for url in urls {
            let toURL: URL = gamesDirectoryURL.appending(component: url.lastPathComponent)
            do {
                try FileManager.default.copyItem(at: url, to: toURL)
            } catch {
                print(error, error.localizedDescription)
            }
        }
        
        controller.dismiss(animated: true)
    }
}

extension GamesController : MCNearbyServiceAdvertiserDelegate {
    nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if let session: MCSession {
            invitationHandler(true, session)
        }
    }
}

extension GamesController : MCNearbyServiceBrowserDelegate {
    nonisolated func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if let session: MCSession {
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30.0)
        }
    }
    
    nonisolated func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }
}

extension GamesController : MCSessionDelegate {
    nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
    }
    
    nonisolated func session(_ session: MCSession, didReceive data: Data,
                             fromPeer peerID: MCPeerID) {
        
    }
    
    nonisolated func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String,
                             fromPeer peerID: MCPeerID) {
        
    }
    
    nonisolated func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String,
                             fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    nonisolated func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
                             fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
        
    }
}
