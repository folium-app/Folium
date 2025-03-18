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
    actor CytrusCheatDownloader {
        var identifier: UInt64? = nil
        
        init(identifier: UInt64? = nil) {
            self.identifier = identifier
        }
        
        func download() async throws {
            guard let identifier, let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            
            let hex = String(format: "000%llx", identifier).uppercased()
            let saveToURL = if #available(iOS 16, *) {
                documentsDirectory
                    .appending(component: "Cytrus")
                    .appending(component: "cheats")
                    .appending(component: "\(hex).txt")
            } else {
                documentsDirectory
                    .appendingPathComponent("Cytrus", conformingTo: .folder)
                    .appendingPathComponent("cheats", conformingTo: .folder)
                    .appendingPathComponent("\(hex).txt", conformingTo: .fileURL)
            }
            
            let url = URL(string: "https://raw.githubusercontent.com/folium-app/CytrusCheats/refs/heads/main/\(hex).txt")
            guard let url else { return }
            
            let (localURL, _) = try await URLSession.shared.download(from: url)
            try FileManager.default.moveItem(at: localURL, to: saveToURL)
        }
    }
    
    var dataSource: UICollectionViewDiffableDataSource<String, Cheat>! = nil
    var snapshot: NSDiffableDataSourceSnapshot<String, Cheat>! = nil
    
    let cheatsManager = CheatsManager()
    
    var cytrusGame: CytrusGame
    init(_ cytrusGame: CytrusGame) {
        self.cytrusGame = cytrusGame
        super.init(collectionViewLayout: UICollectionViewCompositionalLayout.list(using: .init(appearance: .insetGrouped)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController {
            navigationController.navigationBar.prefersLargeTitles = true
        }
        title = "Cheats"
        view.backgroundColor = .systemBackground
        
        navigationItem.setLeftBarButton(.init(systemItem: .close, primaryAction: .init(handler: { _ in
            self.dismiss(animated: true)
        })), animated: true)
        
        let cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Cheat> = .init { cell, indexPath, itemIdentifier in
            var contentConfiguration = UIListContentConfiguration.subtitleCell()
            contentConfiguration.text = itemIdentifier.name
            contentConfiguration.secondaryText = itemIdentifier.code.trimmingCharacters(in: .whitespacesAndNewlines)
            contentConfiguration.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = contentConfiguration
            
            cell.accessories = if itemIdentifier.enabled { [.label(text: "Enabled")] } else { [] }
        }
        
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        guard let identifier = cytrusGame.identifier else { return }
        cheatsManager.loadCheats(identifier)
        
        if cheatsManager.getCheats().isEmpty {
            let alertController: UIAlertController = .init(title: "Download Cheats", message: "Download cheats for \(cytrusGame.title)?", preferredStyle: .alert)
            alertController.addAction(.init(title: "Download", style: .default, handler: { _ in
                let downloader = CytrusCheatDownloader(identifier: identifier)
                Task {
                    try await downloader.download()
                    await self.reloadData()
                }
            }))
            alertController.addAction(.init(title: "Cancel", style: .cancel))
            present(alertController, animated: true)
        } else {
            Task { await reloadData() }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let identifier = cytrusGame.identifier else { return }
        cheatsManager.saveCheats(identifier)
        
        cytrusGame.update()
    }
    
    func reloadData() async {
        guard let identifier = cytrusGame.identifier else { return }
        print(identifier)
        cheatsManager.loadCheats(identifier)
        
        snapshot = .init()
        snapshot.appendSections(["Cheats"])
        snapshot.appendItems(cheatsManager.getCheats(), toSection: "Cheats")
        await dataSource.apply(snapshot)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let identifier = cytrusGame.identifier else { return }
        
        var snapshot = dataSource.snapshot()
        let item = dataSource.itemIdentifier(for: indexPath)
        if let item {
            item.enabled.toggle()
            snapshot.reloadItems([item])
        }
        
        if let item { cheatsManager.update(item, at: indexPath.item) }
        cheatsManager.saveCheats(identifier)
        
        Task { await dataSource.apply(snapshot) }
    }
}
