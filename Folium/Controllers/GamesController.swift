//
//  GamesController.swift
//  Folium
//
//  Created by Jarrod Norwell on 3/6/2026.
//

import ColourKit
import ExtensionsKit
import FontKit
import OnboardingKit
import UniformTypeIdentifiers
import UIKit

class GamesController : UICollectionViewController {
    var selectedSnapshot: SelectedSnapshot = .mandarine {
        didSet {
            guard let dataSource: UICollectionViewDiffableDataSource<String, Game> else {
                return
            }
            
            navigationItem.largeSubtitle = selectedSnapshot.string
            navigationItem.subtitle = navigationItem.largeSubtitle
            
            Task {
                switch selectedSnapshot {
                case .cytrus:
                    break
                case .grape:
                    break
                case .mandarine:
                    guard let mandarineSnapshot else {
                        return
                    }
                    
                    await dataSource.apply(mandarineSnapshot)
                case .tomato:
                    guard let tomatoSnapshot else {
                        return
                    }
                    
                    await dataSource.apply(tomatoSnapshot)
                default:
                    break
                }
            }
        }
    }
    
    var dataSource: UICollectionViewDiffableDataSource<String, Game>? = nil
    var mandarineSnapshot: NSDiffableDataSourceSnapshot<String, Game>? = nil
    var tomatoSnapshot: NSDiffableDataSourceSnapshot<String, Game>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController {
            navigationController.navigationBar.prefersLargeTitles = true
        }
        navigationItem.largeTitle = "Games"
        
