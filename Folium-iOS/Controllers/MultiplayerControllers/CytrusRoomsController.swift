//
//  CytrusRoomsController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 24/10/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

@preconcurrency import Cytrus
import Foundation
import UIKit

class CytrusRoomsController : UICollectionViewController {
    var dataSource: UICollectionViewDiffableDataSource<String, CytrusNetworkRoom>! = nil
    var snapshot: NSDiffableDataSourceSnapshot<String, CytrusNetworkRoom>! = nil
    
    let multiplayer = Cytrus.shared.multiplayer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prefersLargeTitles(true)
        title = "Browse Rooms"
        view.backgroundColor = .systemBackground
        
        navigationItem.setLeftBarButton(.init(systemItem: .close, primaryAction: .init(handler: { _ in
            self.dismiss(animated: true)
        })), animated: true)
        /*
        if multiplayer.state == .joined {
            navigationItem.setRightBarButton(.init(title: "Leave", primaryAction: .init(attributes: [.destructive], handler: { _ in
                self.multiplayer.disconnect()
                self.navigationItem.rightBarButtonItem = nil
            })), animated: true)
        }*/
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, CytrusNetworkRoom> { cell, indexPath, itemIdentifier in
            var contentConfiguration = UIListContentConfiguration.subtitleCell()
            contentConfiguration.text = itemIdentifier.preferredGame
            contentConfiguration.secondaryText = itemIdentifier.ip
            contentConfiguration.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = contentConfiguration
            
            let imageView = UIImageView(image: .init(systemName: "lock.fill"))
            
            cell.accessories = if itemIdentifier.hasPassword {
                [
                    .label(text: "\(itemIdentifier.numberPlayers)/\(itemIdentifier.maxPlayers)"),
                    .customView(configuration: .init(customView: imageView, placement: .trailing(at: { _ in 1 })))
                ]
            } else {
                [
                    .label(text: "\(itemIdentifier.numberPlayers)/\(itemIdentifier.maxPlayers)")
                ]
            }
        }
        
        let headerCellRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            let section = self.snapshot.sectionIdentifiers[indexPath.section]
            
            var contentConfiguration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            contentConfiguration.text = section
            supplementaryView.contentConfiguration = contentConfiguration
            
            let roomsCount = self.snapshot.itemIdentifiers(inSection: section).count
            supplementaryView.accessories = [
                .label(text: "\(roomsCount) \(roomsCount == 1 ? "room" : "rooms")", options: .init(tintColor: .secondaryLabel,
                                                                                                   font: contentConfiguration.textProperties.font))
            ]
        }
        
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerCellRegistration, for: indexPath)
        }
        
        let rooms = MultiplayerManager.shared().rooms()
        
        snapshot = .init()
        let characters = rooms.reduce(into: [String](), {
            let c = String($1.preferredGame.prefix(1))
            if !$0.contains(c) {
                $0.append(c)
            }
        }).sorted(by: <)
        
        snapshot.appendSections(characters)
        characters.forEach { c in
            let filteredRooms = rooms.filter { String($0.preferredGame.prefix(1)) == c }
            snapshot.appendItems(filteredRooms.sorted(by: { $0.preferredGame < $1.preferredGame }), toSection: c)
        }
        
        Task {
            await dataSource.apply(snapshot)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let room = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        let configuration: UICollectionViewCompositionalLayoutConfiguration = .init()
        configuration.interSectionSpacing = 20
        
        let collectionViewLayout: UICollectionViewCompositionalLayout = .init(sectionProvider: { sectionIndex, layoutEnvironment in
            if sectionIndex == 0 {
                let item: NSCollectionLayoutItem = .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)))
                
                let group: NSCollectionLayoutGroup = .horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)), subitems: [item])
                group.interItemSpacing = .fixed(20)
                
                let section: NSCollectionLayoutSection = .init(group: group)
                // section.contentInsets = .init(top: 40, leading: 20, bottom: 0, trailing: 20)
                section.interGroupSpacing = 20
                
                return section
            } else {
                let item: NSCollectionLayoutItem = .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)))
                
                let group: NSCollectionLayoutGroup = .horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)), subitems: [item])
                group.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
                group.interItemSpacing = .fixed(20)
                
                let header: NSCollectionLayoutBoundarySupplementaryItem = .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)),
                                                                                elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                header.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
                
                let footer: NSCollectionLayoutBoundarySupplementaryItem = .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)),
                                                                                elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
                footer.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
                
                let section: NSCollectionLayoutSection = .init(group: group)
                section.boundarySupplementaryItems = [header/*, footer*/]
                section.contentInsets = .init(top: 0, leading: 0, bottom: sectionIndex == 0 ? 0 : 8, trailing: 0)
                section.interGroupSpacing = 20
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                return section
            }
        }, configuration: configuration)
        
        let detailsViewController: CytrusRoomDetailsController = .init(room, collectionViewLayout)
        if let sheetPresentationController = detailsViewController.sheetPresentationController {
            sheetPresentationController.detents = [.large()]
            sheetPresentationController.prefersGrabberVisible = true
            sheetPresentationController.preferredCornerRadius = .smallCornerRadius + 8
        }
        present(detailsViewController, animated: true)
    }
}
