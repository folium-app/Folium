//
//  LibraryController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 4/7/2024.
//

import Cytrus
import Firebase
import FirebaseAuth
import Foundation
import UIKit

class LibraryController: UICollectionViewController {
    fileprivate var dataSource: UICollectionViewDiffableDataSource<Core, GameBase>? = nil
    fileprivate var snapshot: NSDiffableDataSourceSnapshot<Core, GameBase>? = nil
    fileprivate var searchSnapshot: NSDiffableDataSourceSnapshot<Core, GameBase>? = nil
    
    var contentOffsetY: CGFloat? = nil
    var weeTitle: String? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        prefersLargeTitles(true)
        title = "Library"
        if AppStoreCheck.shared.additionalFeaturesAreAllowed, let currentUser = Auth.auth().currentUser, let displayName = currentUser.displayName,
           let firstName = displayName.components(separatedBy: " ").first {
            let prefix = switch Calendar.current.component(.hour, from: .now) {
            case 6...11:
                "Good Morning"
            case 12...17:
                "Good Afternoon"
            default:
                "Good Evening"
            }
            
            weeTitle = "\(prefix), \(firstName)"
            guard let weeTitle else {
                return
            }
            
            navigationItem.perform(NSSelectorFromString("_setWeeTitle:"), with: weeTitle)
        }
        
        var configuration = UIButton.Configuration.plain()
        configuration.buttonSize = .medium
        configuration.cornerStyle = .capsule
        configuration.image = .init(systemName: "gearshape.fill")
        
        let button = UIButton(configuration: configuration)
        var children: [UIMenuElement] = [
            UIMenu(options: .displayInline, children: [
                UIAction(title: "Import Games", image: .init(systemName: "plus"), handler: { _ in
                    self.openDocumentPickerController()
                }),
                UIMenu(title: "Core Settings", image: .init(systemName: "gearshape"), children: [
                    UIAction(title: "Cytrus", handler: { _ in
                        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                        configuration.headerMode = .supplementary
                        let listCollectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
                        
                        let cytrusSettingsController = UINavigationController(rootViewController: CytrusSettingsController(collectionViewLayout: listCollectionViewLayout))
                        cytrusSettingsController.modalPresentationStyle = .fullScreen
                        self.present(cytrusSettingsController, animated: true)
                    })
                ])
            ])
        ]
        if AppStoreCheck.shared.additionalFeaturesAreAllowed, Auth.auth().currentUser != nil {
            children.append(contentsOf: [
                UIAction(title: "View Account", image: .init(systemName: "person.text.rectangle"), handler: { _ in
                    
                }),
                UIAction(title: "Sign Out", image: .init(systemName: "arrow.right"), attributes: [.destructive], handler: { _ in
                    
                })
            ])
        }
        button.menu = .init(children: children)
        button.showsMenuAsPrimaryAction = true
        
        navigationItem.perform(NSSelectorFromString("_setLargeTitleAccessoryView:"), with: button)
        
        beginAddingSubviews()
        beginConfiguringCollectionView()
        
        populateGameLibrary()
    }
    
    @objc func refreshGameLibrary(_ refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        
        populateGameLibrary()
        
        refreshControl.endRefreshing()
    }
    
    func populateGameLibrary() {
        let task = Task { try LibraryManager.shared.games() }
        let task2 = Task {
            switch await task.result {
            case .failure(let error):
                print(print("\(#function): failed: \(error.localizedDescription)"))
            case .success(let games):
                print("\(#function): success")
                
                beginPopulatingGames(with: try games.get())
            }
        }
        
        Task {
            switch await task2.result {
            case .failure(let error):
                print(print("\(#function): failed: \(error), \(error.localizedDescription)"))
            case .success(_):
                print("\(#function): success")
            }
        }
    }
}

// MARK: Delegates
extension LibraryController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let dataSource, let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch item {
        case let nintendoDSGame as NintendoDSGame:
            guard let skin = grapeSkin else {
                return
            }
            
            let nintendoDSEmulationController = NintendoDSEmulationController(game: nintendoDSGame, skin: skin)
            nintendoDSEmulationController.modalPresentationStyle = .fullScreen
            present(nintendoDSEmulationController, animated: true)
        case let nintendo3DSGame as Nintendo3DSGame:
            guard let skin = cytrusSkin else {
                return
            }
            
            let nintendo3DSEmulationController = Nintendo3DSEmulationController(game: nintendo3DSGame, skin: skin)
            nintendo3DSEmulationController.modalPresentationStyle = .fullScreen
            present(nintendo3DSEmulationController, animated: true)
        case let superNESGame as SuperNESGame:
            guard let skin = mangoSkin else {
                return
            }
            
