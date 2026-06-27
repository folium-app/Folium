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

class GamesController : UICollectionViewController {
    var importFileType: ImportFileType = .game
    var selectedSnapshot: SelectedSnapshot = .grape {
        didSet {
            guard let dataSource: UICollectionViewDiffableDataSource<String, Game> else {
                return
            }
            
            navigationItem.largeSubtitle = selectedSnapshot.string
            navigationItem.subtitle = navigationItem.largeSubtitle
            
            Task {
                switch selectedSnapshot {
                case .cytrus:
                    break
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
    
    var dataSource: UICollectionViewDiffableDataSource<String, Game>? = nil
    var grapeSnapshot: NSDiffableDataSourceSnapshot<String, Game>? = nil
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
        navigationItem.largeTitle = "Games"
        
        navigationItem.trailingItemGroups = [
            UIBarButtonItemGroup(barButtonItems: [
                UIBarButtonItem(image: UIImage(systemName: "plus"), menu: UIMenu(children: [
                    UIMenu(options: .displayInline, preferredElementSize: .medium, children: [
                        UIAction(title: "Game", image: UIImage(systemName: "opticaldisc")) { action in
                            self.importFileType = .game
                            var types: [UTType] = []
                            switch self.selectedSnapshot {
                            case .grape:
                                if let nds: UTType = .nds {
                                    types.append(nds)
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
                            documentPickerController.allowsMultipleSelection = [.mandarine, .tomato].contains(self.selectedSnapshot)
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
                        UIAction(title: "3DS", subtitle: "Nintendo 3DS", attributes: .disabled) { action in },
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
        navigationItem.title = navigationItem.largeTitle
        navigationItem.style = .browser
        view.backgroundColor = .systemBackground
        
        collectionView.bottomEdgeEffect.style = .soft
        collectionView.topEdgeEffect.style = .soft
        
        let grapeCell: UICollectionView.CellRegistration<GrapeCell, GrapeGame> = CellManager.Library.grapeCell(viewController: self)
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
            case let grapeGame as GrapeGame:
                collectionView.dequeueConfiguredReusableCell(using: grapeCell, for: indexPath, item: grapeGame)
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
                (UIButton.Configuration.glassConfiguration(.large, .capsule, nil, "Continue"), { controller in
                    UserDefaults.standard.set(true, forKey: "folium.2.0.whatsNewComplete")
                    
                    onMainThread {
                        controller.dismiss(animated: true)
                    }
                })
            ]
            
            let cells: [CellConfiguration] = [
                CellConfiguration(image: UIImage(systemName: "square.grid.2x2.fill"), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "Library, Refreshed"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Rewrote the Library screen improving its design which in turn significantly improves user experience")
                )),
                CellConfiguration(image: UIImage(systemName: "gamecontroller.fill"), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "Emulation, Updated"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Rewrote the Emulation screen improving its design and support for landscape")
                )),
                CellConfiguration(image: UIImage(systemName: "list.bullet.badge.ellipsis"), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "Settings, Cleaned Up"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Rewrote the Settings screen separating each system's settings, added descriptions available by swiping left")
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
        
        if !UserDefaults.standard.bool(forKey: "folium.2.0.whatsNewComplete") {
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
        if let tabBarController {
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
        case let grapeGame as GrapeGame:
            tabController.game = grapeGame
            
            let grapeController: GrapeController = GrapeController()
            tabController.switchEmulationController(with: grapeController)
            tabController.switchSettingsSnapshot(for: .grape)
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
        case is GrapeGame.Type:
            if let games: [GrapeGame] = games as? [GrapeGame] {
                let sections: [GrapeGame] = games.mapUniqueBy({ game in game }, key: { game in game.prefix })
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
            grapeSnapshot = NSDiffableDataSourceSnapshot<String, Game>()
            guard var grapeSnapshot else {
                return
            }
            generateSnapshot(for: &grapeSnapshot, for: await tabController.gamesManager.games(for: .grape), type: GrapeGame.self)
            self.grapeSnapshot = grapeSnapshot
            
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
                navigationItem.largeSubtitle = selectedSnapshot.string
                navigationItem.subtitle = navigationItem.largeSubtitle
                
                switch selectedSnapshot {
                case .grape:
                    await dataSource.apply(grapeSnapshot)
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
        case .grape,
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
        guard let notificationType: UINotificationFeedbackGenerator.FeedbackType = switch state {
        case .notConnected: .error
        case .connecting: nil
        case .connected: .success
        default:
            nil
        } else {
            return
        }
        
        Task { @MainActor in
            UINotificationFeedbackGenerator(view: view).notificationOccurred(notificationType)
        }
    }
    
    nonisolated func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
    }
    
    nonisolated func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    nonisolated func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    nonisolated func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
        
    }
}
