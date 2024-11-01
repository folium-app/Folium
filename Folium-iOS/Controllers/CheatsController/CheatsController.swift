//
//  CheatsController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 21/10/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Cytrus
import Foundation
import UIKit

class CheatsController : UICollectionViewController {
    var dataSource: UICollectionViewDiffableDataSource<String, Cheat>! = nil
    var snapshot: NSDiffableDataSourceSnapshot<String, Cheat>! = nil
    
    var titleIdentifier: UInt64
    init(titleIdentifier: UInt64) {
        self.titleIdentifier = titleIdentifier
        
        let layout = UICollectionViewCompositionalLayout.list(using: .init(appearance: .insetGrouped))
        
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prefersLargeTitles(true)
        title = "Cheats"
        view.backgroundColor = .systemBackground
        
        navigationItem.setLeftBarButton(.init(systemItem: .close, primaryAction: .init(handler: { _ in
            self.dismiss(animated: true)
        })), animated: true)
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Cheat> { cell, indexPath, itemIdentifier in
            var contentConfiguration = UIListContentConfiguration.subtitleCell()
            contentConfiguration.text = itemIdentifier.name
            contentConfiguration.secondaryText = itemIdentifier.comments
            cell.contentConfiguration = contentConfiguration
            
            cell.accessories = if itemIdentifier.enabled {
                [
                    .label(text: "Enabled")
                ]
            } else {
                []
            }
        }
        
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        CheatsManager.shared().loadCheats(titleIdentifier)
        let cheats = CheatsManager.shared().getCheats()
        
        snapshot = .init()
        snapshot.appendSections(["Cheats"])
        snapshot.appendItems(cheats, toSection: "Cheats")
        
        Task {
            await dataSource.apply(snapshot)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        var snapshot = dataSource.snapshot()
        let item = dataSource.itemIdentifier(for: indexPath)
        if let item {
            item.enabled.toggle()
            snapshot.reloadItems([item])
        }
        
        if let item {
            CheatsManager.shared().update(item, at: indexPath.item)
        }
        CheatsManager.shared().saveCheats(titleIdentifier)
        
        Task {
            dataSource.apply(snapshot)
        }
    }
}
