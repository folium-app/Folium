//
//  Nintendo3DSCell.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 17/7/2024.
//

import Foundation
import UIKit

@MainActor class Nintendo3DSCell : DefaultCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 1).isActive = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ nintendo3DSGame: Nintendo3DSGame, with viewController: UIViewController) {
        set(text: nintendo3DSGame.title, image: nintendo3DSGame.icon, with: .white)
        
        guard let blurredImageView, let imageView, let image = nintendo3DSGame.icon.decodeRGB565(width: 48, height: 48) else {
            return
        }
        
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
                
                viewController.present(viewController.alert(title: "Delete \(nintendo3DSGame.title)",
                                                            message: "Are you sure you want to delete \(nintendo3DSGame.title)?",
                                                            preferredStyle: .alert, actions: [
                                                                .init(title: "Dismiss", style: .cancel),
                                                                .init(title: "Delete", style: .destructive, handler: { _ in
                                                                    do {
                                                                        try FileManager.default.removeItem(at: nintendo3DSGame.fileDetails.url)
                                                                        viewController.beginPopulatingGames(with: try LibraryManager.shared.games().get())
                                                                    } catch {
                                                                        print(#function, error, error.localizedDescription)
                                                                    }
                                                                })
                                                            ]),
                                       animated: true)
            })
        ]
        
        if nintendo3DSGame.skins.count > 0 {
            children.append(UIMenu(title: "Skins", children: nintendo3DSGame.skins.reduce(into: [UIAction](), { partialResult, element in
                partialResult.append(.init(title: element.title, handler: { _ in
                    let nintendo3DSEmulationController = Nintendo3DSEmulationController(game: nintendo3DSGame, skin: element)
                    nintendo3DSEmulationController.modalPresentationStyle = .fullScreen
                    viewController.present(nintendo3DSEmulationController, animated: true)
                }))
            })))
        }
        
        optionsButton.menu = .init(children: children)
    }
}
