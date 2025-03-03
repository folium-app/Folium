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
    
    var selectedItem: MissingFile? = nil
    
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
                [
                    .label(text: itemIdentifier.importance.string, options: .init(tintColor: itemIdentifier.importance.color))
                ]
            }
        }
        
        let headerCellRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) {
            var configuration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            configuration.text = self.dataSource?.itemIdentifier(for: $2)?.core
            if UserDefaults.standard.bool(forKey: "folium.showConsoleNames") {
                configuration.secondaryText = self.dataSource?.sectionIdentifier(for: $2.section)?.console ?? ""
            }
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
        
        beginPopulatingMissingFiles()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let dataSource, let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        selectedItem = item
        
        let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: [
            .item
        ])
        documentPickerController.delegate = self
        if let sheetPresentationController = documentPickerController.sheetPresentationController {
            sheetPresentationController.detents = [.medium(), .large()]
        }
        present(documentPickerController, animated: true)
    }
    
    func beginPopulatingMissingFiles() {
        guard let dataSource else { return }
        
        snapshot = .init()
        guard var snapshot else { return }
        snapshot.appendSections(LibraryManager.shared.cores)
        Task {
            LibraryManager.shared.cores.forEach { core in
                snapshot.appendItems(DirectoryManager.shared.scanDirectoryForMissingFiles(for: core.rawValue)
                    .sorted(by: { $0.name < $1.name }), toSection: core)
                
                if snapshot.itemIdentifiers(inSection: core).isEmpty {
                    snapshot.deleteSections([core])
                }
            }
            
            await dataSource.apply(snapshot)
        }
    }
}

extension MissingFilesController : UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedItem, let url = urls.first else { return }
        do {
            try selectedItem.import(from: url)
            self.selectedItem = nil
            
            beginPopulatingMissingFiles()
        } catch {
            print(error.localizedDescription)
        }
    }
}