        navigationItem.pinnedTrailingGroup = UIBarButtonItemGroup(barButtonItems: [
            UIBarButtonItem(image: UIImage(systemName: "plus"), menu: UIMenu(children: [
                UIMenu(options: .displayInline, preferredElementSize: .medium, children: [
                    UIAction(title: "Game", image: UIImage(systemName: "opticaldisc")) { action in
                        var types: [UTType] = []
                        switch self.selectedSnapshot {
                        case .mandarine:
                            if let bin: UTType = .bin, let cue: UTType = .cue {
                                types.append(contentsOf: [bin, cue])
                            }
                        case .tomato:
                            if let gba: UTType = .gba {
                                types.append(gba)
                            }
                        default:
                            break
                        }
                        
                        let documentPickerController: UIDocumentPickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
                        documentPickerController.allowsMultipleSelection = [.mandarine, .tomato].contains(self.selectedSnapshot)
                        documentPickerController.delegate = self
                        self.present(documentPickerController, animated: true)
                    },
                    UIAction(title: "System File", image: UIImage(systemName: "document"), attributes: .disabled) { action in
                        
                    }
                ])
            ])),
            UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: UIMenu(children: [
                UIMenu(title: "Coleco", image: UIImage(systemName: "cpu"), children: [
                    UIAction(title: "CV", subtitle: "ColecoVision", attributes: .disabled) { action in }
                ]),
                UIMenu(title: "Nintendo", image: UIImage(systemName: "cpu"), children: [
                    UIAction(title: "3DS", subtitle: "Nintendo 3DS", attributes: .disabled) { action in },
                    UIAction(title: "DS/DSi", subtitle: "Nintendo DS/DSi", attributes: .disabled) { action in },
                    UIAction(title: "GBA", subtitle: "Game Boy Advance") { action in
                        self.selectedSnapshot = .tomato
                    },
                    UIAction(title: "NES", subtitle: "Nintendo Entertainment System", attributes: .disabled) { action in },
                    UIAction(title: "SNES", subtitle: "Super Nintendo Entertainment System", attributes: .disabled) { action in }
                ]),
                UIMenu(title: "PlayStation", image: UIImage(systemName: "cpu"), children: [
                    UIAction(title: "PS1", subtitle: "PlayStation 1") { action in
                        self.selectedSnapshot = .mandarine
                    }
                ]),
                UIMenu(title: "SEGA", image: UIImage(systemName: "cpu"), children: [
                    UIAction(title: "GEN/MD", subtitle: "SEGA Genesis/Mega Drive", attributes: .disabled) { action in }
                ])
            ]))
        ], representativeItem: nil)
        navigationItem.title = navigationItem.largeTitle
        navigationItem.style = .browser
        view.backgroundColor = .systemBackground
        
        collectionView.bottomEdgeEffect.style = .soft
        collectionView.topEdgeEffect.style = .soft
        
        let mandarineCell: UICollectionView.CellRegistration<MandarineCell, MandarineGame> = CellManager.Library.mandarineCell(viewController: self)
        let tomatoCell: UICollectionView.CellRegistration<TomatoCell, TomatoGame> = CellManager.Library.tomatoCell(viewController: self)
        
        let supplementaryCell: UICollectionView.SupplementaryRegistration<UICollectionViewListCell> = UICollectionView.SupplementaryRegistration(elementKind: .header) { supplementaryView, elementKind, indexPath in
            var contentConfiguration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            if let dataSource: UICollectionViewDiffableDataSource<String, Game> = self.dataSource,
               let system: String = dataSource.sectionIdentifier(for: indexPath.section) {
                contentConfiguration.text = system
            }
            supplementaryView.contentConfiguration = contentConfiguration
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case let mandarineGame as MandarineGame:
                collectionView.dequeueConfiguredReusableCell(using: mandarineCell, for: indexPath, item: mandarineGame)
            case let tomatoGame as TomatoGame:
                collectionView.dequeueConfiguredReusableCell(using: tomatoCell, for: indexPath, item: tomatoGame)
            default:
                nil
            }
        }
        
        guard let dataSource else {
            return
        }
        
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryCell, for: indexPath)
        }
        
        Task {
            await populateGames()
        }
        
        var whatsNewController: OBControllerWithList {
            let textFont: UIFont = .regular(from: .extraLargeTitle)
            
            let image: UIImage? = UIImage(systemName: "sparkles")
            
            let textConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                           color: .label,
                                                                           font: textFont,
                                                                           text: "What's New")
            
            let secondaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                    color: .secondaryLabel,
                                                                                    font: UIFont.regular(from: .body),
                                                                                    text: "What's new in the latest version of Folium")
            
            let buttons: [(UIButton.Configuration, @MainActor (UIViewController) async -> Void)] = [
                (UIButton.Configuration.glassConfiguration(.large, .capsule, nil, "Continue"), { controller in
                    UserDefaults.standard.set(true, forKey: "folium.2.0.whatsNewComplete")
                    
                    DispatchQueue.main.async {
                        controller.dismiss(animated: true)
                    }
                })
            ]
            
            let cells: [CellConfiguration] = [
                CellConfiguration(image: UIImage(systemName: "square.grid.2x2.fill"), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "Library, Refreshed"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Rewrote the Library screen improving its design which in turn significantly improves user experience")
                )),
                CellConfiguration(image: UIImage(systemName: "gamecontroller.fill"), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "Emulation, Updated"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Rewrote the Emulation screen improving its design and support for landscape")
                )),
                CellConfiguration(image: UIImage(systemName: "list.bullet.badge.ellipsis"), labels: (
                    LabelConfiguration(alignment: .left,
                                       color: .label,
                                       font: UIFont.regular(from: .headline),
                                       text: "Settings, Cleaned Up"),
                    LabelConfiguration(alignment: .left,
                                       color: .secondaryLabel,
                                       font: UIFont.regular(from: .subheadline),
                                       text: "Rewrote the Settings screen separating each system's settings, added descriptions available by swiping left")
                ))
            ]
            
            let configuration: OBControllerWithListConfiguration = OBControllerWithListConfiguration(image: image,
                                                                                                     textConfiguration: textConfiguration,
                                                                                                     secondaryConfiguration: secondaryTextConfiguration,
                                                                                                     tertiaryConfiguration: nil,
                                                                                                     buttons: buttons,
                                                                                                     cells: cells)
            
            let controller: OBControllerWithList = OBControllerWithList(configuration: configuration)
            controller.modalPresentationStyle = .overFullScreen
            return controller
        }
        
        if !UserDefaults.standard.bool(forKey: "folium.2.0.whatsNewComplete") {
            present(whatsNewController, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tabBarController {
            tabBarController.setTabBarHidden(false, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let tabController: TabController = tabBarController as? TabController,
              tabController.game == nil,
              let dataSource: UICollectionViewDiffableDataSource<String, Game>,
              let game: Game = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch game {
        case let mandarineGame as MandarineGame:
            tabController.game = mandarineGame
            
            let mandarineController: MandarineController = MandarineController()
            tabController.switchEmulationController(with: mandarineController)
            tabController.switchSettingsSnapshot(for: .mandarine)
        case let tomatoGame as TomatoGame:
            tabController.game = tomatoGame
            
            let tomatoController: TomatoController = TomatoController()
            tabController.switchEmulationController(with: tomatoController)
            tabController.switchSettingsSnapshot(for: .tomato)
        default:
            break
        }
    }
    
    func generateSnapshot<T>(for snapshot: inout NSDiffableDataSourceSnapshot<String, Game>, for games: [T], type: T.Type) {
        switch T.self {
        case is MandarineGame.Type:
            if let games: [MandarineGame] = games as? [MandarineGame] {
                let sections: [MandarineGame] = games.mapUniqueBy({ game in game }, key: { game in game.prefix })
                let sectionsStrings: [String] = sections.map(\.prefix)
                
                snapshot.appendSections(sectionsStrings.sorted())
                snapshot.sectionIdentifiers.forEach { section in
                    snapshot.appendItems(games.filter { game in game.prefix == section }.sorted(), toSection: section)
                }
            }
        case is TomatoGame.Type:
            if let games: [TomatoGame] = games as? [TomatoGame] {
                let sections: [TomatoGame] = games.mapUniqueBy({ game in game }, key: { game in game.prefix })
                let sectionsStrings: [String] = sections.map(\.prefix)
                
                snapshot.appendSections(sectionsStrings.sorted())
                snapshot.sectionIdentifiers.forEach { section in
                    snapshot.appendItems(games.filter { game in game.prefix == section }.sorted(), toSection: section)
                }
            }
        default:
            break
        }
    }
    
    func populateGames() async {
        if let dataSource, let tabController: TabController = tabBarController as? TabController {
            mandarineSnapshot = NSDiffableDataSourceSnapshot<String, Game>()
            guard var mandarineSnapshot else {
                return
            }
            generateSnapshot(for: &mandarineSnapshot, for: await tabController.gamesManager.games(for: .mandarine), type: MandarineGame.self)
            self.mandarineSnapshot = mandarineSnapshot
            
            tomatoSnapshot = NSDiffableDataSourceSnapshot<String, Game>()
            guard var tomatoSnapshot else {
                return
            }
            generateSnapshot(for: &tomatoSnapshot, for: await tabController.gamesManager.games(for: .tomato), type: TomatoGame.self)
            self.tomatoSnapshot = tomatoSnapshot
            
            Task {
                navigationItem.largeSubtitle = selectedSnapshot.string
                navigationItem.subtitle = navigationItem.largeSubtitle
                
                switch selectedSnapshot {
                case .mandarine:
                    await dataSource.apply(mandarineSnapshot)
                case .tomato:
                    await dataSource.apply(tomatoSnapshot)
                default:
                    break
                }
            }
        }
    }
}

extension GamesController : UIDocumentPickerDelegate, UINavigationControllerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let documentDirectoryURL: URL = .documentDirectoryURL else {
            return
        }
        
        var gamesDirectoryURL: URL = documentDirectoryURL
        switch selectedSnapshot {
        case .mandarine,
                .tomato:
            gamesDirectoryURL.append(component: selectedSnapshot.string)
        default:
            break
        }
        
        gamesDirectoryURL.append(component: "games")
        
        for url in urls {
            let toURL: URL = gamesDirectoryURL.appending(component: url.lastPathComponent)
            do {
                try FileManager.default.copyItem(at: url, to: toURL)
            } catch {
                print(error, error.localizedDescription)
            }
        }
        
        controller.dismiss(animated: true)
    }
}
