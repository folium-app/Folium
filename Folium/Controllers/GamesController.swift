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
import StoreKit
import SwiftUI
import UniformTypeIdentifiers
import UIKit

enum HostingOrJoiningState {
    case disconnected,
         hosting,
         joined
}

class GamesController : UICollectionViewController {
    var currentlyImportingSystemFile: String? = nil
    var importFileType: ImportFileType = .game
    
    var hostingOrJoiningState: HostingOrJoiningState = .disconnected
    var selectedSnapshot: SelectedSnapshot = .durian {
        didSet {
            guard let dataSource: UICollectionViewDiffableDataSource<String, Game> else {
                return
            }
            
            if #available(iOS 26.0, *) {
                navigationItem.largeSubtitle = selectedSnapshot.system?.console ?? selectedSnapshot.string
                navigationItem.subtitle = navigationItem.largeSubtitle
            }
            
            Task {
                switch selectedSnapshot {
                case .cherry:
                    guard let cherrySnapshot else {
                        return
                    }
                    
                    await dataSource.apply(cherrySnapshot)
                case .cytrus:
                    guard let cytrusSnapshot else {
                        return
                    }
                    
                    await dataSource.apply(cytrusSnapshot)
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
                case .lychee:
                    guard let lycheeSnapshot else {
                        return
                    }
                    
                    await dataSource.apply(lycheeSnapshot)
                case .mandarine:
                    guard let mandarineSnapshot else {
                        return
                    }
                    
                    await dataSource.apply(mandarineSnapshot)
                case .mango:
                    guard let mangoSnapshot else {
                        return
                    }
                    
                    await dataSource.apply(mangoSnapshot)
                case .plum:
                    guard let plumSnapshot else {
                        return
                    }
                    
                    await dataSource.apply(plumSnapshot)
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
    var cherrySnapshot: NSDiffableDataSourceSnapshot<String, Game>? = nil
    var cytrusSnapshot: NSDiffableDataSourceSnapshot<String, Game>? = nil
    var durianSnapshot: NSDiffableDataSourceSnapshot<String, Game>? = nil
    var grapeSnapshot: NSDiffableDataSourceSnapshot<String, Game>? = nil
    var kiwiSnapshot: NSDiffableDataSourceSnapshot<String, Game>? = nil
    var lycheeSnapshot: NSDiffableDataSourceSnapshot<String, Game>? = nil
    var mandarineSnapshot: NSDiffableDataSourceSnapshot<String, Game>? = nil
    var mangoSnapshot: NSDiffableDataSourceSnapshot<String, Game>? = nil
    var plumSnapshot: NSDiffableDataSourceSnapshot<String, Game>? = nil
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
                UIBarButtonItem(image: UIImage(systemName: "plus"),
                                primaryAction: UIAction(image: UIImage(systemName: "opticaldisc")) { action in
                                    self.importFileType = .game
                                    
                                    let documentPickerController: UIDocumentPickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: self.selectedSnapshot.types, asCopy: true)
                                    documentPickerController.allowsMultipleSelection = true
                                    documentPickerController.delegate = self
                                    self.present(documentPickerController, animated: true)
                                }),
                UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: UIMenu(children: [
                    UIDeferredMenuElement.uncached { completion in
                        completion([
                            UIMenu(options: .displayInline, children: [
                                UIMenu(title: "Bandai", image: UIImage(systemName: "cpu"), children: [
                                    UIAction(title: "WonderSwan", subtitle: "+ WonderSwan Color") { action in
                                        self.selectedSnapshot = .durian
                                    }
                                ]),
                                UIMenu(title: "Coleco", image: UIImage(systemName: "cpu"), children: [
                                    UIAction(title: "ColecoVision") { action in
                                        self.selectedSnapshot = .cherry
                                    }
                                ]),
                                UIMenu(title: "Nintendo", image: UIImage(systemName: "cpu"), children: [
                                    UIAction(title: "3DS", subtitle: "+ New 3DS") { action in
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
                                    UIAction(title: "Nintendo Entertainment System") { action in
                                        self.selectedSnapshot = .mango
                                    },
                                    UIAction(title: "Super Nintendo Entertainment System") { action in
                                        self.selectedSnapshot = .lychee
                                    }
                                ]),
                                UIMenu(title: "SEGA", image: UIImage(systemName: "cpu"), children: [
                                    UIAction(title: "Genesis", subtitle: "+ Mega Drive") { action in
                                        self.selectedSnapshot = .plum
                                    }
                                ]),
                                UIMenu(title: "Sony", image: UIImage(systemName: "cpu"), children: [
                                    UIAction(title: "PlayStation 1") { action in
                                        self.selectedSnapshot = .mandarine
                                    }
                                ])
                            ]),
                            UIAction(title: self.selectedSnapshot.string, subtitle: "Open in Files", image: UIImage(systemName: "arrow.up.forward.app")) { action in
                                if let documentDirectoryURL: URL = .documentDirectoryURL, let sharedDocumentsURL: URL = URL(string: "shareddocuments://\(documentDirectoryURL.path)") {
                                    let url: URL = sharedDocumentsURL.appending(component: self.selectedSnapshot.string)
                                    Task {
                                        await UIApplication.shared.open(url)
                                    }
                                }
                            }
                        ])
                    }
                ]))
            ], representativeItem: nil),
            UIBarButtonItemGroup(barButtonItems: [
                UIBarButtonItem(image: UIImage(systemName: "network"), menu: UIMenu(children: [
                    UIDeferredMenuElement.uncached { completion in
                        guard let advertiser: MCNearbyServiceAdvertiser = self.advertiser,
                              let browser: MCNearbyServiceBrowser = self.browser,
                              let session: MCSession = self.session else {
                            completion([])
                            return
                        }
                        
                        let leaveAction: UIAction = UIAction(title: "Leave",
                                                             image: UIImage(systemName: "network.slash"),
                                                             attributes: .destructive) { handler in
                            self.hostingOrJoiningState = .disconnected
                            advertiser.stopAdvertisingPeer()
                            browser.stopBrowsingForPeers()
                        }
                        
                        let hostAction: UIAction = UIAction(title: self.hostingOrJoiningState == .hosting ? "Hosting" : "Host",
                                                            image: UIImage(systemName: "wave.3.up"),
                                                            attributes: self.hostingOrJoiningState == .hosting ? .disabled : []) { handler in
                            self.hostingOrJoiningState = .hosting
                            advertiser.startAdvertisingPeer()
                        }
                        
                        let joinAction: UIAction = UIAction(title: self.hostingOrJoiningState == .joined ? "Joined" : "Join",
                                                            image: UIImage(systemName: "wave.3.down"),
                                                            attributes: self.hostingOrJoiningState == .joined ? .disabled : []) { handler in
                            self.hostingOrJoiningState = .joined
                            browser.startBrowsingForPeers()
                        }
                        
                        var children: [UIMenuElement] = []
                        
                        switch self.hostingOrJoiningState {
                        case .disconnected:
                            children = [hostAction, joinAction]
                        case .hosting:
                            children = [hostAction]
                        case .joined:
                            children = [joinAction]
                        }
                        
                        if self.hostingOrJoiningState != .disconnected && session.connectedPeers.count > 0 {
                            children.append(leaveAction)
                        }
                        
                        if UserDefaults.standard.bool(forKey: "extraFeaturesPurchased") {
                            completion([UIMenu(options: .displayInline, preferredElementSize: .medium, children: children)])
                        } else {
                            completion([
                                UIAction(title: "Extra Features", subtitle: "Requires Purchase", image: UIImage(systemName: "bag")) { action in
                                    if let tabController: TabController = self.tabBarController as? TabController {
                                        tabController.switchSettingsSnapshot(for: .application)
                                        tabController.selectedIndex = .settingsController
                                    }
                                }
                            ])
                        }
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
        
        let refreshControl: UIRefreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(repopulate(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        let cherryCell: UICollectionView.CellRegistration<CherryCell, CherryGame> = CellManager.Library.cherryCell(viewController: self)
        let cytrusCell: UICollectionView.CellRegistration<CytrusCell, CytrusGame> = CellManager.Library.cytrusCell(viewController: self)
        let durianCell: UICollectionView.CellRegistration<DurianCell, DurianGame> = CellManager.Library.durianCell(viewController: self)
        let grapeCell: UICollectionView.CellRegistration<GrapeCell, GrapeGame> = CellManager.Library.grapeCell(viewController: self)
        let kiwiCell: UICollectionView.CellRegistration<KiwiCell, KiwiGame> = CellManager.Library.kiwiCell(viewController: self)
        let lycheeCell: UICollectionView.CellRegistration<LycheeCell, LycheeGame> = CellManager.Library.lycheeCell(viewController: self)
        let mandarineCell: UICollectionView.CellRegistration<MandarineCell, MandarineGame> = CellManager.Library.mandarineCell(viewController: self)
        let mangoCell: UICollectionView.CellRegistration<MangoCell, MangoGame> = CellManager.Library.mangoCell(viewController: self)
        let plumCell: UICollectionView.CellRegistration<PlumCell, PlumGame> = CellManager.Library.plumCell(viewController: self)
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
            case let cherryGame as CherryGame:
                collectionView.dequeueConfiguredReusableCell(using: cherryCell, for: indexPath, item: cherryGame)
            case let cytrusGame as CytrusGame:
                collectionView.dequeueConfiguredReusableCell(using: cytrusCell, for: indexPath, item: cytrusGame)
            case let durianGame as DurianGame:
                collectionView.dequeueConfiguredReusableCell(using: durianCell, for: indexPath, item: durianGame)
            case let grapeGame as GrapeGame:
                collectionView.dequeueConfiguredReusableCell(using: grapeCell, for: indexPath, item: grapeGame)
            case let kiwiGame as KiwiGame:
                collectionView.dequeueConfiguredReusableCell(using: kiwiCell, for: indexPath, item: kiwiGame)
            case let lycheeGame as LycheeGame:
                collectionView.dequeueConfiguredReusableCell(using: lycheeCell, for: indexPath, item: lycheeGame)
            case let mandarineGame as MandarineGame:
                collectionView.dequeueConfiguredReusableCell(using: mandarineCell, for: indexPath, item: mandarineGame)
            case let mangoGame as MangoGame:
                collectionView.dequeueConfiguredReusableCell(using: mangoCell, for: indexPath, item: mangoGame)
            case let plumGame as PlumGame:
                collectionView.dequeueConfiguredReusableCell(using: plumCell, for: indexPath, item: plumGame)
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
        
        if let defaultSystemForLibrary: String = UserDefaults.standard.string(forKey: "folium.defaultSystemForLibrary"),
           let ss: SelectedSnapshot = SelectedSnapshot.from(string: defaultSystemForLibrary) {
            selectedSnapshot = ss
        }
        
        Task {
            await populateGames()
        }
        
        if !UserDefaults.standard.bool(forKey: "folium.2.2.5.whatsNewComplete") {
            let whatsNewController: WhatsNewController = WhatsNewController()
            whatsNewController.modalPresentationStyle = .overFullScreen
            present(whatsNewController, animated: true)
        }
        
        let peerID: MCPeerID = MCPeerID(displayName: UIDevice.current.name)
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "foliumlink")
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: "foliumlink")
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        
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
        
        func beginImporting(systemFile: String) {
            currentlyImportingSystemFile = systemFile
            
            let documentPickerController: UIDocumentPickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: [.item],
                                                                                                          asCopy: true)
            documentPickerController.delegate = self
            present(documentPickerController, animated: true)
        }
        
        func requiresSystemFiles(for system: System) async -> (Bool, [SystemFile]) {
            let systemFiles: [SystemFile] = await tabController.directoryManager.unavailableSystemFiles
            return (systemFiles.contains(where: { systemFile in systemFile.system == system }), systemFiles.filter { systemFile in systemFile.system == system })
        }
        
        let alertController: UIAlertController = UIAlertController(title: "Requires System Files",
                                                                   message: "Required system files for this console cannot be found, please tap one of the options below to import them",
                                                                   preferredStyle: .alert)
        
        Task {
            switch game {
            case let cherryGame as CherryGame:
                let (result, systemFiles) = await requiresSystemFiles(for: cherryGame.system)
                if result {
                    importFileType = .system
                    
                    for systemFile in systemFiles {
                        alertController.addAction(UIAlertAction(title: systemFile.fileName, style: .default) { action in
                            beginImporting(systemFile: systemFile.fileName)
                        })
                    }
                    
                    present(alertController, animated: true)
                } else {
                    tabController.game = cherryGame
                    
                    let cherryController: CherryController = CherryController()
                    tabController.switchEmulationController(with: cherryController)
                    // tabController.switchSettingsSnapshot(for: .cherry)
                    
                    // let encoder: JSONEncoder = JSONEncoder()
                    // do {
                    //     let packet: P2P.Packet = P2P.Packet(data: Data(), dataType: .prepare(.cherry))
                    //     if let session: MCSession, session.connectedPeers.count > 0 {
                    //         try session.send(encoder.encode(packet), toPeers: session.connectedPeers, with: .reliable)
                    //     }
                    // } catch {
                    //     print(error, error.localizedDescription)
                    // }
                }
            case let cytrusGame as CytrusGame:
                let (result, systemFiles) = await requiresSystemFiles(for: cytrusGame.system)
                if result {
                    importFileType = .system
                    
                    for systemFile in systemFiles {
                        alertController.addAction(UIAlertAction(title: systemFile.fileName, style: .default) { action in
                            beginImporting(systemFile: systemFile.fileName)
                        })
                    }
                    
                    present(alertController, animated: true)
                } else {
                    tabController.game = cytrusGame
                    
                    let cytrusController: CytrusController = CytrusController()
                    tabController.switchEmulationController(with: cytrusController)
                    // tabController.switchSettingsSnapshot(for: .cytrus)
                }
            case let durianGame as DurianGame:
                let (result, systemFiles) = await requiresSystemFiles(for: durianGame.system)
                if result {
                    importFileType = .system
                    
                    for systemFile in systemFiles {
                        alertController.addAction(UIAlertAction(title: systemFile.fileName, style: .default) { action in
                            beginImporting(systemFile: systemFile.fileName)
                        })
                    }
                    
                    present(alertController, animated: true)
                } else {
                    tabController.game = durianGame
                    
                    let durianController: DurianController = DurianController()
                    tabController.switchEmulationController(with: durianController)
                    tabController.switchSettingsSnapshot(for: .durian)
                }
            case let grapeGame as GrapeGame:
                let (result, systemFiles) = await requiresSystemFiles(for: grapeGame.system)
                if result {
                    importFileType = .system
                    
                    for systemFile in systemFiles {
                        alertController.addAction(UIAlertAction(title: systemFile.fileName, style: .default) { action in
                            beginImporting(systemFile: systemFile.fileName)
                        })
                    }
                    
                    present(alertController, animated: true)
                } else {
                    tabController.game = grapeGame
                    
                    let grapeController: GrapeController = GrapeController()
                    tabController.switchEmulationController(with: grapeController)
                    tabController.switchSettingsSnapshot(for: .grape)
                }
            case let kiwiGame as KiwiGame:
                let (result, systemFiles) = await requiresSystemFiles(for: kiwiGame.system)
                if result {
                    importFileType = .system
                    
                    for systemFile in systemFiles {
                        alertController.addAction(UIAlertAction(title: systemFile.fileName, style: .default) { action in
                            beginImporting(systemFile: systemFile.fileName)
                        })
                    }
                    
                    present(alertController, animated: true)
                } else {
                    tabController.game = kiwiGame
                    
                    let kiwiController: KiwiController = KiwiController()
                    tabController.switchEmulationController(with: kiwiController)
                    tabController.switchSettingsSnapshot(for: .kiwi)
                }
            case let lycheeGame as LycheeGame:
                let (result, systemFiles) = await requiresSystemFiles(for: lycheeGame.system)
                if result {
                    importFileType = .system
                    
                    for systemFile in systemFiles {
                        alertController.addAction(UIAlertAction(title: systemFile.fileName, style: .default) { action in
                            beginImporting(systemFile: systemFile.fileName)
                        })
                    }
                    
                    present(alertController, animated: true)
                } else {
                    tabController.game = lycheeGame
                    
                    let lycheeController: LycheeController = LycheeController()
                    tabController.switchEmulationController(with: lycheeController)
                    // tabController.switchSettingsSnapshot(for: .lychee)
                }
            case let mandarineGame as MandarineGame:
                let (result, systemFiles) = await requiresSystemFiles(for: mandarineGame.system)
                if result {
                    importFileType = .system
                    
                    for systemFile in systemFiles {
                        alertController.addAction(UIAlertAction(title: systemFile.fileName, style: .default) { action in
                            beginImporting(systemFile: systemFile.fileName)
                        })
                    }
                    
                    present(alertController, animated: true)
                } else {
                    tabController.game = mandarineGame
                    
                    let mandarineController: MandarineController = MandarineController()
                    tabController.switchEmulationController(with: mandarineController)
                    // tabController.switchSettingsSnapshot(for: .mandarine)
                    
                    let encoder: JSONEncoder = JSONEncoder()
                    do {
                        let packet: P2P.Packet = P2P.Packet(data: Data(), dataType: .prepare(.mandarine))
                        if let session: MCSession, session.connectedPeers.count > 0 {
                            try session.send(encoder.encode(packet), toPeers: session.connectedPeers, with: .reliable)
                        }
                    } catch {
                        print(error, error.localizedDescription)
                    }
                }
            case let mangoGame as MangoGame:
                let (result, systemFiles) = await requiresSystemFiles(for: mangoGame.system)
                if result {
                    importFileType = .system
                    
                    for systemFile in systemFiles {
                        alertController.addAction(UIAlertAction(title: systemFile.fileName, style: .default) { action in
                            beginImporting(systemFile: systemFile.fileName)
                        })
                    }
                    
                    present(alertController, animated: true)
                } else {
                    tabController.game = mangoGame
                    
                    let mangoController: MangoController = MangoController()
                    tabController.switchEmulationController(with: mangoController)
                    // tabController.switchSettingsSnapshot(for: .mango)
                }
            case let plumGame as PlumGame:
                let (result, systemFiles) = await requiresSystemFiles(for: plumGame.system)
                if result {
                    importFileType = .system
                    
                    for systemFile in systemFiles {
                        alertController.addAction(UIAlertAction(title: systemFile.fileName, style: .default) { action in
                            beginImporting(systemFile: systemFile.fileName)
                        })
                    }
                    
                    present(alertController, animated: true)
                } else {
                    tabController.game = plumGame
                    
                    let plumController: PlumController = PlumController()
                    tabController.switchEmulationController(with: plumController)
                    // tabController.switchSettingsSnapshot(for: .plum)
                    
                    let encoder: JSONEncoder = JSONEncoder()
                    do {
                        let packet: P2P.Packet = P2P.Packet(data: Data(), dataType: .prepare(.plum))
                        if let session: MCSession, session.connectedPeers.count > 0 {
                            try session.send(encoder.encode(packet), toPeers: session.connectedPeers, with: .reliable)
                        }
                    } catch {
                        print(error, error.localizedDescription)
                    }
                }
            case let tomatoGame as TomatoGame:
                let (result, systemFiles) = await requiresSystemFiles(for: tomatoGame.system)
                if result {
                    importFileType = .system
                    
                    for systemFile in systemFiles {
                        alertController.addAction(UIAlertAction(title: systemFile.fileName, style: .default) { action in
                            beginImporting(systemFile: systemFile.fileName)
                        })
                    }
                    
                    present(alertController, animated: true)
                } else {
                    tabController.game = tomatoGame
                    
                    let tomatoController: TomatoController = TomatoController()
                    tabController.switchEmulationController(with: tomatoController)
                    tabController.switchSettingsSnapshot(for: .tomato)
                }
            default:
                break
            }
        }
    }
    
    func generateSnapshot<T>(for snapshot: inout NSDiffableDataSourceSnapshot<String, Game>, for games: [T], type: T.Type) {
        switch T.self {
        case is CherryGame.Type:
            if let games: [CherryGame] = games as? [CherryGame] {
                let sections: [CherryGame] = games.mapUniqueBy({ game in game }, key: { game in game.prefix })
                let sectionsStrings: [String] = sections.map(\.prefix)
                
                snapshot.appendSections(sectionsStrings.sorted())
                snapshot.sectionIdentifiers.forEach { section in
                    snapshot.appendItems(games.filter { game in game.prefix == section }.sorted(), toSection: section)
                }
            }
        case is CytrusGame.Type:
            if let games: [CytrusGame] = games as? [CytrusGame] {
                let sections: [CytrusGame] = games.mapUniqueBy({ game in game }, key: { game in game.prefix })
                let sectionsStrings: [String] = sections.map(\.prefix)
                
                snapshot.appendSections(sectionsStrings.sorted())
                snapshot.sectionIdentifiers.forEach { section in
                    snapshot.appendItems(games.filter { game in game.prefix == section }.sorted(), toSection: section)
                }
            }
        case is DurianGame.Type:
            if let games: [DurianGame] = games as? [DurianGame] {
                let sections: [DurianGame] = games.mapUniqueBy({ game in game }, key: { game in game.prefix })
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
        case is LycheeGame.Type:
            if let games: [LycheeGame] = games as? [LycheeGame] {
                let sections: [LycheeGame] = games.mapUniqueBy({ game in game }, key: { game in game.prefix })
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
        case is MangoGame.Type:
            if let games: [MangoGame] = games as? [MangoGame] {
                let sections: [MangoGame] = games.mapUniqueBy({ game in game }, key: { game in game.prefix })
                let sectionsStrings: [String] = sections.map(\.prefix)
                
                snapshot.appendSections(sectionsStrings.sorted())
                snapshot.sectionIdentifiers.forEach { section in
                    snapshot.appendItems(games.filter { game in game.prefix == section }.sorted(), toSection: section)
                }
            }
        case is PlumGame.Type:
            if let games: [PlumGame] = games as? [PlumGame] {
                let sections: [PlumGame] = games.mapUniqueBy({ game in game }, key: { game in game.prefix })
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
    
    func populateGames(_ reinitialisingSystem: Bool = false) async {
        if let dataSource, let tabController: TabController = tabBarController as? TabController {
            cherrySnapshot = NSDiffableDataSourceSnapshot<String, Game>()
            guard var cherrySnapshot else {
                return
            }
            generateSnapshot(for: &cherrySnapshot, for: await tabController.gamePopulationManager.retrieveGames(.cherry), type: CherryGame.self)
            self.cherrySnapshot = cherrySnapshot
            
            cytrusSnapshot = NSDiffableDataSourceSnapshot<String, Game>()
            guard var cytrusSnapshot else {
                return
            }
            generateSnapshot(for: &cytrusSnapshot, for: await tabController.gamePopulationManager.retrieveGames(.cytrus), type: CytrusGame.self)
            self.cytrusSnapshot = cytrusSnapshot
            
            durianSnapshot = NSDiffableDataSourceSnapshot<String, Game>()
            guard var durianSnapshot else {
                return
            }
            generateSnapshot(for: &durianSnapshot, for: await tabController.gamePopulationManager.retrieveGames(.durian), type: DurianGame.self)
            self.durianSnapshot = durianSnapshot
            
            grapeSnapshot = NSDiffableDataSourceSnapshot<String, Game>()
            guard var grapeSnapshot else {
                return
            }
            generateSnapshot(for: &grapeSnapshot, for: await tabController.gamePopulationManager.retrieveGames(.grape), type: GrapeGame.self)
            self.grapeSnapshot = grapeSnapshot
            
            kiwiSnapshot = NSDiffableDataSourceSnapshot<String, Game>()
            guard var kiwiSnapshot else {
                return
            }
            generateSnapshot(for: &kiwiSnapshot, for: await tabController.gamePopulationManager.retrieveGames(.kiwi), type: KiwiGame.self)
            self.kiwiSnapshot = kiwiSnapshot
            
            lycheeSnapshot = NSDiffableDataSourceSnapshot<String, Game>()
            guard var lycheeSnapshot else {
                return
            }
            generateSnapshot(for: &lycheeSnapshot, for: await tabController.gamePopulationManager.retrieveGames(.lychee), type: LycheeGame.self)
            self.lycheeSnapshot = lycheeSnapshot
            
            mandarineSnapshot = NSDiffableDataSourceSnapshot<String, Game>()
            guard var mandarineSnapshot else {
                return
            }
            generateSnapshot(for: &mandarineSnapshot, for: await tabController.gamePopulationManager.retrieveGames(.mandarine), type: MandarineGame.self)
            self.mandarineSnapshot = mandarineSnapshot
            
            mangoSnapshot = NSDiffableDataSourceSnapshot<String, Game>()
            guard var mangoSnapshot else {
                return
            }
            generateSnapshot(for: &mangoSnapshot, for: await tabController.gamePopulationManager.retrieveGames(.mango), type: MangoGame.self)
            self.mangoSnapshot = mangoSnapshot
            
            plumSnapshot = NSDiffableDataSourceSnapshot<String, Game>()
            guard var plumSnapshot else {
                return
            }
            generateSnapshot(for: &plumSnapshot, for: await tabController.gamePopulationManager.retrieveGames(.plum), type: PlumGame.self)
            self.plumSnapshot = plumSnapshot
            
            tomatoSnapshot = NSDiffableDataSourceSnapshot<String, Game>()
            guard var tomatoSnapshot else {
                return
            }
            generateSnapshot(for: &tomatoSnapshot, for: await tabController.gamePopulationManager.retrieveGames(.tomato), type: TomatoGame.self)
            self.tomatoSnapshot = tomatoSnapshot
            
            Task {
                if #available(iOS 26.0, *) {
                    navigationItem.largeSubtitle = selectedSnapshot.system?.console ?? selectedSnapshot.string
                    navigationItem.subtitle = navigationItem.largeSubtitle
                }
                
                switch selectedSnapshot {
                case .cherry:
                    await dataSource.apply(cherrySnapshot)
                case .cytrus:
                    await dataSource.apply(cytrusSnapshot)
                case .durian:
                    await dataSource.apply(durianSnapshot)
                case .grape:
                    await dataSource.apply(grapeSnapshot)
                case .kiwi:
                    await dataSource.apply(kiwiSnapshot)
                case .lychee:
                    await dataSource.apply(lycheeSnapshot)
                case .mandarine:
                    await dataSource.apply(mandarineSnapshot)
                case .mango:
                    await dataSource.apply(mangoSnapshot)
                case .plum:
                    await dataSource.apply(plumSnapshot)
                case .tomato:
                    await dataSource.apply(tomatoSnapshot)
                default:
                    break
                }
            }
        }
    }
    
    @objc func repopulate(_ refreshControl: UIRefreshControl) {
        Task {
            refreshControl.beginRefreshing()
            await populateGames()
            refreshControl.endRefreshing()
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
        case .cherry,
                .cytrus,
                .durian,
                .grape,
                .kiwi,
                .lychee,
                .mandarine,
                .mango,
                .plum,
                .tomato:
            gamesDirectoryURL.append(component: selectedSnapshot.string)
        default:
            break
        }
        
        gamesDirectoryURL.append(component: importFileType.directory)
        
        Task {
            await urls.asyncForEach { url in
                let toURL: URL = if importFileType == .game {
                    gamesDirectoryURL.appending(component: url.lastPathComponent)
                } else {
                    gamesDirectoryURL.appending(component: currentlyImportingSystemFile ?? url.lastPathComponent)
                }
                
                do {
                    try FileManager.default.copyItem(at: url, to: toURL)
                    
                    if let currentlyImportingSystemFile: String, let tabController: TabController = tabBarController as? TabController {
                        await tabController.directoryManager.removeUnavailableSystemFile(currentlyImportingSystemFile)
                    }
                } catch {
                    print(error, error.localizedDescription)
                }
            }
            
            controller.dismiss(animated: true) {
                Task {
                    await self.populateGames()
                }
            }
        }
    }
}

extension GamesController : MCNearbyServiceAdvertiserDelegate {
    nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
                                withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
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
        Task { @MainActor in
            hostingOrJoiningState = .disconnected
            
            let barButtonItem: UIBarButtonItem? = self.navigationItem.trailingItemGroups.last?.barButtonItems.first
            if let barButtonItem: UIBarButtonItem {
                barButtonItem.tintColor = if hostingOrJoiningState == .disconnected {
                    nil
                } else {
                    .tintColor
                }
            }
        }
    }
}

extension GamesController : MCSessionDelegate {
    nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Task { @MainActor in
            switch state {
            case .notConnected:
                hostingOrJoiningState = .disconnected
            default:
                break
            }
            
            let barButtonItem: UIBarButtonItem? = self.navigationItem.trailingItemGroups.last?.barButtonItems.first
            if let barButtonItem: UIBarButtonItem {
                barButtonItem.tintColor = if hostingOrJoiningState == .disconnected {
                    nil
                } else {
                    .tintColor
                }
            }
        }
        
        if let tabController: TabController = tabBarController as? TabController {
            if #available(iOS 18.0, *) {
                if let emulationController: ScreensController = tabController.tabs[.emulationController].viewController as? ScreensController {
                    emulationController.session(session, peer: peerID, didChange: state)
                }
            } else {
                
            }
        }
    }
    
    nonisolated func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let decoder: JSONDecoder = JSONDecoder()
        do {
            let packet: P2P.Packet = try decoder.decode(P2P.Packet.self, from: data)
            switch packet.dataType {
            case .prepare(.cherry):
                Task { @MainActor in
                    let cherryController: CherryMPController = CherryMPController()
                    cherryController.system = .cherry
                    if let tabController: TabController = tabBarController as? TabController {
                        tabController.switchEmulationController(with: cherryController)
                    }
                }
            case .prepare(.plum):
                Task { @MainActor in
                    let plumController: PlumMPController = PlumMPController()
                    plumController.system = .plum
                    if let tabController: TabController = tabBarController as? TabController {
                        tabController.switchEmulationController(with: plumController)
                    }
                }
            case .prepare(.mandarine):
                Task { @MainActor in
                    let mandarineController: MandarineMPController = MandarineMPController()
                    mandarineController.system = .mandarine
                    if let tabController: TabController = tabBarController as? TabController {
                        tabController.switchEmulationController(with: mandarineController)
                    }
                }
            default:
                break
            }
        } catch {
            print(error, error.localizedDescription)
        }
        
        if let tabController: TabController = tabBarController as? TabController {
            if #available(iOS 18.0, *) {
                if let emulationController: ScreensController = tabController.tabs[.emulationController].viewController as? ScreensController {
                    emulationController.session(session, didReceive: data, fromPeer: peerID)
                }
            }
        }
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

