//
//  LibraryController.swift
//  Folium
//
//  Created by Jarrod Norwell on 16/5/2024.
//

import Cytrus
import Foundation
import Grape
import UniformTypeIdentifiers
import UIKit

class LibraryController : UICollectionViewController {
    var dataSource: UICollectionViewDiffableDataSource<Core, AnyHashable>! = nil
    var snapshot: NSDiffableDataSourceSnapshot<Core, AnyHashable>! = nil
    
    var importURLCore: Core? = nil
    var importURL: URL? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.setRightBarButton(.init(systemItem: .add, primaryAction: .init(handler: { _ in
            let documentController = UIDocumentPickerViewController(forOpeningContentTypes: [
                .init("com.antique.Folium-iOS.gba")!,
                .init("com.antique.Folium-iOS.nds")!,
                .init("com.antique.Folium-iOS.nes")!,
                .init("com.antique.Folium-iOS.3ds")!,
                .init("com.antique.Folium-iOS.app")!,
                .init("com.antique.Folium-iOS.cia")!,
                .init("com.antique.Folium-iOS.cci")!,
                .init("com.antique.Folium-iOS.cxi")!,
                .init("com.rileytestut.delta.game.gba")!,
                .init("com.rileytestut.delta.game.ds")!
            ], asCopy: true)
            documentController.allowsMultipleSelection = true
            documentController.delegate = self
            
            if UserDefaults.standard.bool(forKey: "hasAcknowledgedImportGames") {
                self.present(documentController, animated: true)
            } else {
                let alertController = UIAlertController(title: "Import", message: "Select .3ds, .app, .cia, .cci, .cxi, .ds, .gba, .nds and .nes games to be imported into your library",
                                                        preferredStyle: .alert)
                alertController.addAction(.init(title: "Cancel", style: .cancel))
                alertController.addAction(.init(title: "Import", style: .default, handler: { _ in
                    UserDefaults.standard.setValue(true, forKey: "hasAcknowledgedImportGames")
                    self.present(documentController, animated: true)
                }))
                self.present(alertController, animated: true)
            }
        })), animated: true)
        title = "Library"
        collectionView.backgroundColor = .secondarySystemBackground
        
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
            
            var contentConfiguration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            contentConfiguration.text = sectionIdentifier.rawValue
            contentConfiguration.secondaryText = sectionIdentifier.console.rawValue
            supplementaryView.contentConfiguration = contentConfiguration
            
            var buttonConfiguration = UIButton.Configuration.filled()
            buttonConfiguration.buttonSize = .mini
            buttonConfiguration.cornerStyle = .capsule
            buttonConfiguration.image = .init(systemName: "ellipsis")?
                .applyingSymbolConfiguration(.init(weight: .bold))
            
