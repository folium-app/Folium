//
//  GrapeCell.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 2/3/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Foundation
import UIKit

@MainActor class GrapeCell : DefaultCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 1).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ grapeGame: GrapeGame, with viewController: UIViewController) {
        set(text: grapeGame.title, image: Data(bytes: grapeGame.icon, count: 32 * 32 * MemoryLayout<UInt32>.size), with: .white)
        
        guard let blurredImageView, let imageView, let cgImage = CGImage.cgImage(grapeGame.icon, 32, 32) else {
            return
        }
        
        let image = UIImage(cgImage: cgImage)
        
        blurredImageView.image = image
        imageView.image = image.blurMasked(radius: 2)
        
        guard let optionsButton else {
            return
        }
        
        var children: [UIMenuElement] = [
            UIAction(title: "Copy MD5", subtitle: "Used for Widgets, etc", image: .init(systemName: "clipboard"), handler: { _ in
                UIPasteboard.general.string = grapeGame.fileDetails.md5
            }),
            UIAction(title: "Delete", image: .init(systemName: "trash"), attributes: [.destructive], handler: { _ in
                guard let viewController = viewController as? LibraryController else {
                    return
                }
                
                viewController.present(viewController.alert(title: "Delete \(grapeGame.title)",
                                                            message: "Are you sure you want to delete \(grapeGame.title)?",
                                                            preferredStyle: .alert, actions: [
                                                                .init(title: "Dismiss", style: .cancel),
                                                                .init(title: "Delete", style: .destructive, handler: { _ in
                                                                    do {
                                                                        try FileManager.default.removeItem(at: grapeGame.fileDetails.url)
                                                                        viewController.beginPopulatingGames(with: try LibraryManager.shared.games().get())
                                                                    } catch {
                                                                        print(#function, error, error.localizedDescription)
                                                                    }
                                                                })
                                                            ]),
                                       animated: true)
            })
        ]
        
        if grapeGame.skins.count > 0 {
            children.append(UIMenu(title: "Skins", children: grapeGame.skins.reduce(into: [UIAction](), { partialResult, element in
                partialResult.append(.init(title: element.title, subtitle: element.author.name, handler: { _ in
                    let grapeEmulationController = GrapeSkinController(game: grapeGame, skin: element)
                    grapeEmulationController.modalPresentationStyle = .fullScreen
                    viewController.present(grapeEmulationController, animated: true)
                }))
            })))
        }
        
        optionsButton.menu = .init(children: children)
    }
}
