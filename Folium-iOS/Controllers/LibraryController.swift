//
//  LibraryController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 4/7/2024.
//

import AppleArchive
import Cytrus
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation
import System
import UIKit
import WidgetKit
import CoreMotion

class LibraryController: UICollectionViewController {
    fileprivate var dataSource: UICollectionViewDiffableDataSource<Core, GameBase>? = nil
    fileprivate var snapshot: NSDiffableDataSourceSnapshot<Core, GameBase>? = nil
    fileprivate var searchSnapshot: NSDiffableDataSourceSnapshot<Core, GameBase>? = nil
    
    let pedometer = CMPedometer()
    
    var contentOffsetY: CGFloat? = nil
    var weeTitle: String? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        prefersLargeTitles(true)
        title = "Library"
        
        let user = Auth.auth().currentUser
        let userDefaults = UserDefaults(suiteName: "group.com.antique.Folium")
        Task {
            if AppStoreCheck.shared.additionalFeaturesAreAllowed, let user {
                let document = Firestore.firestore().collection("users").document(user.uid)
                let doc = try await document.getDocument()
                if doc.exists {
                    if let userDefaults {
                        userDefaults.set(try JSONEncoder().encode(try await document.getDocument(as: User.self)), forKey: "user")
                    }
                } else {
                    if let displayName = user.displayName,
                       let firstName = displayName.components(separatedBy: " ").first, let lastName = displayName.components(separatedBy: " ").last {
                        let user = User(games: [], name: "\(firstName) \(lastName)")
                        try document.setData(from: user)
                        
                        if let userDefaults {
                            userDefaults.set(try JSONEncoder().encode(user), forKey: "user")
                        }
                    }
                }
                
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        
        // TODO: this does not work 100%
        if let hourBefore = Calendar.current.date(byAdding: .hour, value: -8, to: .now) {
            pedometer.queryPedometerData(from: hourBefore, to: .now) { data, error in
                if let error {
                    print("error = \(error.localizedDescription)")
                } else {
                    if let data {
                        print("steps = \(data.numberOfSteps)")
                        Cytrus.shared.stepsPerHour = data.numberOfSteps.uint16Value
                    }
                }
            }
        }
        
        
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
            guard let _ = weeTitle else {
                return
            }
            
            navigationItem.perform(NSSelectorFromString("_setWeeTitle:"), with: weeTitle)
        }
        
        var children: [UIMenuElement] = [
            UIAction(title: "App Settings", image: .init(systemName: "leaf"), handler: { _ in
                var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                configuration.headerMode = .supplementary
                let listCollectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
                
                let foliumSettingsController = UINavigationController(rootViewController: FoliumSettingsController(collectionViewLayout: listCollectionViewLayout))
                foliumSettingsController.modalPresentationStyle = .fullScreen
                self.present(foliumSettingsController, animated: true)
            }),
            UIMenu(title: "Core Settings", children: [
                UIMenu(title: "Cytrus", children: [
                    UIAction(title: "Browse Rooms", image: .init(systemName: "magnifyingglass"), handler: { _ in
                        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                        configuration.headerMode = .supplementary
                        let listCollectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
                        
                        let roomsController = UINavigationController(rootViewController: CytrusRoomsController(collectionViewLayout: listCollectionViewLayout))
                        roomsController.modalPresentationStyle = .fullScreen
                        self.present(roomsController, animated: true)
                    }),
                    UIAction(title: "Settings", image: .init(systemName: "gearshape"), handler: { _ in
                        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                        configuration.headerMode = .supplementary
                        let listCollectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
                        
                        let cytrusSettingsController = UINavigationController(rootViewController: CytrusSettingsController(collectionViewLayout: listCollectionViewLayout))
                        cytrusSettingsController.modalPresentationStyle = .fullScreen
                        self.present(cytrusSettingsController, animated: true)
                    }),
                ]),
                UIAction(title: "Grape", handler: { _ in
                    var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                    configuration.headerMode = .supplementary
                    let listCollectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
                    
                    let grapeSettingsController = UINavigationController(rootViewController: GrapeSettingsController(collectionViewLayout: listCollectionViewLayout))
                    grapeSettingsController.modalPresentationStyle = .fullScreen
                    self.present(grapeSettingsController, animated: true)
                })
            ])
        ]
        
        if AppStoreCheck.shared.additionalFeaturesAreAllowed {
            if Auth.auth().currentUser == nil {
                children.append(UIMenu(title: "Account Settings", options: .displayInline, children: [
                    UIAction(title: "Sign In", image: .init(systemName: "arrow.right"), handler: { _ in
                        let authenticationController = AuthenticationController()
                        authenticationController.modalPresentationStyle = .fullScreen
                        self.present(authenticationController, animated: true)
                    })
                ]))
            } else {
                children.append(UIMenu(title: "Account Settings", options: .displayInline, children: [
                    UIAction(title: "Sign Out", image: .init(systemName: "arrow.right"), attributes: [.destructive], handler: { _ in
                        do {
                            try Auth.auth().signOut()
                            
                            let authenticationController = AuthenticationController()
                            authenticationController.modalPresentationStyle = .fullScreen
                            self.present(authenticationController, animated: true)
                        } catch {
                            print(#function, error, error.localizedDescription)
                        }
                    })
                ]))
            }
        }
        
        navigationItem.setRightBarButtonItems([
            .init(image: .init(systemName: "gearshape"), menu: .init(children: children)),
            .init(title: "Import", primaryAction: .init(handler: { _ in
                self.openDocumentPickerController()
            }))
        ], animated: true)
        
        beginAddingSubviews()
        beginConfiguringCollectionView()
        
        populateGameLibrary()
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if UserDefaults.standard.bool(forKey: "shouldShowArchived") {
            let alertController = UIAlertController(title: "Archived", message: "Archive has been performed, previously available games and system files can now be found within the Files app inside of the archive.aar archive\n\nArchive ensures a smooth transition between updates by resetting each cores directory structure", preferredStyle: .alert)
            alertController.addAction(.init(title: "Dismiss", style: .cancel, handler: { _ in
                self.extractArchivedDocumentsDirectoryIfPossible()
            }))
            alertController.addAction(.init(title: "Open Files", style: .default, handler: { _ in
                if let sharedUrl = URL(string: "shareddocuments://\(documentsDirectory.path)") {
                    if UIApplication.shared.canOpenURL(sharedUrl) {
                        UIApplication.shared.open(sharedUrl, options: [:])
                    }
                }
            }))
            present(alertController, animated: true)
            
            
            UserDefaults.standard.set(false, forKey: "shouldShowArchived")
        }
        
        extractArchivedDocumentsDirectoryIfPossible()
    }
    
    func extractArchivedDocumentsDirectoryIfPossible() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let aarURL = if #available(iOS 16, *) {
            documentsDirectory.appending(component: "archive.aar")
        } else {
            documentsDirectory.appendingPathComponent("archive.aar")
        }
        
