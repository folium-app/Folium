//
//  MissingFilesController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 2/1/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import DirectoryManager
import Foundation
import UIKit

class MissingFilesController : UICollectionViewController {
    fileprivate var dataSource: UICollectionViewDiffableDataSource<Core, MissingFile>? = nil
    fileprivate var snapshot: NSDiffableDataSourceSnapshot<Core, MissingFile>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setLeftBarButton(.init(systemItem: .close, primaryAction: .init(handler: { _ in
            self.dismiss(animated: true)
        })), animated: true)
        prefersLargeTitles(true)
        title = "Missing Files"
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, MissingFile> {
            var configuration = UIListContentConfiguration.subtitleCell()
            configuration.text = $2.nameWithoutExtension
            configuration.secondaryText = $2.name
            configuration.secondaryTextProperties.color = .secondaryLabel
            $0.contentConfiguration = configuration
            
            let itemIdentifier = $2
            $0.accessories = if let details = itemIdentifier.details {
                [
                    .label(text: itemIdentifier.importance.string, options: .init(tintColor: itemIdentifier.importance.color)),
                    .detail(options: .init(tintColor: .systemBlue), actionHandler: {
                        let alertController = UIAlertController(title: "\(itemIdentifier.name) Details", message: details, preferredStyle: .alert)
                        alertController.addAction(.init(title: "Dismiss", style: .cancel))
                        self.present(alertController, animated: true)
                    })
                ]
            } else {
                []
            }
        }
        
        let headerCellRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) {
            var configuration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            configuration.text = self.dataSource?.itemIdentifier(for: $2)?.core
            $0.contentConfiguration = configuration
        }
        
        dataSource = .init(collectionView: collectionView) {
            $0.dequeueConfiguredReusableCell(using: cellRegistration, for: $1, item: $2)
        }
        
        guard let dataSource else {
            return
        }
        
        dataSource.supplementaryViewProvider = {
            $0.dequeueConfiguredReusableSupplementary(using: headerCellRegistration, for: $2)
        }
        
        snapshot = .init()
        guard var snapshot else { return }
        snapshot.appendSections(Core.allCases)
        Task {
            Core.allCases.forEach { core in
                snapshot.appendItems(DirectoryManager.shared.scanDirectoryForMissingFiles(for: core.rawValue), toSection: core)
                
                if snapshot.itemIdentifiers(inSection: core).isEmpty {
                    snapshot.deleteSections([core])
                }
            }
            
            await dataSource.apply(snapshot)
        }
    }
}
