//
//  GameIntermediateController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 14/3/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Cytrus
import Foundation
import LayoutManager
import UIKit

class MaskedVisualEffectView : UIVisualEffectView {
    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradientMask()
    }
    
    private func applyGradientMask() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor.black.cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.9, 1.0]
        
        layer.mask = gradientLayer
    }
}

class GameArtworkTitleCell : UICollectionViewCell {
    var imageView: UIImageView? = nil
    var textLabel: UILabel? = nil, secondaryTextLabel: UILabel? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = .init()
        guard let imageView else { return }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        let effect: UIBlurEffect = .init(style: .systemUltraThinMaterial) // .init(style: .init(rawValue: 1100) ?? .systemUltraThinMaterial)
        
        let visualEffectView: MaskedVisualEffectView = .init(effect: effect)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(visualEffectView)
        
        let largeTitleTextStyle: UIFont.TextStyle = if #available(iOS 17, *) { .extraLargeTitle2 } else { .largeTitle }
        
        textLabel = .init()
        guard let textLabel else { return }
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: largeTitleTextStyle).pointSize)
        textLabel.numberOfLines = 3
        textLabel.textAlignment = .center
        addSubview(textLabel)
        
        secondaryTextLabel = .init()
        guard let secondaryTextLabel else { return }
        secondaryTextLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryTextLabel.font = .preferredFont(forTextStyle: .title2)
        secondaryTextLabel.textAlignment = .center
        secondaryTextLabel.textColor = .secondaryLabel
        addSubview(secondaryTextLabel)
        
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        visualEffectView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 50).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
        secondaryTextLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 8).isActive = true
        secondaryTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        secondaryTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
        bottomAnchor.constraint(equalTo: secondaryTextLabel.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ header: Header, _ viewController: UIViewController) {
        guard let imageView, let textLabel, let secondaryTextLabel else { return }
        if let icon = header.icon {
            switch header.core {
            case .cytrus:
                if let decoded = icon.decodeRGB565(width: 48, height: 48) {
                    imageView.image = decoded
                }
            default: break
            }
        }
        if let iconBuffer = header.iconBuffer {
            switch header.core {
            case .grape:
                if let cgImage = CGImage.cgImage(iconBuffer, 32, 32) {
                    imageView.image = .init(cgImage: cgImage)
                }
            default: break
            }
        }
        textLabel.text = header.text
        secondaryTextLabel.text = header.secondaryText
    }
}

class GamePlayCell : UICollectionViewCell {
    var button: UIButton? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var configuration: UIButton.Configuration = .filled()
        configuration.buttonSize = .large
        configuration.cornerStyle = .large
        configuration.attributedTitle = .init("Play", attributes: .init([
            .font : UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        ]))
        configuration.image = .init(systemName: "play.fill")?
            .applyingSymbolConfiguration(.init(scale: .medium))
        configuration.imagePadding = 8
        
        button = .init(configuration: configuration, primaryAction: nil)
        guard let button else { return }
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        
        button.topAnchor.constraint(equalTo: topAnchor).isActive = true
        button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
        bottomAnchor.constraint(equalTo: button.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ play: Play, _ viewController: UIViewController) {
        guard let button else { return }
        button.addTarget(viewController, action: play.selector, for: .touchUpInside)
        
        if let icon = play.icon {
            switch play.core {
            case .cytrus:
                if let decoded = icon.decodeRGB565(width: 48, height: 48) {
                    button.configuration?.baseBackgroundColor = decoded.dominantColor()
                }
            default: break
            }
        }
        if let iconBuffer = play.iconBuffer {
            switch play.core {
            case .grape:
                if let cgImage = CGImage.cgImage(iconBuffer, 32, 32) {
                    button.configuration?.baseBackgroundColor = UIImage(cgImage: cgImage).dominantColor()
                }
            default: break
            }
        }
    }
}

class GameCheatCell : UICollectionViewCell, UIContextMenuInteractionDelegate {
    var textLabel: UILabel? = nil, secondaryTextLabel: UILabel? = nil
    
    var cheat: Cheat? = nil
    var game: GameBase? = nil
    var indexPath: IndexPath? = nil
    