            let superNESEmulationController = SuperNESEmulationController(game: superNESGame, skin: skin)
            superNESEmulationController.modalPresentationStyle = .fullScreen
            present(superNESEmulationController, animated: true)
        default:
            break
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let contentOffsetY = contentOffsetY {
            if scrollView.contentOffset.y + contentOffsetY > 20 {
                navigationItem.weeTitle(with: "")
            } else {
                guard let weeTitle else {
                    return
                }
                
                navigationItem.weeTitle(with: weeTitle)
            }
        } else {
            contentOffsetY = abs(scrollView.contentOffset.y)
        }
    }
}

extension LibraryController: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let task = Task {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            try urls.forEach { url in
                if url.pathExtension.lowercased() == "cia" {
                    _ = Cytrus.shared.importGame(at: url)
                } else {
                    let romsDirectoryURL: URL =
                    switch url.pathExtension.lowercased() {
                    case "gb", "gbc":
                        documentDirectory.appendingPathComponent("Kiwi", conformingTo: .folder)
                            .appendingPathComponent("roms", conformingTo: .folder)
                    case "gba":
                        documentDirectory.appendingPathComponent("Tomato", conformingTo: .folder)
                            .appendingPathComponent("roms", conformingTo: .folder)
                    case "ds", "dsi", "nds":
                        documentDirectory.appendingPathComponent("Grape", conformingTo: .folder)
                            .appendingPathComponent("roms", conformingTo: .folder)
                    case "3ds", "app", "cci", "cxi":
                        documentDirectory.appendingPathComponent("Cytrus", conformingTo: .folder)
                            .appendingPathComponent("roms", conformingTo: .folder)
                    case "n64", "z64":
                        documentDirectory.appendingPathComponent("Guava", conformingTo: .folder)
                            .appendingPathComponent("roms", conformingTo: .folder)
                    case "cue":
                        documentDirectory.appendingPathComponent("Lychee", conformingTo: .folder)
                            .appendingPathComponent("roms", conformingTo: .folder)
                    case "sfc", "smc":
                        documentDirectory.appendingPathComponent("Mango", conformingTo: .folder)
                            .appendingPathComponent("roms", conformingTo: .folder)
                    default:
                        documentDirectory
                    }
                    
                    try FileManager.default.moveItem(at: url, to: romsDirectoryURL.appendingPathComponent(url.lastPathComponent, conformingTo: .fileURL))
                }
            }
            
            beginPopulatingGames(with: try LibraryManager.shared.games().get())
        }
        
        Task {
            switch await task.result {
            case .failure(let error):
                print("\(#function): failed: \(error.localizedDescription)")
            case .success(_):
                print("\(#function): success")
            }
        }
    }
}

extension LibraryController: UISearchControllerDelegate, UISearchResultsUpdating {
    func willDismissSearchController(_ searchController: UISearchController) {
        guard let dataSource, let searchSnapshot else {
            return
        }
        
        Task {
            await dataSource.apply(searchSnapshot)
            self.searchSnapshot = nil
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let dataSource, let searchBarText = searchController.searchBar.text else {
            return
        }
        
        if searchSnapshot == nil {
            searchSnapshot = dataSource.snapshot()
        }
        
        let filteredGames = searchSnapshot?.itemIdentifiers.filter {
            searchBarText.isEmpty ? true : $0.title.lowercased().contains(searchBarText.lowercased())
        } ?? []
        
        var newSnapshot = NSDiffableDataSourceSnapshot<Core, GameBase>()
        newSnapshot.appendSections(LibraryManager.shared.cores)
        LibraryManager.shared.cores.forEach { core in
            newSnapshot.appendItems(filteredGames.filter {
                $0.core == core.rawValue
            }, toSection: core)
        }
        
        Task { await dataSource.apply(newSnapshot) }
    }
}

// MARK: Functions
extension LibraryController {
    @objc fileprivate func openDocumentPickerController() {
        let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: [
            .init("com.antique.Folium-iOS.ds")!,
            .init("com.antique.Folium-iOS.dsi")!,
            .init("com.antique.Folium-iOS.gb")!,
            .init("com.antique.Folium-iOS.gba")!,
            .init("com.antique.Folium-iOS.gbc")!,
            .init("com.antique.Folium-iOS.nds")!,
            .init("com.antique.Folium-iOS.3ds")!,
            .init("com.antique.Folium-iOS.app")!,
            .init("com.antique.Folium-iOS.cia")!,
            .init("com.antique.Folium-iOS.cci")!,
            .init("com.antique.Folium-iOS.cxi")!,
            .init("com.antique.Folium-iOS.n64")!,
            .init("com.antique.Folium-iOS.z64")!,
            // TODO: add .cue,
            .init("com.antique.Folium-iOS.snes")!,
                
            .init("com.rileytestut.delta.game")!,
            .init("com.rileytestut.delta.game.gba")!,
            .init("com.rileytestut.delta.game.gbc")!,
            .init("com.rileytestut.delta.game.ds")!,
        ], asCopy: true)
        documentPickerController.delegate = self
        documentPickerController.allowsMultipleSelection = true
        
