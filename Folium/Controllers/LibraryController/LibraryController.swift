//
//  LibraryController.swift
//  Folium
//
//  Created by Jarrod Norwell on 16/5/2024.
//

import Foundation
import Grape
import UIKit

class LibraryController : UICollectionViewController {
    var dataSource: UICollectionViewDiffableDataSource<Core, AnyHashable>! = nil
    var snapshot: NSDiffableDataSourceSnapshot<Core, AnyHashable>! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.setRightBarButton(.init(systemItem: .add), animated: true)
        title = "Library"
        view.backgroundColor = .systemBackground
        
        let refreshControl = UIRefreshControl()
        refreshControl.addAction(.init(handler: { _ in
            Task {
                refreshControl.beginRefreshing()
                try await self.populateGames()
                refreshControl.endRefreshing()
            }
        }), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        
        let headerSupplementaryRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) {
            supplementaryView, elementKind, indexPath in
            guard let sectionIdentifier = self.dataSource.sectionIdentifier(for: indexPath.section) else {
                return
            }
            
            var configuration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            configuration.text = sectionIdentifier.rawValue
            configuration.secondaryText = sectionIdentifier.console.rawValue
            supplementaryView.contentConfiguration = configuration
            
            switch sectionIdentifier {
            case .cytrus:
                supplementaryView.accessories = []
            case .grape:
                var configuration = UIButton.Configuration.filled()
                configuration.buttonSize = .mini
                configuration.cornerStyle = .capsule
                configuration.image = .init(systemName: "ellipsis")?
                    .applyingSymbolConfiguration(.init(weight: .bold))
                
                let button = UIButton(configuration: configuration)
                button.menu = GrapeManager.shared.menu(button)
                button.showsMenuAsPrimaryAction = true
                
                supplementaryView.accessories = [
                    .customView(configuration: .init(customView: button, placement: .trailing(), reservedLayoutWidth: .actual))
                ]
            case .kiwi:
                var configuration = UIButton.Configuration.filled()
                configuration.buttonSize = .mini
                configuration.cornerStyle = .capsule
                configuration.image = .init(systemName: "ellipsis")?
                    .applyingSymbolConfiguration(.init(weight: .bold))
                
                let button = UIButton(configuration: configuration)
                button.menu = KiwiManager.shared.menu(button)
                button.showsMenuAsPrimaryAction = true
                
                supplementaryView.accessories = [
                    .customView(configuration: .init(customView: button, placement: .trailing(), reservedLayoutWidth: .actual))
                ]
            }
        }
        
        let n3dsCellRegistration = UICollectionView.CellRegistration<N3DSDefaultLibraryCell, CytrusManager.Library.Game> { cell, indexPath, itemIdentifier in
            cell.set(itemIdentifier, self)
        }
        
        let ndsCellRegistration = UICollectionView.CellRegistration<NDSDefaultLibraryCell, GrapeManager.Library.Game> { cell, indexPath, itemIdentifier in
            cell.set(itemIdentifier, self)
        }
        
        let ndsGbaCellRegistration = UICollectionView.CellRegistration<NDSGBADefaultLibraryCell, GrapeManager.Library.Game> { cell, indexPath, itemIdentifier in
            cell.set(itemIdentifier, self)
        }
        
        let nesCellRegistration = UICollectionView.CellRegistration<NESDefaultLibraryCell, KiwiManager.Library.Game> { cell, indexPath, itemIdentifier in
            cell.set(itemIdentifier, self)
        }
        
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case let cytrusGame as CytrusManager.Library.Game:
                collectionView.dequeueConfiguredReusableCell(using: n3dsCellRegistration, for: indexPath, item: cytrusGame)
            case let grapeGame as GrapeManager.Library.Game:
                if grapeGame.fileDetails.extension == "nds" {
                    collectionView.dequeueConfiguredReusableCell(using: ndsCellRegistration, for: indexPath, item: grapeGame)
                } else {
                    collectionView.dequeueConfiguredReusableCell(using: ndsGbaCellRegistration, for: indexPath, item: grapeGame)
                }
            case let kiwiGame as KiwiManager.Library.Game:
                collectionView.dequeueConfiguredReusableCell(using: nesCellRegistration, for: indexPath, item: kiwiGame)
            default:
                nil
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerSupplementaryRegistration, for: indexPath)
        }
        
        Task {
            try await populateGames()
        }
    }
    
    func populateGames() async throws {
        try LibraryManager.shared.library()
        
        snapshot = .init()
        snapshot.appendSections(Core.cores)
        Core.cores.forEach { core in
            let items: [AnyHashable] = switch core {
            case .cytrus:
                LibraryManager.shared.cytrusManager.library.games
            case .grape:
                LibraryManager.shared.grapeManager.library.games
            case .kiwi:
                LibraryManager.shared.kiwiManager.library.games
            }
            
            snapshot.appendItems(items, toSection: core)
        }
        
        await dataSource.apply(snapshot)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let game = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch game {
        case let grapeGame as GrapeManager.Library.Game:
            let grapeController = GrapeEmulationController(grapeGame.core, grapeGame)
            grapeController.modalPresentationStyle = .fullScreen
            present(grapeController, animated: true)
        case let kiwiGame as KiwiManager.Library.Game:
            let kiwiController = KiwiEmulationController(kiwiGame.core, kiwiGame)
            kiwiController.modalPresentationStyle = .fullScreen
            present(kiwiController, animated: true)
        default:
            break
        }
    }
}

extension LibraryController : UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        
        let games = snapshot.itemIdentifiers
        let filteredGames = games.filter {
            switch $0 {
            case let cytrusGame as CytrusManager.Library.Game:
                return cytrusGame.title.lowercased().contains(text.lowercased())
            case let grapeGame as GrapeManager.Library.Game:
                return grapeGame.title.lowercased().contains(text.lowercased())
            case let kiwiGame as KiwiManager.Library.Game:
                return kiwiGame.title.lowercased().contains(text.lowercased())
            default:
                return false
            }
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Core, AnyHashable>()
        snapshot.appendSections(Core.cores)
        filteredGames.forEach { game in
            switch game {
            case let cytrusGame as CytrusManager.Library.Game:
                snapshot.appendItems([cytrusGame], toSection: cytrusGame.core)
            case let grapeGame as GrapeManager.Library.Game:
                snapshot.appendItems([grapeGame], toSection: grapeGame.core)
            case let kiwiGame as KiwiManager.Library.Game:
                snapshot.appendItems([kiwiGame], toSection: kiwiGame.core)
            default:
                break
            }
        }
        
        Task {
            await dataSource.apply(snapshot)
        }
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        Task {
            try await populateGames()
        }
    }
}