    var handler: (() -> Void)? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        clipsToBounds = true
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15
        
        textLabel = .init()
        guard let textLabel else { return }
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize)
        addSubview(textLabel)
        
        secondaryTextLabel = .init()
        guard let secondaryTextLabel else { return }
        secondaryTextLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryTextLabel.font = .preferredFont(forTextStyle: .subheadline)
        secondaryTextLabel.textAlignment = .right
        secondaryTextLabel.textColor = .secondaryLabel
        addSubview(secondaryTextLabel)
        
        textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        
        secondaryTextLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        secondaryTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
        textLabel.trailingAnchor.constraint(lessThanOrEqualTo: secondaryTextLabel.leadingAnchor, constant: -20).isActive = true
        
        let interaction = UIContextMenuInteraction(delegate: self)
        addInteraction(interaction)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ gameCheat: GameCheat, _ game: GameBase? = nil, _ indexPath: IndexPath? = nil) {
        self.game = game
        self.indexPath = indexPath
        
        guard let textLabel, let secondaryTextLabel else { return }
        textLabel.text = gameCheat.name
        secondaryTextLabel.text = if gameCheat.cheat.enabled { "Enabled" } else { nil }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        .init(actionProvider:  { _ in
                .init(children: [
                    UIAction(title: "Delete", image: .init(systemName: "trash.fill"), attributes: [.destructive, .disabled], handler: { _ in
                        guard let game = self.game as? CytrusGame, let identifier = game.identifier, let indexPath = self.indexPath else { return }
                        CheatsManager.shared().loadCheats(identifier)
                        CheatsManager.shared().removeCheat(at: indexPath.item)
                        CheatsManager.shared().saveCheats(identifier)
                        
                        game.update()
                        if let handler = self.handler { handler() }
                    })
                ])
        })
    }
}

class GameSaveCell : UICollectionViewCell {
    var imageView: UIImageView? = nil // use for validity status
    var textLabel: UILabel? = nil, secondaryTextLabel: UILabel? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        clipsToBounds = true
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15
        
        imageView = .init(image: .init(systemName: "circle.fill"))
        guard let imageView else { return }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        
        textLabel = .init()
        guard let textLabel else { return }
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize)
        addSubview(textLabel)
        
        secondaryTextLabel = .init()
        guard let secondaryTextLabel else { return }
        secondaryTextLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryTextLabel.font = .preferredFont(forTextStyle: .subheadline)
        secondaryTextLabel.textAlignment = .right
        secondaryTextLabel.textColor = .secondaryLabel
        addSubview(secondaryTextLabel)
        
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 12).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        
        secondaryTextLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        secondaryTextLabel.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -12).isActive = true
        
        textLabel.trailingAnchor.constraint(equalTo: secondaryTextLabel.leadingAnchor, constant: -20).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ gameSave: GameSaveState) {
        guard let imageView, let textLabel, let secondaryTextLabel else { return }
        
        imageView.tintColor = switch gameSave.status {
        case 0: .systemGreen
        case 1: .systemRed
        default: .tertiarySystemBackground
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        let date: Date = .init(timeIntervalSince1970: .init(gameSave.time))
        
        textLabel.text = dateFormatter.string(from: date)
        secondaryTextLabel.text = timeFormatter.string(from: date)
    }
}

class GameDeleteCell : UICollectionViewCell {
    var button: UIButton? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var configuration: UIButton.Configuration = .filled()
        configuration.baseBackgroundColor = .systemRed
        configuration.buttonSize = .large
        configuration.cornerStyle = .large
        configuration.attributedTitle = .init("Delete", attributes: .init([
            .font : UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        ]))
        configuration.image = .init(systemName: "trash.fill")?
            .applyingSymbolConfiguration(.init(scale: .medium))
        configuration.imagePadding = 8
        
        button = .init(configuration: configuration, primaryAction: nil)
        guard let button else { return }
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        
        button.topAnchor.constraint(equalTo: topAnchor).isActive = true
        button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
        bottomAnchor.constraint(equalTo: button.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ delete: GameDelete, _ viewController: UIViewController) {
        guard let button else { return }
        button.addTarget(viewController, action: delete.selector, for: .touchUpInside)
    }
}

