//
//  N3DSDefaultLibraryCell.swift
//  Folium
//
//  Created by Jarrod Norwell on 21/5/2024.
//

import Foundation
import Cytrus
import UIKit

class N3DSDefaultLibraryCell : UICollectionViewCell {
    fileprivate var imageView: UIImageView!
    fileprivate var gradientView: GradientView!
    fileprivate var headlineLabel, titleLabel: UILabel!
    fileprivate var optionsButton: UIButton!
    
    fileprivate var game: CytrusManager.Library.Game!
    fileprivate var viewController: UIViewController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .tertiarySystemBackground
        clipsToBounds = true
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15
        
        imageView = .init()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        
        gradientView = .init()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(gradientView)
        
        titleLabel = .init()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        titleLabel.textColor = .white
        gradientView.addSubview(titleLabel)
        
        headlineLabel = .init()
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize)
        headlineLabel.textAlignment = .left
        headlineLabel.textColor = .lightText
        gradientView.addSubview(headlineLabel)
        
        var configuration = UIButton.Configuration.tinted()
        configuration.baseBackgroundColor = .white
        configuration.baseForegroundColor = .white
        configuration.buttonSize = .mini
        configuration.cornerStyle = .capsule
        configuration.image = .init(systemName: "ellipsis")?
            .applyingSymbolConfiguration(.init(weight: .bold))
        
        optionsButton = .init(configuration: configuration)
        optionsButton.translatesAutoresizingMaskIntoConstraints = false
        optionsButton.showsMenuAsPrimaryAction = true
        addSubview(optionsButton)
        
        addConstraints([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            gradientView.topAnchor.constraint(equalTo: imageView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            gradientView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: -12),
            titleLabel.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -12),
            
            headlineLabel.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 12),
            headlineLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -4),
            headlineLabel.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -12),
            
            optionsButton.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            optionsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            heightAnchor.constraint(equalTo: widthAnchor, multiplier: 3 / 4)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ game: CytrusManager.Library.Game, _ viewController: UIViewController) {
        self.game = game
        self.viewController = viewController
        
        print(game)
        optionsButton.menu = menu(game.fileDetails.extension == "app" || game.fileDetails.extension == "cia")
        
        let information = Cytrus.shared.information(game.fileDetails.url)
        if let image = information.iconData.decodeRGB565(width: 48, height: 48) {
            imageView.image = image.blurred(radius: 1)
            gradientView.set((.clear, image.averageColor ?? .tintColor))
        }
        
        headlineLabel.text = game.fileDetails.extension.uppercased()
        titleLabel.text = information.title
    }
    
    fileprivate func menu(_ isCIA: Bool = false) -> UIMenu {
        .init(children: [
            /*UIMenu(title: "Boot Options", image: .init(systemName: "power"), children: [
                UIAction(title: "Fast Boot", subtitle: "Skip the Home Menu", handler: { _ in
                    // TODO:
                }),
                UIAction(title: "Slow Boot", subtitle: "Boot the Home Menu", attributes: [.disabled], handler: { _ in
                    // TODO:
                }),
            ]),*/
            UIAction(title: "Delete", image: .init(systemName: "trash"), attributes: isCIA ? [.destructive, .disabled] : [.destructive], handler: { _ in
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
