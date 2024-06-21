//
//  CheatsViewController.swift
//  Folium
//
//  Created by Jarrod Norwell on 17/6/2024.
//

#if canImport(Cytrus)

import Cytrus
import Foundation
import UIKit

class CheatCell : UICollectionViewCell {
    fileprivate var textLabel, secondaryTextLabel: UILabel!
    fileprivate var optionsButton: UIButton!
    fileprivate var isEnabled: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .tertiarySystemBackground
        clipsToBounds = true
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15
        
        textLabel = .init()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.textAlignment = .left
        addSubview(textLabel)
        
        textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        
        secondaryTextLabel = .init()
        secondaryTextLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryTextLabel.numberOfLines = 5
        secondaryTextLabel.textAlignment = .left
        addSubview(secondaryTextLabel)
        
        secondaryTextLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 4).isActive = true
        secondaryTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        secondaryTextLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        secondaryTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        
        var configuration = UIButton.Configuration.filled()
        configuration.buttonSize = .small
        configuration.cornerStyle = .capsule
        
        optionsButton = .init(configuration: configuration)
        optionsButton.translatesAutoresizingMaskIntoConstraints = false
        optionsButton.configurationUpdateHandler = { button in
            guard var configuration = button.configuration else {
                return
            }
            
            configuration.baseBackgroundColor = self.isEnabled ? .tintColor : .systemRed
            configuration.image = .init(systemName: self.isEnabled ? "checkmark" : "circle.dashed")?
                .applyingSymbolConfiguration(.init(weight: .bold))
            button.configuration = configuration
        }
        optionsButton.isUserInteractionEnabled = false
        addSubview(optionsButton)
        
        optionsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        optionsButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let configuration = optionsButton.configuration {
            layer.cornerRadius = configuration.background.cornerRadius + 16
        }
    }
    
    func set(_ cheat: Cheat) {
        isEnabled = cheat.isEnabled
        optionsButton.setNeedsUpdateConfiguration()
        
        textLabel.attributedText = .init(string: cheat.name, attributes: [
            .font : UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize),
            .foregroundColor : UIColor.label
        ])
        
        secondaryTextLabel.attributedText = .init(string: cheat.code, attributes: [
            .font : UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor : UIColor.secondaryLabel
        ])
    }
}

class CheatsViewController : UICollectionViewController {
    fileprivate var dataSource: UICollectionViewDiffableDataSource<String, Cheat>! = nil
    fileprivate var snapshot: NSDiffableDataSourceSnapshot<String, Cheat>! = nil
    
    fileprivate var cheatManager: CheatManager!
    
    fileprivate var titleIdentifier: UInt64
    init(_ titleIdentifier: UInt64) {
        self.titleIdentifier = titleIdentifier
        super.init(collectionViewLayout: LayoutManager.shared.cheats)
        
        cheatManager = .init()
        cheatManager.loadCheats(titleIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var configuration = UIButton.Configuration.filled()
        configuration.buttonSize = .small
        configuration.cornerStyle = .capsule
        configuration.image = .init(systemName: "plus")?
            .applyingSymbolConfiguration(.init(weight: .bold))
        
        let _ = UIButton(configuration: configuration, primaryAction: .init(handler: { _ in
            let addCheatViewController = UINavigationController(rootViewController: AddCheatViewController(self.titleIdentifier, self.cheatManager))
            self.present(addCheatViewController, animated: true)
        }))
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.setLeftBarButton(.init(systemItem: .cancel, primaryAction: .init(handler: { _ in
            self.dismiss(animated: true)
        })), animated: true)
        // TODO: allow users to add cheats in-app
        // navigationItem.perform(NSSelectorFromString("_setLargeTitleAccessoryView:"), with: button)
        title = "Cheats"
        collectionView.backgroundColor = .secondarySystemBackground
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        let cellRegistration = UICollectionView.CellRegistration<CheatCell, Cheat> { cell, indexPath, itemIdentifier in
            cell.set(itemIdentifier)
        }
        
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        snapshot = .init()
        snapshot.appendSections(["Cheats"])
        snapshot.appendItems(cheatManager.getCheats(), toSection: "Cheats")
        Task {
            await dataSource.apply(snapshot)
        }
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        
        cheatManager = .init()
        cheatManager.loadCheats(titleIdentifier)
        
        snapshot = .init()
        snapshot.appendSections(["Cheats"])
        snapshot.appendItems(cheatManager.getCheats(), toSection: "Cheats")
        Task {
            await dataSource.apply(snapshot)
        }
        
        refreshControl.endRefreshing()
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = collectionView.indexPathForItem(at: point), let _ = collectionView.cellForItem(at: indexPath) as? CheatCell else {
            return .init()
        }
        
        return .init(actionProvider: { _ in
            .init(children: [
                UIAction(title: "Delete", image: .init(systemName: "trash"), attributes: [.destructive], handler: { _ in
                    self.cheatManager.removeCheat(at: indexPath.item)
                    self.cheatManager.saveCheats(self.titleIdentifier)
                    
                    var snapshot = self.dataSource.snapshot()
                    snapshot.deleteItems([snapshot.itemIdentifiers[indexPath.item]])
                    Task {
                        await self.dataSource.apply(snapshot)
                    }
                })
            ])
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        var snapshot = dataSource.snapshot()
        let item = snapshot.itemIdentifiers[indexPath.item]
        cheatManager.toggle(item)
        cheatManager.update(item, at: indexPath.item)
        cheatManager.saveCheats(titleIdentifier)
        snapshot.reloadItems([item])
        Task {
            await dataSource.apply(snapshot)
        }
    }
}

#endif