class GameNoDataCell : UICollectionViewCell {
    var textLabel: UILabel? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        clipsToBounds = true
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15
        
        textLabel = .init()
        guard let textLabel else { return }
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize)
        textLabel.textAlignment = .center
        addSubview(textLabel)
        
        textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ noData: LimitedOrNoData) {
        guard let textLabel else { return }
        textLabel.text = noData.text
        textLabel.textAlignment = noData.textAlignment
    }
}

enum SectionType : Int, CaseIterable, CustomStringConvertible {
    case header, play, cheats, coreVersion, kernelMemoryMode, new3DSKernelMemoryMode, publisher, regions, saveStates, delete
    
    var description: String {
        switch self {
        case .header: "Header"
        case .play: "Play"
        case .cheats: "Cheats"
        case .coreVersion: "Core Version"
        case .kernelMemoryMode: "Kernel Memory Mode"
        case .new3DSKernelMemoryMode: "New 3DS Kernel Memory Mode"
        case .publisher: "Publisher"
        case .regions: "Regions"
        case .saveStates: "Save States"
        case .delete: "Delete"
        }
    }
}

class Header : AnyHashableSendable, @unchecked Sendable {
    let core: Core
    var icon: Data? = nil
    var iconBuffer: UnsafeMutablePointer<UInt32>? = nil
    let text, secondaryText: String
    
    init(core: Core, icon: Data? = nil, iconBuffer: UnsafeMutablePointer<UInt32>? = nil, text: String, secondaryText: String) {
        self.core = core
        self.icon = icon
        self.iconBuffer = iconBuffer
        self.text = text
        self.secondaryText = secondaryText
    }
}

class Play : AnyHashableSendable, @unchecked Sendable {
    let core: Core
    var icon: Data? = nil
    var iconBuffer: UnsafeMutablePointer<UInt32>? = nil
    let selector: Selector
    
    init(core: Core, icon: Data? = nil, iconBuffer: UnsafeMutablePointer<UInt32>? = nil, selector: Selector) {
        self.core = core
        self.icon = icon
        self.iconBuffer = iconBuffer
        self.selector = selector
    }
}

class GameCheat : AnyHashableSendable, @unchecked Sendable {
    var cheat: Cheat
    
    let name, code: String
    
    init(_ cheat: Cheat) {
        self.cheat = cheat
        
        self.name = cheat.name
        self.code = cheat.code
    }
    
    func tap() {
        cheat.enabled.toggle()
    }
}

class GameSaveState : AnyHashableSendable, @unchecked Sendable {
    let slot: UInt32
    let time: UInt64
    let build: String
    let status: Int32
    
    var identifier: UInt64? = nil
    
    init(_ saveState: SaveStateInfo, _ identifier: UInt64? = nil) {
        self.slot = saveState.slot
        self.time = saveState.time
        self.build = saveState.buildName
        self.status = saveState.status
        self.identifier = identifier
    }
}

class GameDelete : AnyHashableSendable, @unchecked Sendable {
    let core: Core
    let selector: Selector
    
    init(core: Core, selector: Selector) {
        self.core = core
        self.selector = selector
    }
}

class LimitedOrNoData : AnyHashableSendable, @unchecked Sendable {
    let text: String
    let textAlignment: NSTextAlignment
    
    init(text: String, _ textAlignment: NSTextAlignment = .center) {
        self.text = text
        self.textAlignment = textAlignment
    }
}

class GameIntermediateController : UICollectionViewController {
    var dataSource: UICollectionViewDiffableDataSource<SectionType, AnyHashableSendable>? = nil
    var snapshot: NSDiffableDataSourceSnapshot<SectionType, AnyHashableSendable>? = nil
    
    var button: UIButton? = nil
    
