//
//  CytrusCell.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 17/7/2024.
//

import Cytrus
import Foundation
import SwiftUI
import UIKit

@MainActor class CytrusCell : DefaultCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 1).isActive = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ cytrusGame: CytrusGame, with viewController: UIViewController? = nil) {
        guard let viewController else { return }
        set(text: cytrusGame.title, image: cytrusGame.icon, with: .white)
        
        guard let blurredImageView, let imageView else {
            return
        }
        
        if let icon = cytrusGame.icon, let image = icon.decodeRGB565(width: 48, height: 48) {
            blurredImageView.image = image
            imageView.image = image.blurMasked(radius: 2)
        }
        
        guard let optionsButton else {
            return
        }
        
        var children: [UIMenuElement] = [
            UIAction(title: "Cheats", image: .init(systemName: "hammer"), handler: { _ in
                let cheatsController = UINavigationController(rootViewController: CheatsController(cytrusGame))
                cheatsController.modalPresentationStyle = .fullScreen
                viewController.present(cheatsController, animated: true)
            }),
            UIAction(title: "Copy MD5", subtitle: "Used for Widgets, etc", image: .init(systemName: "clipboard"), handler: { _ in
                UIPasteboard.general.string = cytrusGame.fileDetails.md5
            }),
            UIAction(title: "Delete", image: .init(systemName: "trash"), attributes: [.destructive], handler: { _ in
                guard let viewController = viewController as? LibraryController else {
                    return
                }
                
                viewController.present(viewController.alert(title: "Delete \(cytrusGame.title)",
                                                            message: "Are you sure you want to delete \(cytrusGame.title)?",
                                                            preferredStyle: .alert, actions: [
                                                                .init(title: "Dismiss", style: .cancel),
                                                                .init(title: "Delete", style: .destructive, handler: { _ in
                                                                    do {
                                                                        try FileManager.default.removeItem(at: cytrusGame.fileDetails.url)
                                                                        viewController.beginPopulatingGames(with: try LibraryManager.shared.games().get())
                                                                    } catch {
                                                                        print(#function, error, error.localizedDescription)
                                                                    }
                                                                })
                                                            ]),
                                       animated: true)
            })
        ]
        
        if cytrusGame.skins.count > 0 {
            children.append(UIMenu(title: "Skins", children: cytrusGame.skins.reduce(into: [UIAction](), { partialResult, element in
                partialResult.append(.init(title: element.title, subtitle: element.author.name, handler: { _ in
                    let cytrusEmulationController = Nintendo3DSEmulationController(game: cytrusGame, skin: element)
                    cytrusEmulationController.modalPresentationStyle = .fullScreen
                    viewController.present(cytrusEmulationController, animated: true)
                }))
            })))
        }
        
        optionsButton.menu = .init(children: children)
    }
}
