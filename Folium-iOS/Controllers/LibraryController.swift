//
//  LibraryController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 4/7/2024.
//

import ContentTypeManager
import Cytrus
import DirectoryManager
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation
import System
import UIKit
import WidgetKit

class LibraryController : UICollectionViewController {
    var dataSource: UICollectionViewDiffableDataSource<Core, GameBase>? = nil
    var snapshot: NSDiffableDataSourceSnapshot<Core, GameBase>? = nil
    var searchSnapshot: NSDiffableDataSourceSnapshot<Core, GameBase>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController {
            navigationController.navigationBar.prefersLargeTitles = true
        }
        title = "Library"
        
        let refreshControl: UIRefreshControl = .init()
        refreshControl.addTarget(self, action: #selector(refreshGames(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        
        setSettingsButton()
        setWeeTitle()
        
        // TODO: Redo this
        let gameBoyCellRegistration: UICollectionView.CellRegistration<GameBoyCell, GameBoyGame> = .init { $0.set(text: $2.title, with: .white) }
        let gameBoyAdvanceCellRegistration: UICollectionView.CellRegistration<GameBoyAdvanceCell, GameBoyAdvanceGame> = .init { $0.set($2, with: self) }
        let nintendo3DSCellRegistration: UICollectionView.CellRegistration<Nintendo3DSCell, Nintendo3DSGame> = .init { $0.set($2, with: self) }
        let nintendoDSCellRegistration: UICollectionView.CellRegistration<NintendoDSCell, NintendoDSGame> = .init { $0.set($2, with: self) }
        let playStation1CellRegistration: UICollectionView.CellRegistration<PlayStation1Cell, PlayStation1Game> = .init { $0.set($2, with: self) }
        let nesCellRegistration: UICollectionView.CellRegistration<NintendoEntertainmentSystemCell, NintendoEntertainmentSystemGame> = .init { $0.set(text: $2.title, with: .white) }
        let superNESCellRegistration: UICollectionView.CellRegistration<SuperNESCell, SuperNESGame> = .init { $0.set($2, with: self) }
        
        let headerCellRegistration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell> = .init(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] supplementaryView, elementKind, indexPath in
            var contentConfiguration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            if let self, let dataSource = self.dataSource, let core = dataSource.sectionIdentifier(for: indexPath.section) {
                contentConfiguration.text = core.rawValue
                if UserDefaults.standard.bool(forKey: "folium.showConsoleNames") {
                    contentConfiguration.secondaryText = core.console
                }
                
                if UserDefaults.standard.bool(forKey: "folium.showBetaConsoles"), core.isBeta {
                    var configuration: UIButton.Configuration = .tinted()
                    configuration.attributedTitle = .init("BETA", attributes: .init([
                        .font : UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
                    ]))
                    configuration.baseBackgroundColor = .systemOrange
                    configuration.baseForegroundColor = .systemOrange
                    configuration.buttonSize = .medium
                    configuration.cornerStyle = .capsule
                    supplementaryView.accessories = [
                        .customView(configuration: .init(customView: UIButton(configuration: configuration), placement: .trailing()))
                    ]
                } else {
                    supplementaryView.accessories = []
                }
            }
            supplementaryView.contentConfiguration = contentConfiguration
        }
        
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case let gameBoyGame as GameBoyGame:
                collectionView.dequeueConfiguredReusableCell(using: gameBoyCellRegistration, for: indexPath, item: gameBoyGame)
            case let gameBoyAdvanceGame as GameBoyAdvanceGame:
                collectionView.dequeueConfiguredReusableCell(using: gameBoyAdvanceCellRegistration, for: indexPath, item: gameBoyAdvanceGame)
            case let nintendo3DSGame as Nintendo3DSGame:
                collectionView.dequeueConfiguredReusableCell(using: nintendo3DSCellRegistration, for: indexPath, item: nintendo3DSGame)
            case let nintendoDSGame as NintendoDSGame:
                collectionView.dequeueConfiguredReusableCell(using: nintendoDSCellRegistration, for: indexPath, item: nintendoDSGame)
            case let playStation1Game as PlayStation1Game:
                collectionView.dequeueConfiguredReusableCell(using: playStation1CellRegistration, for: indexPath, item: playStation1Game)
            case let nintendoEnterainmentSystemGame as NintendoEntertainmentSystemGame:
                collectionView.dequeueConfiguredReusableCell(using: nesCellRegistration, for: indexPath, item: nintendoEnterainmentSystemGame)
            case let superNESGame as SuperNESGame:
                collectionView.dequeueConfiguredReusableCell(using: superNESCellRegistration, for: indexPath, item: superNESGame)
            default:
                nil
            }
        }
        
        guard let dataSource else { return }
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerCellRegistration, for: indexPath)
        }
        // TODO: Redo this
        
        Task {
            beginPopulatingGames(with: try LibraryManager.shared.games().get())
        }
    }
    
    func beginImportingGames() {
        let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: ContentTypeManager.contentTypes)
        documentPickerController.allowsMultipleSelection = true
        documentPickerController.delegate = self
        self.present(documentPickerController, animated: true)
    }
    
    func beginPopulatingGames(with games: [GameBase]) {
        snapshot = .init()
        guard let dataSource, var snapshot else {
            return
        }
        
        snapshot.appendSections(LibraryManager.shared.coresWithGames.sorted(by: { $0.rawValue < $1.rawValue }))
        LibraryManager.shared.coresWithGames.forEach { core in
            snapshot.appendItems(games.filter {
                $0.core == core.rawValue
            }.sorted(by: { $0.title < $1.title }), toSection: core)
        }
        
        Task { await dataSource.apply(snapshot) }
    }
    
    @objc func refreshGames(_ refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        
        Task {
            beginPopulatingGames(with: try LibraryManager.shared.games().get())
        }
        
        refreshControl.endRefreshing()
    }
    
    func setSettingsButton() {
        var children: [UIMenuElement] = [
            UIAction(title: "App Settings", image: .init(systemName: "leaf"), handler: { [weak self] _ in
                guard let self else { return }
                
                var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                configuration.headerMode = .supplementary
                let listCollectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
                
                let foliumSettingsController = UINavigationController(rootViewController: FoliumSettingsController(collectionViewLayout: listCollectionViewLayout))
                foliumSettingsController.modalPresentationStyle = .fullScreen
                self.present(foliumSettingsController, animated: true)
            }),
            UIMenu(options: .displayInline, children: [
                UIMenu(title: "Cytrus", children: [
                    UIAction(title: "Browse Rooms", image: .init(systemName: "magnifyingglass"), handler: { [weak self] _ in
                        guard let self else { return }
                        
                        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                        configuration.headerMode = .supplementary
                        let listCollectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
                        
                        let roomsController = UINavigationController(rootViewController: CytrusRoomsController(collectionViewLayout: listCollectionViewLayout))
                        roomsController.modalPresentationStyle = .fullScreen
                        self.present(roomsController, animated: true)
                    }),
                    UIAction(title: "Settings", image: .init(systemName: "gearshape"), handler: { [weak self] _ in
                        guard let self else { return }
                        
                        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                        configuration.headerMode = .supplementary
                        let listCollectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
                        
                        let cytrusSettingsController = UINavigationController(rootViewController: CytrusSettingsController(collectionViewLayout: listCollectionViewLayout))
                        cytrusSettingsController.modalPresentationStyle = .fullScreen
                        self.present(cytrusSettingsController, animated: true)
                    }),
                ]),
                UIAction(title: "Grape", handler: { [weak self] _ in
                    guard let self else { return }
                    
                    var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                    configuration.headerMode = .supplementary
                    let listCollectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
                    
                    let grapeSettingsController = UINavigationController(rootViewController: GrapeSettingsController(collectionViewLayout: listCollectionViewLayout))
                    grapeSettingsController.modalPresentationStyle = .fullScreen
                    self.present(grapeSettingsController, animated: true)
                })
            ])
        ]
        
        children.append(UIMenu(options: .displayInline, children: [
            UIAction(title: "Missing Files", image: .init(systemName: "doc"), handler: { [weak self] _ in
                guard let self else { return }
                
                var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                configuration.headerMode = .supplementary
                let listCollectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
                
                let missingFilesController = UINavigationController(rootViewController: MissingFilesController(collectionViewLayout: listCollectionViewLayout))
                missingFilesController.modalPresentationStyle = .fullScreen
                self.present(missingFilesController, animated: true)
            })
        ]))
        
        if AppStoreCheck.shared.additionalFeaturesAreAllowed {
            if Auth.auth().currentUser == nil {
                children.append(UIMenu(options: .displayInline, children: [
                    UIAction(title: "Sign In", image: .init(systemName: "arrow.right"), handler: { [weak self] _ in
                        guard let self else { return }
                        
                        let authenticationController = AuthenticationController()
                        authenticationController.modalPresentationStyle = .fullScreen
                        self.present(authenticationController, animated: true)
                    })
                ]))
            } else {
                children.append(UIMenu(options: .displayInline, children: [
                    UIAction(title: "Sign Out", image: .init(systemName: "arrow.right"), attributes: [.destructive], handler: { [weak self] _ in
                        guard let self else { return }
                        
                        do {
                            try Auth.auth().signOut()
                            
                            let authenticationController = AuthenticationController()
                            authenticationController.modalPresentationStyle = .fullScreen
                            self.present(authenticationController, animated: true)
                        } catch {
                            print(#function, error, error.localizedDescription)
                        }
                    })
                ]))
            }
        }
        
        navigationItem.rightBarButtonItem = .init(image: .init(systemName: "gearshape.fill"), menu: .init(children: [
            UIAction(title: "Import Games", image: .init(systemName: "arrow.down.document"), handler: { [weak self] _ in
                guard let self else { return }
                self.beginImportingGames()
            }),
            UIMenu(title: "Settings", image: .init(systemName: "gearshape"), children: children)
        ]))
    }
    
    func setWeeTitle() {
        let userDefaults: UserDefaults? = .init(suiteName: "group.com.antique.Folium")
        guard AppStoreCheck.shared.additionalFeaturesAreAllowed, let user = Auth.auth().currentUser,
              let displayName = user.displayName, let firstName = displayName.components(separatedBy: " ").first, let userDefaults else { return }
        
        let prefix = switch Calendar.current.component(.hour, from: .now) {
        case 6...11: "Good Morning"
        case 12...17: "Good Afternoon"
        default: "Good Evening"
        }
        
        navigationItem.perform(NSSelectorFromString("_setWeeTitle:"), with: "\(prefix), \(firstName)")
        
        let document = Firestore.firestore().collection("users").document(user.uid)
        Task {
            userDefaults.set(try JSONEncoder().encode(try await document.getDocument(as: User.self)), forKey: "user")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

extension LibraryController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let dataSource, let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case let nintendoDSGame as NintendoDSGame:
            guard let skin = grapeSkin else { return }
            
            let nintendoDSEmulationController = GrapeDefaultController(game: nintendoDSGame, skin: skin)
            nintendoDSEmulationController.modalPresentationStyle = .fullScreen
            present(nintendoDSEmulationController, animated: true)
        case let nintendo3DSGame as Nintendo3DSGame:
            guard let skin = cytrusSkin else { return }
            
            let nintendo3DSEmulationController = CytrusDefaultController(game: nintendo3DSGame, skin: skin)
            nintendo3DSEmulationController.modalPresentationStyle = .fullScreen
            present(nintendo3DSEmulationController, animated: true)
        case let superNESGame as SuperNESGame:
            guard let skin = mangoSkin else { return }
            
            let superNESEmulationController = MangoDefaultController(game: superNESGame, skin: skin)
            superNESEmulationController.modalPresentationStyle = .fullScreen
            present(superNESEmulationController, animated: true)
        case let playStation1Game as PlayStation1Game:
            guard let skin = lycheeSkin else { return }
            
            let lycheeSkinController = LycheeDefaultController(game: playStation1Game, skin: skin)
            lycheeSkinController.modalPresentationStyle = .fullScreen
            present(lycheeSkinController, animated: true)
        case let gameBoyAdvanceGame as GameBoyAdvanceGame:
            guard let skin = tomatoSkin else { return }
            
            let gameBoyAdvanceEmulationController = TomatoDefaultController(game: gameBoyAdvanceGame, skin: skin)
            gameBoyAdvanceEmulationController.modalPresentationStyle = .fullScreen
            present(gameBoyAdvanceEmulationController, animated: true)
        case let nintendoEntertainmentSystemGame as NintendoEntertainmentSystemGame:
            guard let skin = peachSkin else { return }
            
            let nintendoEntertainmentSystemEmulationController = PeachDefaultController(game: nintendoEntertainmentSystemGame, skin: skin)
            nintendoEntertainmentSystemEmulationController.modalPresentationStyle = .fullScreen
            present(nintendoEntertainmentSystemEmulationController, animated: true)
        default:
            break
        }
    }
}