            switch sectionIdentifier {
            case .cytrus:
                let button = UIButton(configuration: buttonConfiguration)
                button.menu = CytrusManager.shared.menu(button, self)
                button.showsMenuAsPrimaryAction = true
                
                supplementaryView.accessories = [
                    .customView(configuration: .init(customView: button, placement: .trailing(), reservedLayoutWidth: .actual))
                ]
            case .grape:
                let button = UIButton(configuration: buttonConfiguration)
                button.menu = GrapeManager.shared.menu(button)
                button.showsMenuAsPrimaryAction = true
                
                supplementaryView.accessories = [
                    .customView(configuration: .init(customView: button, placement: .trailing(), reservedLayoutWidth: .actual))
                ]
            case .kiwi:
                let button = UIButton(configuration: buttonConfiguration)
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
        
        let missingFilesCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, MissingFile> { cell, indexPath, itemIdentifier in
            var backgroundConfiguration = UIBackgroundConfiguration.listPlainCell()
            backgroundConfiguration.backgroundColor = .tertiarySystemBackground
            cell.backgroundConfiguration = backgroundConfiguration
            
            var configuration = UIListContentConfiguration.valueCell()
            configuration.text = itemIdentifier.fileDetails.nameWithoutExtension
            configuration.secondaryText = itemIdentifier.fileDetails.`extension`
            configuration.secondaryTextProperties.color = itemIdentifier.fileDetails.importance.color
            cell.contentConfiguration = configuration
        }
        
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case let missingFile as MissingFile:
                collectionView.dequeueConfiguredReusableCell(using: missingFilesCellRegistration, for: indexPath, item: missingFile)
            case let cytrusGame as CytrusManager.Library.Game:
                collectionView.dequeueConfiguredReusableCell(using: n3dsCellRegistration, for: indexPath, item: cytrusGame)
            case let grapeGame as GrapeManager.Library.Game:
                if grapeGame.gameType == .nds {
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
            var items: [AnyHashable] = []
            switch core {
            case .cytrus:
                LibraryManager.shared.cytrusManager.library.missingFiles.removeAll()
                DirectoryManager.shared.scanDirectoriesForRequiredFiles(core)
                items = if LibraryManager.shared.cytrusManager.library.missingFiles.contains(where: { $0.fileDetails.importance == .required }) {
                    LibraryManager.shared.cytrusManager.library.missingFiles
                } else {
                    LibraryManager.shared.cytrusManager.library.games
                }
            case .grape:
                LibraryManager.shared.grapeManager.library.missingFiles.removeAll()
                DirectoryManager.shared.scanDirectoriesForRequiredFiles(core)
                items = if LibraryManager.shared.grapeManager.library.missingFiles.contains(where: { $0.fileDetails.importance == .required }) {
                    LibraryManager.shared.grapeManager.library.missingFiles
                } else {
                    LibraryManager.shared.grapeManager.library.games
                }
            case .kiwi:
                LibraryManager.shared.kiwiManager.library.missingFiles.removeAll()
                DirectoryManager.shared.scanDirectoriesForRequiredFiles(core)
                items = if LibraryManager.shared.kiwiManager.library.missingFiles.contains(where: { $0.fileDetails.importance == .required }) {
                    LibraryManager.shared.kiwiManager.library.missingFiles
                } else {
                    LibraryManager.shared.kiwiManager.library.games
                }
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
        
        func defaultSkin() -> Skin {
            let bounds = UIScreen.main.bounds
            let width = bounds.width
            let height = bounds.height
            
            let safeAreaInsets = UIApplication.shared.windows[0].safeAreaInsets
            
            let buttons: [Skin.Button] = [
                .init(vibrateWhenTapped: true, vibrationStrength: 3, x: 80, y: height-(180+safeAreaInsets.bottom), width: 60, height: 60, type: .dpadUp),
                .init(vibrateWhenTapped: true, vibrationStrength: 3, x: 80, y: height-(60+safeAreaInsets.bottom), width: 60, height: 60, type: .dpadDown),
                .init(vibrateWhenTapped: true, vibrationStrength: 3, x: 20, y: height-(120+safeAreaInsets.bottom), width: 60, height: 60, type: .dpadLeft),
                .init(vibrateWhenTapped: true, vibrationStrength: 3, x: 140, y: height-(120+safeAreaInsets.bottom), width: 60, height: 60, type: .dpadRight),
            //
                .init(vibrateWhenTapped: true, vibrationStrength: 3, x: width-140, y: height-(180+safeAreaInsets.bottom), width: 60, height: 60, type: .north),
                .init(vibrateWhenTapped: true, vibrationStrength: 3, x: width-80, y: height-(120+safeAreaInsets.bottom), width: 60, height: 60, type: .east),
                .init(vibrateWhenTapped: true, vibrationStrength: 3, x: width-140, y: height-(60+safeAreaInsets.bottom), width: 60, height: 60, type: .south),
                .init(vibrateWhenTapped: true, vibrationStrength: 3, x: width-200, y: height-(120+safeAreaInsets.bottom), width: 60, height: 60, type: .west)
            ]
            
            let buttonsLandscape: [Skin.Button] = [
                .init(vibrateWhenTapped: true, vibrationStrength: 3, x: 80, y: width-(180+safeAreaInsets.bottom), width: 60, height: 60, type: .dpadUp),
                .init(vibrateWhenTapped: true, vibrationStrength: 3, x: 80, y: width-(60+safeAreaInsets.bottom), width: 60, height: 60, type: .dpadDown),
                .init(vibrateWhenTapped: true, vibrationStrength: 3, x: 20, y: width-(120+safeAreaInsets.bottom), width: 60, height: 60, type: .dpadLeft),
                .init(vibrateWhenTapped: true, vibrationStrength: 3, x: 140, y: width-(120+safeAreaInsets.bottom), width: 60, height: 60, type: .dpadRight),
            //
                .init(vibrateWhenTapped: true, vibrationStrength: 3, x: height-140, y: width-(180+safeAreaInsets.bottom), width: 60, height: 60, type: .north),
                .init(vibrateWhenTapped: true, vibrationStrength: 3, x: height-80, y: width-(120+safeAreaInsets.bottom), width: 60, height: 60, type: .east),
                .init(vibrateWhenTapped: true, vibrationStrength: 3, x: height-140, y: width-(60+safeAreaInsets.bottom), width: 60, height: 60, type: .south),
                .init(vibrateWhenTapped: true, vibrationStrength: 3, x: height-200, y: width-(120+safeAreaInsets.bottom), width: 60, height: 60, type: .west)
            ]
            
            let thumbsticks: [Skin.Thumbstick] = [
                .init(x: 20, y: height-(180+safeAreaInsets.bottom), width: 180, height: 180, type: .left),
                .init(x: width-200, y: height-(180+safeAreaInsets.bottom), width: 180, height: 180, type: .right)
            ]
            
            let thumbsticksLandscape: [Skin.Thumbstick] = [
                .init(x: 20, y: width-(180+safeAreaInsets.bottom), width: 180, height: 180, type: .left),
                .init(x: height-200, y: width-(180+safeAreaInsets.bottom), width: 180, height: 180, type: .right)
            ]
            //
            let devices: [Skin.Device] = [
                .init(device: machine, orientation: .portrait, buttons: buttons, screens: [
                    .init(x: 0, y: safeAreaInsets.top, width: width, height: (width / 1.67) + (width / 1.33))
                ], thumbsticks: thumbsticks),
                .init(device: machine, orientation: .landscape, buttons: buttonsLandscape, screens: [
                    .init(x: 0, y: 0, width: height, height: width)
                ], thumbsticks: thumbsticksLandscape)
            ]
            //
            return Skin(author: "Antique", description: "Default skin for the Nintendo 3DS", name: "Cytrus Skin", core: .cytrus, devices: devices)
        }
        
        do {
            let data = try JSONEncoder().encode(defaultSkin())
            
            let string = NSString(data: data, encoding: NSUTF8StringEncoding)
            try string?.write(to: try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("Skin.json", conformingTo: .fileURL), atomically: false, encoding: NSUTF8StringEncoding)
        } catch { }
        
        switch game {
        case let missingFile as MissingFile:
            self.importURL = missingFile.fileDetails.path
            
            let alertController = UIAlertController(title: "Import", message: "Select \(missingFile.fileDetails.name) to import it into \(missingFile.fileDetails.core.rawValue)",
                                                    preferredStyle: .alert)
            alertController.addAction(.init(title: "Cancel", style: .cancel))
            alertController.addAction(.init(title: "Import", style: .default, handler: { _ in
                let documentController = UIDocumentPickerViewController(forOpeningContentTypes: [.archive, .plainText], asCopy: true)
                documentController.shouldShowFileExtensions = true
                documentController.delegate = self
                self.present(documentController, animated: true)
            }))
            present(alertController, animated: true)
            break
        case let cytrusGame as CytrusManager.Library.Game:
            let cytrusController = CytrusDefaultViewController(with: cytrusGame, skin: defaultSkin()) // CytrusEmulationController(cytrusGame.core, cytrusGame)
            cytrusController.modalPresentationStyle = .fullScreen
            present(cytrusController, animated: true)
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

extension LibraryController : UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let documentsDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return
        }
        
        urls.forEach { url in
            switch url.pathExtension.lowercased() {
            case "gba", "nds":
                Task {
                    let toURL = documentsDirectory
                        .appendingPathComponent("Grape", conformingTo: .folder)
                        .appendingPathComponent("roms", conformingTo: .folder)
                        .appendingPathComponent(url.pathExtension.lowercased() == "ds" ? url.lastPathComponent.replacingOccurrences(of: ".ds", with: ".nds") : url.lastPathComponent, conformingTo: .fileURL)
                    
                    try FileManager.default.copyItem(at: url, to: toURL)
                    
                    var snapshot = self.dataSource.snapshot()
                    snapshot.appendItems(LibraryManager.shared.games(.grape, [toURL]), toSection: .grape)
                    await self.dataSource.apply(snapshot)
                }
            case "nes":
                Task {
                    let toURL = documentsDirectory
                        .appendingPathComponent("Kiwi", conformingTo: .folder)
                        .appendingPathComponent("roms", conformingTo: .folder)
                        .appendingPathComponent(url.lastPathComponent, conformingTo: .fileURL)
                    
                    try FileManager.default.copyItem(at: url, to: toURL)
                    
                    var snapshot = self.dataSource.snapshot()
                    snapshot.appendItems(LibraryManager.shared.games(.kiwi, [toURL]), toSection: .kiwi)
                    await self.dataSource.apply(snapshot)
                }
            case "3ds", "app", "cci", "cxi":
                Task {
                    let toURL = documentsDirectory
                        .appendingPathComponent("Cytrus", conformingTo: .folder)
                        .appendingPathComponent("roms", conformingTo: .folder)
                        .appendingPathComponent(url.lastPathComponent, conformingTo: .fileURL)
                    
                    try FileManager.default.copyItem(at: url, to: toURL)
                    
                    var snapshot = self.dataSource.snapshot()
                    snapshot.appendItems(LibraryManager.shared.games(.cytrus, [toURL]), toSection: .cytrus)
                    await self.dataSource.apply(snapshot)
                }
            case "cia":
                Task {
                    let result = Cytrus.shared.import(game: url)
                    
                    var message = ""
                    
                    switch result {
                    case .success:
                        try await populateGames()
                    case .errorFailedToOpenFile:
                        message = "Failed to open file"
                    case .errorFileNotFound:
                        message = "File not found"
                    case .errorAborted:
                        message = "Aborted"
                    case .errorInvalid:
                        message = "Invalid"
                    case .errorEncrypted:
                        message = "Encrypted"
                    @unknown default:
                        fatalError()
                    }
                    
                    if result != .success {
                        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                        alertController.addAction(.init(title: "Cancel", style: .cancel))
                        self.present(alertController, animated: true)
                    }
                }
                break
            default:
                guard let importURL else {
                    return
                }
                
                Task {
                    try FileManager.default.copyItem(at: url, to: importURL)
                    self.importURL = nil
                    
                    try await populateGames()
                }
            }
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