        if FileManager.default.fileExists(atPath: aarURL.path) {
            let alertController = UIAlertController(title: "Extract",
                                                    message: "Do you want to extract the previous archive.aar returning Folium to its previous state?\n\nFolium may appear frozen during this operation, please wait until it is finished and your games are displayed",
                                                    preferredStyle: .alert)
            alertController.addAction(.init(title: "Dismiss", style: .cancel))
            alertController.addAction(.init(title: "Extract", style: .default, handler: { _ in
                do {
                    let archiveFilePath = FilePath(aarURL.path)


                    guard let readFileStream = ArchiveByteStream.fileStream(
                            path: archiveFilePath,
                            mode: .readOnly,
                            options: [ ],
                            permissions: FilePermissions(rawValue: 0o644)) else {
                        return
                    }
                    
                    defer {
                        try? readFileStream.close()
                    }
                    
                    guard let decompressStream = ArchiveByteStream.decompressionStream(readingFrom: readFileStream) else {
                        return
                    }
                    
                    defer {
                        try? decompressStream.close()
                    }
                    
                    guard let decodeStream = ArchiveStream.decodeStream(readingFrom: decompressStream) else {
                        print("unable to create decode stream")
                        return
                    }
                    
                    defer {
                        try? decodeStream.close()
                    }
                    
                    let decompressDestination = FilePath(documentsDirectory.path)
                    
                    guard let extractStream = ArchiveStream.extractStream(extractingTo: decompressDestination,
                                                                          flags: [ .ignoreOperationNotPermitted ]) else {
                        return
                    }
                    
                    defer {
                        try? extractStream.close()
                    }
                    
                    _ = try ArchiveStream.process(readingFrom: decodeStream,
                                                      writingTo: extractStream)
                    
                    try FileManager.default.removeItem(atPath: archiveFilePath.string)
                    
                    self.populateGameLibrary()
                } catch {}
            }))
            present(alertController, animated: true)
        }
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
        case let playStation1Game as PlayStation1Game:
            guard let skin = lycheeSkin else {
                return
            }
            
