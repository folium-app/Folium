//
//  NDSDefaultLibraryCell.swift
//  Folium
//
//  Created by Jarrod Norwell on 21/5/2024.
//

import Foundation
import Grape
import UIKit

class NDSDefaultLibraryCell : UICollectionViewCell {
    fileprivate var imageView: UIImageView!
    fileprivate var gradientView: GradientView!
    fileprivate var titleLabel: UILabel!
    fileprivate var optionsButton: UIButton!
    
    fileprivate var game: GrapeManager.Library.Game!
    fileprivate var viewController: UIViewController!
    
    fileprivate var hasImage: Bool = true
    fileprivate var averageImageColor: UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .tertiarySystemBackground
        clipsToBounds = true
        layer.borderColor = UIColor.tertiarySystemBackground.cgColor
        layer.borderWidth = 3
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15
        
        imageView = .init()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        gradientView = .init()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(gradientView)
        
        gradientView.topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
        gradientView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        gradientView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        gradientView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
        
        titleLabel = .init()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 3
        titleLabel.textAlignment = .left
        gradientView.addSubview(titleLabel)
        
        titleLabel.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 16).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: -16).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -16).isActive = true
        
        var configuration = UIButton.Configuration.tinted()
        configuration.baseBackgroundColor = .white
        configuration.baseForegroundColor = .white
        configuration.buttonSize = .small
        configuration.cornerStyle = .capsule
        configuration.image = .init(systemName: "ellipsis")?
            .applyingSymbolConfiguration(.init(weight: .bold))
        
        optionsButton = .init(configuration: configuration)
        optionsButton.translatesAutoresizingMaskIntoConstraints = false
        optionsButton.showsMenuAsPrimaryAction = true
        addSubview(optionsButton)
        
        optionsButton.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        optionsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        if #available(iOS 17, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], action: #selector(traitDidChange))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.borderColor = averageImageColor?.cgColor ?? UIColor.tertiarySystemBackground.cgColor
        if let configuration = optionsButton.configuration {
            layer.cornerRadius = configuration.background.cornerRadius + 16
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.borderColor = averageImageColor?.cgColor ?? UIColor.tertiarySystemBackground.cgColor
        if !hasImage {
            gradientView.set(.tertiarySystemBackground)
        }
    }
    
    @objc func traitDidChange() {
        layer.borderColor = averageImageColor?.cgColor ?? UIColor.tertiarySystemBackground.cgColor
        if !hasImage {
            gradientView.set(.tertiarySystemBackground)
        }
    }
    
    func set(_ game: GrapeManager.Library.Game, _ viewController: UIViewController) {
        self.game = game
        self.viewController = viewController
        
        optionsButton.menu = menu()
        
        let pointer = Grape.shared.icon(game.fileDetails.url)
        let cgImage = CGImage.cgImage(pointer, 32, 32)
        if let cgImage {
            let averageColor = UIImage(cgImage: cgImage).averageColor
            averageImageColor = averageColor
            
            imageView.image = .init(cgImage: cgImage).blurred(radius: 2)
            gradientView.set((.clear, averageColor ?? .tintColor))
        } else {
            imageView.image = nil
            hasImage = false
            gradientView.set(.tertiarySystemBackground)
        }
        
        titleLabel.attributedText = .init(string: game.title, attributes: [
            .font : UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize)
        ])
    }
    
    fileprivate func menu() -> UIMenu {
        return .init(children: [
            UIMenu(title: "Boot Options", image: .init(systemName: "power"), children: [
                UIMenu(title: "Boot with Skin", image: .init(systemName: "paintbrush"), children: GrapeManager.shared.skinsManager.skins.reduce(into: [UIAction](), { partialResult, skin in
                    partialResult.append(UIAction(title: skin.name, subtitle: "by \(skin.author)", handler: { _ in
                        let grapeController = GrapeDefaultViewController(with: self.game, skin: skin)
                        grapeController.modalPresentationStyle = .fullScreen
                        self.viewController.present(grapeController, animated: true)
                    }))
                }))
            ]),
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
