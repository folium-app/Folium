//
//  CytrusRoomsController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 24/10/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Cytrus
import Foundation
import UIKit

class CytrusRoomsController : UICollectionViewController {
    var dataSource: UICollectionViewDiffableDataSource<String, NetworkRoom>! = nil
    var snapshot: NSDiffableDataSourceSnapshot<String, NetworkRoom>! = nil
    
    let multiplayer = Cytrus.shared.multiplayer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prefersLargeTitles(true)
        title = "Browse Rooms"
        view.backgroundColor = .systemBackground
        
        navigationItem.setLeftBarButton(.init(systemItem: .close, primaryAction: .init(handler: { _ in
            self.dismiss(animated: true)
        })), animated: true)
        if multiplayer.state == .joined {
            navigationItem.setRightBarButton(.init(title: "Leave", primaryAction: .init(attributes: [.destructive], handler: { _ in
                self.multiplayer.disconnect()
                self.navigationItem.rightBarButtonItem = nil
            })), animated: true)
        }
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, NetworkRoom> { cell, indexPath, itemIdentifier in
            var contentConfiguration = UIListContentConfiguration.subtitleCell()
            contentConfiguration.text = itemIdentifier.gameName
            contentConfiguration.secondaryText = itemIdentifier.ip
            contentConfiguration.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = contentConfiguration
            
            let imageView = UIImageView(image: .init(systemName: "lock.fill"))
            
            cell.accessories = if itemIdentifier.hasPassword {
                [
                    .label(text: "\(itemIdentifier.numberOfPlayers)/\(itemIdentifier.maxPlayers)"),
                    .customView(configuration: .init(customView: imageView, placement: .trailing(at: { _ in 1 })))
                ]
            } else {
                [
                    .label(text: "\(itemIdentifier.numberOfPlayers)/\(itemIdentifier.maxPlayers)")
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
            let c = String($1.gameName.prefix(1))
            if !$0.contains(c) {
                $0.append(c)
            }
        }).sorted(by: <)
        
        snapshot.appendSections(characters)
        characters.forEach { c in
            let filteredRooms = rooms.filter { String($0.gameName.prefix(1)) == c }
            snapshot.appendItems(filteredRooms.sorted(by: { $0.gameName < $1.gameName }), toSection: c)
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
        
        let alertController = UIAlertController(title: "Enter Details",
                                                message: "Connecting to a room requires a username\(room.hasPassword ? ", this room also requires a password" : "")",
                                                preferredStyle: .alert)
        alertController.addAction(.init(title: "Cancel", style: .cancel))
        alertController.addAction(.init(title: "Connect", style: .default, handler: { _ in
            guard let textFields = alertController.textFields, let usernameTextField = textFields.first, let username = usernameTextField.text else {
                return
            }
            
            var password: String? = nil
            if room.hasPassword, let passwordTextField = textFields.last {
                password = passwordTextField.text
            }
            
            let alertController = UIAlertController(title: "STATE", message: nil, preferredStyle: .alert)
            alertController.addAction(.init(title: "Dismiss", style: .cancel))
            alertController.addAction(.init(title: "Leave", style: .destructive, handler: { _ in
                self.multiplayer.disconnect()
                
                Task {
                    self.navigationItem.rightBarButtonItem = nil
                    
                    room.numberOfPlayers -= 1
                    
                    var snapshot = self.dataSource.snapshot()
                    snapshot.reloadItems([room])
                    await self.dataSource.apply(snapshot)
                }
            }))
            self.present(alertController, animated: true)
            
            self.multiplayer.connect(to: room, with: username, and: password) { error in
                Task {
                    switch error {
                    case .lostConnection:
                        alertController.title = "Lost Connection"
                        alertController.message = ""
                    case .hostKicked:
                        alertController.title = "Host Kicked"
                        alertController.message = ""
                    case .unknownError:
                        alertController.title = "Unknown Error"
                        alertController.message = ""
                    case .nameCollision:
                        alertController.title = "Name Collision"
                        alertController.message = ""
                    case .macCollision:
                        alertController.title = "MAC Collision"
                        alertController.message = ""
                    case .consoleIdCollision:
                        alertController.title = "Console ID Collision"
                        alertController.message = ""
                    case .wrongVersion:
                        alertController.title = "Wrong Version"
                        alertController.message = ""
                    case .wrongPassword:
                        alertController.title = "Wrong Password"
                        alertController.message = ""
                    case .couldNotConnect:
                        alertController.title = "Could Not Connect"
                        alertController.message = ""
                    case .roomIsFull:
                        alertController.title = "Room Is Full"
                        alertController.message = ""
                    case .hostBanned:
                        alertController.title = "Host Banned"
                        alertController.message = ""
                    case .permissionDenied:
                        alertController.title = "Permission Denied"
                        alertController.message = ""
                    case .noSuchUser:
                        alertController.title = "No Such User"
                        alertController.message = ""
                    @unknown default:
                        alertController.title = ""
                        alertController.message = ""
                    }
                }
            } state: { state in
                Task {
                    if state == .joined {
                        self.navigationItem.setRightBarButton(.init(title: "Leave", primaryAction: .init(attributes: [.destructive], handler: { _ in
                            self.multiplayer.disconnect()
                            self.navigationItem.rightBarButtonItem = nil
                            
                            Task {
                                room.numberOfPlayers -= 1
                                
                                var snapshot = self.dataSource.snapshot()
                                snapshot.reloadItems([room])
                                await self.dataSource.apply(snapshot)
                            }
                        })), animated: true)
                        UserDefaults.standard.set(true, forKey: "isConnectedToRoom")
                        
                        room.numberOfPlayers += 1
                        
                        var snapshot = self.dataSource.snapshot()
                        snapshot.reloadItems([room])
                        await self.dataSource.apply(snapshot)
                    }
                    
                    alertController.title = switch state {
                    case .uninitialized:
                        "Unititialized"
                    case .idle:
                        "Idle"
                    case .joining:
                        "Joining"
                    case .joined:
                        "Joined"
                    case .moderator:
                        "Moderator"
                    default:
                        "Idle"
                    }
                }
            }
        }))
        
        alertController.addTextField { textField in
            textField.placeholder = "Username"
        }
        
        if room.hasPassword {
            alertController.addTextField { textField in
                textField.placeholder = "Password"
            }
        }
        
        self.present(alertController, animated: true)
    }
}
