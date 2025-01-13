//
//  FoliumSettingsController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 29/10/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation
import SettingsKit
import UIKit

enum FoliumSettingsHeaders : Int, CaseIterable {
    case library
    
    var header: SettingHeader {
        switch self {
        case .library: .init(text: "Library")
        }
    }
    
    static var allHeaders: [SettingHeader] { allCases.map { $0.header } }
}

class FoliumSettingsController : UICollectionViewController {
    var dataSource: UICollectionViewDiffableDataSource<FoliumSettingsHeaders, AHS>! = nil
    var snapshot: NSDiffableDataSourceSnapshot<FoliumSettingsHeaders, AHS>! = nil
    
    let settingsKit = SettingsKit.shared
 
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setLeftBarButton(.init(systemItem: .close, primaryAction: .init(handler: { _ in
            self.dismiss(animated: true)
        })), animated: true)
        prefersLargeTitles(true)
        title = "Settings"
        
        let boolCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, BoolSetting> { cell, indexPath, itemIdentifier in
            var contentConfiguration = UIListContentConfiguration.cell()
            contentConfiguration.text = itemIdentifier.title
            cell.contentConfiguration = contentConfiguration
            
            let toggle = UISwitch(frame: .zero, primaryAction: .init(handler: { action in
                guard let toggle = action.sender as? UISwitch else {
                    return
                }
                
                UserDefaults.standard.set(toggle.isOn, forKey: itemIdentifier.key)
                if let delegate = itemIdentifier.delegate {
                    delegate.didChangeSetting(at: indexPath)
                }
            }))
            toggle.isOn = itemIdentifier.value
            
            cell.accessories = if let details = itemIdentifier.details {
                [
                    .customView(configuration: .init(customView: toggle, placement: .trailing())),
                    .detail(options: .init(tintColor: .systemBlue), actionHandler: {
                        let alertController = UIAlertController(title: "\(itemIdentifier.title) Details", message: details, preferredStyle: .alert)
                        alertController.addAction(.init(title: "Dismiss", style: .cancel))
                        self.present(alertController, animated: true)
                    })
                ]
            } else {
                [
                    .customView(configuration: .init(customView: toggle, placement: .trailing()))
                ]
            }
        }
        
        let headerCellRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            var contentConfiguration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            contentConfiguration.text = self.snapshot.sectionIdentifiers[indexPath.section].header.text
            contentConfiguration.secondaryText = self.snapshot.sectionIdentifiers[indexPath.section].header.secondaryText
            contentConfiguration.secondaryTextProperties.color = .secondaryLabel
            supplementaryView.contentConfiguration = contentConfiguration
        }
        
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case let boolSetting as BoolSetting:
                collectionView.dequeueConfiguredReusableCell(using: boolCellRegistration, for: indexPath, item: boolSetting)
            default:
                nil
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerCellRegistration, for: indexPath)
        }
        
        snapshot = .init()
        snapshot.appendSections(FoliumSettingsHeaders.allCases)
        
        snapshot.appendItems([
            settingsKit.bool(key: "folium.showBetaConsoles",
                             title: "Show Beta Consoles",
                             details: "Determines whether or not to show consoles that are in a beta state",
                             value: UserDefaults.standard.bool(forKey: "folium.showBetaConsoles"),
                             delegate: self),
            settingsKit.bool(key: "folium.showConsoleNames",
                             title: "Show Console Names",
                             details: "Determines whether or not to show the name of the console under the core name",
                             value: UserDefaults.standard.bool(forKey: "folium.showConsoleNames"),
                             delegate: self),
            settingsKit.bool(key: "folium.showGameTitles",
                             title: "Show Game Titles",
                             details: "Determines whether or not to show game titles. Games without artwork always have titles shown",
                             value: UserDefaults.standard.bool(forKey: "folium.showGameTitles"),
                             delegate: self)
        ], toSection: FoliumSettingsHeaders.library)
        
        Task {
            await dataSource.apply(snapshot)
        }
    }
}

extension FoliumSettingsController : SettingDelegate {
    func didChangeSetting(at indexPath: IndexPath) {
        guard let sectionIdentifier = dataSource.sectionIdentifier(for: indexPath.section) else {
            return
        }
        
        var snapshot = dataSource.snapshot()
        let item = snapshot.itemIdentifiers(inSection: sectionIdentifier)[indexPath.item]
        
        switch item {
        case let boolSetting as BoolSetting:
            boolSetting.value = UserDefaults.standard.bool(forKey: boolSetting.key)
        default:
            break
        }
        
        snapshot.reloadItems([item])
        Task {
            await dataSource.apply(snapshot)
        }
    }
}
