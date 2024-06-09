//
//  NDSGBADefaultLibraryCell.swift
//  Folium
//
//  Created by Jarrod Norwell on 21/5/2024.
//

import Foundation
import Grape
import UIKit

class NDSGBADefaultLibraryCell : UICollectionViewCell {
    fileprivate var headlineLabel, titleLabel: UILabel!
    fileprivate var optionsButton: UIButton!
    
    fileprivate var game: GrapeManager.Library.Game!
    fileprivate var viewController: UIViewController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .tertiarySystemBackground
        clipsToBounds = true
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15
        
        titleLabel = .init()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        titleLabel.textColor = .label
        addSubview(titleLabel)
        
        headlineLabel = .init()
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize)
        headlineLabel.textAlignment = .left
        headlineLabel.textColor = .secondaryLabel
        addSubview(headlineLabel)
        
        var configuration = UIButton.Configuration.filled()
        configuration.buttonSize = .mini
        configuration.cornerStyle = .capsule
        configuration.image = .init(systemName: "ellipsis")?
            .applyingSymbolConfiguration(.init(weight: .bold))
        
        optionsButton = .init(configuration: configuration)
        optionsButton.translatesAutoresizingMaskIntoConstraints = false
        optionsButton.showsMenuAsPrimaryAction = true
        addSubview(optionsButton)
        
        addConstraints([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            headlineLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            headlineLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -4),
            headlineLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            optionsButton.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            optionsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            heightAnchor.constraint(equalTo: widthAnchor, multiplier: 3 / 4)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ game: GrapeManager.Library.Game, _ viewController: UIViewController) {
        self.game = game
        self.viewController = viewController
        
        optionsButton.menu = menu()
        
        headlineLabel.text = Core.Console.gba.shortened
        titleLabel.text = game.title
    }
    
    fileprivate func menu() -> UIMenu {
        .init(children: [
            UIAction(title: "Delete", image: .init(systemName: "trash"), attributes: [.destructive], handler: { _ in
                guard let viewController = self.viewController as? LibraryController else {
                    return
                }
                
                let alertController = UIAlertController(title: "Delete", message: "Are you sure you want to delete \(self.game.title)?", preferredStyle: .alert)
                alertController.addAction(.init(title: "Cancel", style: .cancel))
                alertController.addAction(.init(title: "Delete", style: .destructive, handler: { _ in
                    Task {
                        try FileManager.default.removeItem(at: self.game.fileDetails.url)
                        try await viewController.populateGames()
                    }
                }))
                viewController.present(alertController, animated: true)
            })
        ])
    }
}
