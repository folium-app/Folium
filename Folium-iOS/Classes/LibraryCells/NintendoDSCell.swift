//
//  NintendoDSCell.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 18/7/2024.
//

import Foundation
import UIKit

@MainActor class NintendoDSCell : DefaultCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 1).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ nintendoDSGame: NintendoDSGame, with viewController: UIViewController) {
        set(text: nintendoDSGame.title, with: .white)
        
        guard let blurredImageView, let imageView, let cgImage = CGImage.cgImage(nintendoDSGame.icon, 32, 32) else {
            return
        }
        
        let image = UIImage(cgImage: cgImage)
        
        blurredImageView.image = image
        imageView.image = image.blurMasked(radius: 2)
        
        guard let optionsButton else {
            return
        }
        
        var children: [UIMenuElement] = [
            UIAction(title: "Delete", image: .init(systemName: "trash"), attributes: [.destructive], handler: { _ in
                guard let viewController = viewController as? LibraryController else {
                    return
                }
                
                viewController.present(viewController.alert(title: "Delete \(nintendoDSGame.title)",
                                                            message: "Are you sure you want to delete \(nintendoDSGame.title)?",
                                                            preferredStyle: .alert, actions: [
                                                                .init(title: "Dismiss", style: .cancel),
                                                                .init(title: "Delete", style: .destructive, handler: { _ in
                                                                    do {
                                                                        try FileManager.default.removeItem(at: nintendoDSGame.fileDetails.url)
                                                                        viewController.beginPopulatingGames(with: try LibraryManager.shared.games().get())
                                                                    } catch {
                                                                        print(#function, error, error.localizedDescription)
                                                                    }
                                                                })
                                                            ]),
                                       animated: true)
            })
        ]
        
        if nintendoDSGame.skins.count > 0 {
            children.append(UIMenu(title: "Skins", children: nintendoDSGame.skins.reduce(into: [UIAction](), { partialResult, element in
                partialResult.append(.init(title: element.title, subtitle: element.author.name, handler: { _ in
                    let nintendoDSEmulationController = NintendoDSEmulationController(game: nintendoDSGame, skin: element)
                    nintendoDSEmulationController.modalPresentationStyle = .fullScreen
                    viewController.present(nintendoDSEmulationController, animated: true)
                }))
            })))
        }
        
        optionsButton.menu = .init(children: children)
    }
}