            let playStation1EmulationController = PlayStation1EmulationController(game: playStation1Game, skin: skin)
            playStation1EmulationController.modalPresentationStyle = .fullScreen
            present(playStation1EmulationController, animated: true)
        case let gameBoyGame as GameBoyGame:
            guard let skin = mangoSkin else {
                return
            }
            
            let gameBoyEmulationController = GameBoyEmulationController(game: gameBoyGame, skin: skin)
            gameBoyEmulationController.modalPresentationStyle = .fullScreen
            present(gameBoyEmulationController, animated: true)
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
                    case "ds", "nds":
                        documentDirectory.appendingPathComponent("Grape", conformingTo: .folder)
                            .appendingPathComponent("roms", conformingTo: .folder)
                    case "3ds", "app", "cci", "cxi":
                        documentDirectory.appendingPathComponent("Cytrus", conformingTo: .folder)
                            .appendingPathComponent("roms", conformingTo: .folder)
                    case "n64", "z64":
                        documentDirectory.appendingPathComponent("Guava", conformingTo: .folder)
                            .appendingPathComponent("roms", conformingTo: .folder)
                    case "bin", "cue":
                        documentDirectory.appendingPathComponent("Lychee", conformingTo: .folder)
                            .appendingPathComponent("roms", conformingTo: .folder)
                    case "sfc", "smc":
                        documentDirectory.appendingPathComponent("Mango", conformingTo: .folder)
                            .appendingPathComponent("roms", conformingTo: .folder)
                    case "gb", "gbc":
                        documentDirectory.appendingPathComponent("Tomato", conformingTo: .folder)
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
            .init("com.antique.Folium-iOS.app")!,
            .init("com.antique.Folium-iOS.cci")!,
            .init("com.antique.Folium-iOS.cia")!,
            .init("com.antique.Folium-iOS.cxi")!,
            .init("com.antique.Folium-iOS.3ds")!,
            .init("com.antique.Folium-iOS.sfc")!,
            .init("com.antique.Folium-iOS.smc")!,
            .init("com.antique.Folium-iOS.ds")!,
            .init("com.antique.Folium-iOS.nds")!,
            
            .init("com.retroarch.mtl")!,
            .init("com.retroarch.obj")!,
            .init("com.retroarch.iso")!,
            .init("com.retroarch.bin")!,
            .init("com.retroarch.chd")!,
            .init("com.retroarch.cue")!,
            .init("com.retroarch.p")!,
            .init("com.retroarch.tzx")!,
            .init("com.retroarch.t81")!,
            .init("com.retroarch.a52")!,
            .init("com.retroarch.hex")!,
            .init("com.retroarch.arduboy")!,
            .init("com.retroarch.xfd")!,
            .init("com.retroarch.atr")!,
            .init("com.retroarch.dcm")!,
            .init("com.retroarch.cas")!,
            .init("com.retroarch.atx")!,
            .init("com.retroarch.car")!,
            .init("com.retroarch.rom")!,
            .init("com.retroarch.com")!,
            .init("com.retroarch.xex")!,
            .init("com.retroarch.m3u")!,
            .init("com.retroarch.md")!,
            .init("com.retroarch.smd")!,
            .init("com.retroarch.gen")!,
            .init("com.retroarch.68k")!,
            .init("com.retroarch.sgd")!,
            .init("com.retroarch.ri")!,
            .init("com.retroarch.mx1")!,
            .init("com.retroarch.mx2")!,
            .init("com.retroarch.col")!,
            .init("com.retroarch.dsk")!,
            .init("com.retroarch.sg")!,
            .init("com.retroarch.sc")!,
            .init("com.retroarch.sf")!,
            .init("com.retroarch.nes")!,
            .init("com.retroarch.pk4")!,
            .init("com.retroarch.sfc")!,
            .init("com.retroarch.smc")!,
            .init("com.retroarch.bml")!,
            .init("com.retroarch.gb")!,
            .init("com.retroarch.gbc")!,
            .init("com.retroarch.st")!,
            .init("com.retroarch.bs")!,
            .init("com.retroarch.swc")!,
            .init("com.retroarch.fig")!,
            .init("com.retroarch.game")!,
            .init("com.retroarch.88")!,
            .init("com.retroarch.sna")!,
            .init("com.retroarch.tap")!,
            .init("com.retroarch.cdt")!,
            .init("com.retroarch.voc")!,
            .init("com.retroarch.cpr")!,
            .init("com.retroarch.chai")!,
            .init("com.retroarch.chailove")!,
            .init("com.retroarch.gd3")!,
            .init("com.retroarch.gd7")!,
            .init("com.retroarch.dx2")!,
            .init("com.retroarch.bsx")!,
            .init("com.retroarch.3ds")!,
            .init("com.retroarch.3dsx")!,
            .init("com.retroarch.elf")!,
            .init("com.retroarch.axf")!,
            .init("com.retroarch.cci")!,
            .init("com.retroarch.cxi")!,
            .init("com.retroarch.app")!,
            .init("com.retroarch.kcr")!,
            .init("com.retroarch.nds")!,
            .init("com.retroarch.ids")!,
            .init("com.retroarch.ogv")!,
            .init("com.retroarch.dirksimple")!,
            .init("com.retroarch.dol")!,
            .init("com.retroarch.gcm")!,
            .init("com.retroarch.wbfs")!,
            .init("com.retroarch.ciso")!,
            .init("com.retroarch.gcz")!,
            .init("com.retroarch.wad")!,
            .init("com.retroarch.dff")!,
            .init("com.retroarch.tgc")!,
            .init("com.retroarch.rvz")!,
            .init("com.retroarch.wia")!,
            .init("com.retroarch.exe")!,
            .init("com.retroarch.bat")!,
            .init("com.retroarch.conf")!,
            .init("com.retroarch.dosz")!,
            .init("com.retroarch.ins")!,
            .init("com.retroarch.img")!,
            .init("com.retroarch.ima")!,
            .init("com.retroarch.vhd")!,
            .init("com.retroarch.jrc")!,
            .init("com.retroarch.tc")!,
            .init("com.retroarch.m3u8")!,
            .init("com.retroarch.cgb")!,
            .init("com.retroarch.sgb")!,
            .init("com.retroarch.psexe")!,
            .init("com.retroarch.pbp")!,
            .init("com.retroarch.ecm")!,
            .init("com.retroarch.mds")!,
            .init("com.retroarch.psf")!,
            .init("com.retroarch.ldb")!,
            .init("com.retroarch.easyrpg")!,
            .init("com.retroarch.wl6")!,
            .init("com.retroarch.n3d")!,
            .init("com.retroarch.sod")!,
            .init("com.retroarch.sdm")!,
            .init("com.retroarch.wl1")!,
            .init("com.retroarch.pk3")!,
            .init("com.retroarch.cart")!,
            .init("com.retroarch.0")!,
            .init("com.retroarch.ch8")!,
            .init("com.retroarch.sms")!,
            .init("com.retroarch.bms")!,