    var game: GameBase
    init(_ game: GameBase) {
        self.game = game
        super.init(collectionViewLayout: LayoutManager.shared.intermediate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        var configuration: UIButton.Configuration = .filled()
        configuration.buttonSize = .large
        configuration.cornerStyle = .capsule
        configuration.image = .init(systemName: "xmark")?
            .applyingSymbolConfiguration(.init(scale: .large))?
            .applyingSymbolConfiguration(.init(weight: .bold))
        configuration.baseForegroundColor = .white
        switch game {
        case let cytrusGame as CytrusGame:
            if let icon = cytrusGame.icon {
                if let decoded = icon.decodeRGB565(width: 48, height: 48) {
                    configuration.baseBackgroundColor = decoded.dominantColor()
                }
            }
        case let grapeGame as GrapeGame:
            if let cgImage = CGImage.cgImage(grapeGame.icon, 32, 32) {
                configuration.baseBackgroundColor = UIImage(cgImage: cgImage).dominantColor()
            }
        default: break
        }
        
        button = .init(configuration: configuration, primaryAction: .init(handler: { _ in
            self.dismiss(animated: true)
        }))
        guard let button else { return }
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        
        let headerCellRegistration: UICollectionView.CellRegistration<GameArtworkTitleCell, Header> = .init { cell, indexPath, itemIdentifier in
            cell.set(itemIdentifier, self)
        }
        
        let playCellRegistration: UICollectionView.CellRegistration<GamePlayCell, Play> = .init { cell, indexPath, itemIdentifier in
            cell.set(itemIdentifier, self)
        }
        
        let cheatCellRegistration: UICollectionView.CellRegistration<GameCheatCell, GameCheat> = .init { cell, indexPath, itemIdentifier in
            cell.set(itemIdentifier, self.game, indexPath)
            cell.handler = {
                // self.reloadData()
            }
        }
        
        let saveCellRegistration: UICollectionView.CellRegistration<GameSaveCell, GameSaveState> = .init { cell, indexPath, itemIdentifier in
            cell.set(itemIdentifier)
        }
        
        let deleteCellRegistration: UICollectionView.CellRegistration<GameDeleteCell, GameDelete> = .init { cell, indexPath, itemIdentifier in
            cell.set(itemIdentifier, self)
        }
        
        let noDataCelRegistration: UICollectionView.CellRegistration<GameNoDataCell, LimitedOrNoData> = .init { cell, indexPath, itemIdentifier in
            cell.set(itemIdentifier)
        }
        
        let supplementaryCellRegistration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell> = .init(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            var contentConfiguration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            if let dataSource = self.dataSource, let section = dataSource.sectionIdentifier(for: indexPath.section) {
                contentConfiguration.text = section.description
            }
            supplementaryView.contentConfiguration = contentConfiguration
        }
        
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch (itemIdentifier) {
            case let header as Header:
                collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: header)
            case let play as Play:
                collectionView.dequeueConfiguredReusableCell(using: playCellRegistration, for: indexPath, item: play)
            case let cheat as GameCheat:
                collectionView.dequeueConfiguredReusableCell(using: cheatCellRegistration, for: indexPath, item: cheat)
            case let save as GameSaveState:
                collectionView.dequeueConfiguredReusableCell(using: saveCellRegistration, for: indexPath, item: save)
            case let delete as GameDelete:
                collectionView.dequeueConfiguredReusableCell(using: deleteCellRegistration, for: indexPath, item: delete)
            case let noData as LimitedOrNoData:
                collectionView.dequeueConfiguredReusableCell(using: noDataCelRegistration, for: indexPath, item: noData)
            default:
                 nil
            }
        }
        guard let dataSource else { return }
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryCellRegistration, for: indexPath)
        }
        
        reloadData()
    }
    
    func reloadData() {
        guard let dataSource else { return }
        
        snapshot = .init()
        guard var snapshot else { return }
        snapshot.appendSections(SectionType.allCases)
        
        switch (game) {
        case let cytrusGame as CytrusGame:
            let cheats: [AnyHashableSendable] = if cytrusGame.cheats.isEmpty { [LimitedOrNoData(text: "No Cheats")] } else { cytrusGame.cheats.map { GameCheat($0) } }
            let saves: [AnyHashableSendable] = if cytrusGame.saves.isEmpty { [LimitedOrNoData(text: "No Save States")] } else { cytrusGame.saves.map { GameSaveState($0, cytrusGame.identifier) } }
            
            snapshot.appendItems([
                Header(core: .init(rawValue: cytrusGame.core)!,
                       icon: cytrusGame.icon,
                       text: cytrusGame.title,
                       secondaryText: cytrusGame.fileDetails.size)
            ], toSection: .header)
            
            snapshot.appendItems([
                Play(core: .init(rawValue: cytrusGame.core)!,
                     icon: cytrusGame.icon,
                     selector: #selector(playCytrusGame))
            ], toSection: .play)
            
            snapshot.appendItems(cheats, toSection: .cheats)
            
            let coreVersion = if let coreVersion = cytrusGame.coreVersion { "\(coreVersion.major).\(coreVersion.minor).\(coreVersion.revision)" } else { "No Core Version" }
            let coreVersionAlignment: NSTextAlignment = if cytrusGame.coreVersion == nil { .center } else { .left }
            snapshot.appendItems([
                LimitedOrNoData(text: coreVersion, coreVersionAlignment)
            ], toSection: .coreVersion)
            
            let kernelMemoryMode: String = if let kernelMemoryMode = cytrusGame.kernelMemoryMode {
                switch kernelMemoryMode {
                case .prod: "64 MB application memory"
                case .dev1: "96 MB application memory"
                case .dev2: "80 MB application memory"
                case .dev3: "72 MB application memory"
                case .dev4: "32 MB application memory"
                default: "64 MB application memory"
                }
            } else { "No Kernel Memory Mode" }
            let kernelMemoryModeAlignment: NSTextAlignment = if cytrusGame.kernelMemoryMode == nil { .center } else { .left }
            snapshot.appendItems([
                LimitedOrNoData(text: kernelMemoryMode, kernelMemoryModeAlignment)
            ], toSection: .kernelMemoryMode)
            
            let new3DSKernelMemoryMode: String = if let new3DSKernelMemoryMode = cytrusGame.new3DSKernelMemoryMode {
                switch new3DSKernelMemoryMode {
                case .legacy: kernelMemoryMode
                case .prod, .dev2: "124 MB application memory"
                case .dev1: "178 MB application memory"
                default: kernelMemoryMode
                }
            } else { "No New 3DS Kernel Memory Mode" }
            let new3DSKernelMemoryModeAlignment: NSTextAlignment = if cytrusGame.new3DSKernelMemoryMode == nil { .center } else { .left }
            snapshot.appendItems([
                LimitedOrNoData(text: new3DSKernelMemoryMode, new3DSKernelMemoryModeAlignment)
            ], toSection: .new3DSKernelMemoryMode)
            
            let publisherAlignment: NSTextAlignment = if cytrusGame.publisher == nil { .center } else { .left }
            snapshot.appendItems([
                LimitedOrNoData(text: cytrusGame.publisher ?? "No Publisher", publisherAlignment)
            ], toSection: .publisher)
            
            let regionsAlignment: NSTextAlignment = if cytrusGame.regions == nil { .center } else { .left }
            snapshot.appendItems([
                LimitedOrNoData(text: cytrusGame.regions ?? "No Regions", regionsAlignment)
            ], toSection: .regions)
            
            snapshot.appendItems(saves, toSection: .saveStates)
            
            snapshot.appendItems([
                GameDelete(core: .init(rawValue: cytrusGame.core)!,
                           selector: #selector(deleteCytrusGame))
            ], toSection: .delete)
        case let grapeGame as GrapeGame:
            snapshot.appendItems([
                Header(core: .init(rawValue: grapeGame.core)!,
                       iconBuffer: grapeGame.icon,
                       text: grapeGame.title,
                       secondaryText: grapeGame.fileDetails.size)
            ], toSection: .header)
            snapshot.appendItems([
                Play(core: .init(rawValue: grapeGame.core)!,
                     iconBuffer: grapeGame.icon,
                     selector: #selector(playGrapeGame))
            ], toSection: .play)
            snapshot.appendItems([LimitedOrNoData(text: "No Cheats")], toSection: .cheats)
            snapshot.appendItems([LimitedOrNoData(text: "No Save States")], toSection: .saveStates)
            snapshot.appendItems([
                GameDelete(core: .init(rawValue: grapeGame.core)!,
                           selector: #selector(deleteGrapeGame))
            ], toSection: .delete)
        default: break
        }
        Task { await dataSource.apply(snapshot) }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let dataSource, let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case let cheat as GameCheat:
            guard let cytrusGame = game as? CytrusGame, let identifier = cytrusGame.identifier else { return }
            cheat.cheat.enabled.toggle()
            CheatsManager().update(cheat.cheat, at: indexPath.item)
            CheatsManager().saveCheats(identifier)
            
            cytrusGame.update()
            
            var snapshot = dataSource.snapshot()
            snapshot.reloadItems([cheat])
            Task { await dataSource.apply(snapshot) }
        case let save as GameSaveState:
            guard let identifier = save.identifier else { return }
            
            let alertController: UIAlertController = .init(title: "Delete Save State", message: "Are you sure you want to delete this save state?", preferredStyle: .alert)
            alertController.addAction(.init(title: "Dismiss", style: .cancel))
            alertController.addAction(.init(title: "Delete", style: .destructive, handler: { _ in
                do {
                    try FileManager.default.removeItem(atPath: Cytrus.shared.saveStatePath(for: identifier))
                    switch self.game {
                    case let cytrusGame as CytrusGame:
                        cytrusGame.update()
                        if let nav = self.presentingViewController as? UINavigationController, let viewController = nav.topViewController as? LibraryController {
                            viewController.beginPopulatingGames(with: try LibraryManager.shared.games().get())
                        }
                    default: break
                    }
                } catch {
                    print(error.localizedDescription)
                }
                
                self.reloadData()
            }))
            self.present(alertController, animated: true)
        default: break
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
        
        guard let button else { return }
        
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.height
        let alpha = max(1 / 3, 1.0 - (offset / maxOffset))
        button.alpha = alpha
    }
    
    @objc func playCytrusGame() {
        guard let cytrusSkin, let presentingViewController else { return }
        
        let emulationController = CytrusDefaultController(game: game, skin: cytrusSkin)
        emulationController.modalPresentationStyle = .fullScreen
        
        dismiss(animated: true) {
            presentingViewController.present(emulationController, animated: true)
        }
    }
    
    @objc func playGrapeGame() {
        guard let grapeSkin, let presentingViewController else { return }
        
        let emulationController = GrapeDefaultController(game: game, skin: grapeSkin)
        emulationController.modalPresentationStyle = .fullScreen
        
        dismiss(animated: true) {
            presentingViewController.present(emulationController, animated: true)
        }
    }
    
    @objc func deleteCytrusGame() {
        guard let cytrusGame = game as? CytrusGame, let nav = presentingViewController as? UINavigationController, let viewController = nav.topViewController as? LibraryController else { return }
        
        present(alert(title: "Delete \(cytrusGame.title)",
                      message: "Are you sure you want to delete \(cytrusGame.title)?",
                      preferredStyle: .alert, actions: [
                        .init(title: "Dismiss", style: .cancel),
                        .init(title: "Delete", style: .destructive, handler: { _ in
                            do {
                                try FileManager.default.removeItem(at: cytrusGame.fileDetails.url)
                                viewController.beginPopulatingGames(with: try LibraryManager.shared.games().get())
                                self.dismiss(animated: true)
                            } catch {
                                print(#function, error, error.localizedDescription)
                            }
                        })
                      ]),
                animated: true)
    }
    
    @objc func deleteGrapeGame() {
        guard let grapeGame = game as? GrapeGame, let nav = presentingViewController as? UINavigationController, let viewController = nav.topViewController as? LibraryController else { return }
        
        present(alert(title: "Delete \(grapeGame.title)",
                      message: "Are you sure you want to delete \(grapeGame.title)?",
                      preferredStyle: .alert, actions: [
                        .init(title: "Dismiss", style: .cancel),
                        .init(title: "Delete", style: .destructive, handler: { _ in
                            do {
                                try FileManager.default.removeItem(at: grapeGame.fileDetails.url)
                                viewController.beginPopulatingGames(with: try LibraryManager.shared.games().get())
                                self.dismiss(animated: true)
                            } catch {
                                print(#function, error, error.localizedDescription)
                            }
                        })
                      ]),
                animated: true)
    }
}