        if let sheetPresentationController = documentPickerController.sheetPresentationController {
            sheetPresentationController.detents = [.medium(), .large()]
        }
        
        present(documentPickerController, animated: true)
    }
    
    @objc fileprivate func openSettingsController() {
        
    }
    
    fileprivate func beginAddingSubviews() {
        let searchController = UISearchController()
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshGameLibrary(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    fileprivate func beginConfiguringCollectionView() {
        let gameBoyCellRegistration = UICollectionView.CellRegistration<GameBoyCell, GameBoyGame> { $0.set(text: $2.title, with: .white) }
        let gameBoyAdvanceCellRegistration = UICollectionView.CellRegistration<GameBoyCell, GameBoyAdvanceGame> { $0.set(text: $2.title, with: .white) }
        let nintendo3DSCellRegistration = UICollectionView.CellRegistration<Nintendo3DSCell, Nintendo3DSGame> { $0.set($2, with: self) }
        let nintendo64CellRegistration = UICollectionView.CellRegistration<Nintendo64Cell, Nintendo64Game> { $0.set(text: $2.title, with: .white) }
        let nintendoDSCellRegistration = UICollectionView.CellRegistration<NintendoDSCell, NintendoDSGame> { $0.set(text: $2.title, image: $2.icon, with: .white) }
        let playStation1CellRegistration = UICollectionView.CellRegistration<PlayStation1Cell, PlayStation1Game> { $0.set(text: $2.title, with: .white) }
        let superNESCellRegistration = UICollectionView.CellRegistration<SuperNESCell, SuperNESGame> { $0.set(text: $2.title, with: .white) }
        
        let headerCellRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) {
            var configuration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            configuration.text = self.dataSource?.sectionIdentifier(for: $2.section)?.rawValue ?? ""
            configuration.secondaryText = self.dataSource?.sectionIdentifier(for: $2.section)?.console ?? ""
            $0.contentConfiguration = configuration
            
            if let dataSource = self.dataSource, let core = dataSource.sectionIdentifier(for: $2.section) {
                if core.isBeta {
                    var configuration = UIButton.Configuration.tinted()
                    configuration.baseBackgroundColor = .systemOrange
                    configuration.baseForegroundColor = .systemOrange
                    configuration.attributedTitle = .init("BETA", attributes: .init([
                        .font : UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
                    ]))
                    configuration.buttonSize = .small
                    configuration.cornerStyle = .capsule
                    
                    $0.accessories = [
                        .customView(configuration: .init(customView: UIButton(configuration: configuration), placement: .trailing()))
                    ]
                } else {
                    $0.accessories = []
                }
            }
        }
        
        dataSource = .init(collectionView: collectionView) {
            switch $2 {
            case let gameBoyGame as GameBoyGame:
                $0.dequeueConfiguredReusableCell(using: gameBoyCellRegistration, for: $1, item: gameBoyGame)
            case let gameBoyAdvanceGame as GameBoyAdvanceGame:
                $0.dequeueConfiguredReusableCell(using: gameBoyAdvanceCellRegistration, for: $1, item: gameBoyAdvanceGame)
            case let nintendo3DSGame as Nintendo3DSGame:
                $0.dequeueConfiguredReusableCell(using: nintendo3DSCellRegistration, for: $1, item: nintendo3DSGame)
            case let nintendo64Game as Nintendo64Game:
                $0.dequeueConfiguredReusableCell(using: nintendo64CellRegistration, for: $1, item: nintendo64Game)
            case let nintendoDSGame as NintendoDSGame:
                $0.dequeueConfiguredReusableCell(using: nintendoDSCellRegistration, for: $1, item: nintendoDSGame)
            case let playStation1Game as PlayStation1Game:
                $0.dequeueConfiguredReusableCell(using: playStation1CellRegistration, for: $1, item: playStation1Game)
            case let superNESGame as SuperNESGame:
                $0.dequeueConfiguredReusableCell(using: superNESCellRegistration, for: $1, item: superNESGame)
            default:
                nil
            }
        }
        
        guard let dataSource else {
            return
        }
        
        dataSource.supplementaryViewProvider = {
            $0.dequeueConfiguredReusableSupplementary(using: headerCellRegistration, for: $2)
        }
    }
    
    func beginPopulatingGames(with games: [GameBase]) {
        snapshot = .init()
        guard let dataSource, var snapshot else {
            return
        }
        
        snapshot.appendSections(LibraryManager.shared.cores)
        LibraryManager.shared.cores.forEach { core in
            snapshot.appendItems(games.filter {
                $0.core == core.rawValue
            }, toSection: core)
        }
        
        Task { await dataSource.apply(snapshot) }
    }
}