            .init("com.rileytestut.delta.game")!,
            .init("com.rileytestut.delta.game.snes")!,
            .init("com.rileytestut.delta.game.gba")!,
            .init("com.rileytestut.delta.skin")!,
            .init("com.rileytestut.delta.game.gbc")!,
            .init("com.rileytestut.delta.game.nes")!,
            .init("com.rileytestut.delta.game.n64")!,
            .init("com.rileytestut.delta.game.ds")!,
            .init("com.rileytestut.delta.game.genesis")!
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
        let nintendoDSCellRegistration = UICollectionView.CellRegistration<NintendoDSCell, NintendoDSGame> { $0.set($2, with: self) }
        let playStation1CellRegistration = UICollectionView.CellRegistration<PlayStation1Cell, PlayStation1Game> { $0.set(text: $2.title, with: .white) }
        let superNESCellRegistration = UICollectionView.CellRegistration<SuperNESCell, SuperNESGame> { $0.set($2, with: self) }
        
        let headerCellRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) {
            var configuration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            configuration.text = self.dataSource?.sectionIdentifier(for: $2.section)?.rawValue ?? ""
            // configuration.secondaryText = self.dataSource?.sectionIdentifier(for: $2.section)?.console ?? ""
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
        if games.isEmpty {
            let alertController = UIAlertController(title: "Import Games",
                                                    message: "No games could be found, do you want to import some?",
                                                    preferredStyle: .alert)
            alertController.addAction(.init(title: "Cancel", style: .cancel))
            alertController.addAction(.init(title: "Import", style: .default, handler: { _ in
                self.openDocumentPickerController()
            }))
            present(alertController, animated: true)
        } else {
            snapshot = .init()
            guard let dataSource, var snapshot else {
                return
            }
            
            snapshot.appendSections(LibraryManager.shared.coresWithGames)
            LibraryManager.shared.coresWithGames.forEach { core in
                snapshot.appendItems(games.filter {
                    $0.core == core.rawValue
                }.sorted(by: { $0.title < $1.title }), toSection: core)
            }
            
            Task { await dataSource.apply(snapshot) }
        }
    }
}