extension LibraryController : UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        urls.forEach { url in
            Task {
                try urls.forEach { url in
                    if url.pathExtension.lowercased() == "cia" {
                        _ = Cytrus.shared.importGame(at: url)
                    } else {
                        let romsDirectoryURL: URL =
                        switch url.pathExtension.lowercased() {
                        case "dsi", "nds":
                            documentDirectory.appendingPathComponent("Grape", conformingTo: .folder)
                                .appendingPathComponent("roms", conformingTo: .folder)
                        case "3ds", "app", "cci", "cxi":
                            documentDirectory.appendingPathComponent("Cytrus", conformingTo: .folder)
                                .appendingPathComponent("roms", conformingTo: .folder)
                        case "bin", "cue":
                            if url.lastPathComponent.lowercased() == "bios.bin" {
                                documentDirectory.appendingPathComponent("Lychee", conformingTo: .folder)
                                    .appendingPathComponent("sysdata", conformingTo: .folder)
                            } else {
                                documentDirectory.appendingPathComponent("Lychee", conformingTo: .folder)
                                    .appendingPathComponent("roms", conformingTo: .folder)
                            }
                        case "sfc", "smc":
                            documentDirectory.appendingPathComponent("Mango", conformingTo: .folder)
                                .appendingPathComponent("roms", conformingTo: .folder)
                        case "gba":
                            documentDirectory.appendingPathComponent("Tomato", conformingTo: .folder)
                                .appendingPathComponent("roms", conformingTo: .folder)
                        default:
                            documentDirectory
                        }
                        
                        try FileManager.default.moveItem(at: url, to: romsDirectoryURL.appendingPathComponent(url.lastPathComponent, conformingTo: .fileURL))
                    }
                }
                
                beginPopulatingGames(with: try LibraryManager.shared.games().get())
            }
        }
    }
}

extension LibraryController : UISearchControllerDelegate, UISearchResultsUpdating {
    func willDismissSearchController(_ searchController: UISearchController) {
        guard let dataSource, let searchSnapshot else { return }
        Task {
            await dataSource.apply(searchSnapshot)
            self.searchSnapshot = nil
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let dataSource, let text = searchController.searchBar.text, !text.isEmpty else { return }
        
        if searchSnapshot == nil {
            searchSnapshot = dataSource.snapshot()
        }
        guard let searchSnapshot else { return }
        
        let filtered = searchSnapshot.itemIdentifiers.filter { $0.title.localizedCaseInsensitiveContains(text) }
        let cores = Set(filtered.compactMap { Core(rawValue: $0.core) })
        
        var newSnapshot: NSDiffableDataSourceSnapshot<Core, GameBase> = .init()
        newSnapshot.appendSections(cores.sorted(by: <))
        cores.forEach { core in
            newSnapshot.appendItems(filtered.filter { $0.core == core.rawValue }, toSection: core)
        }
        
        Task { await dataSource.apply(newSnapshot) }
    }
}
