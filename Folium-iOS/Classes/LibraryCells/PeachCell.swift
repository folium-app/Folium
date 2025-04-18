//
//  PeachCell.swift
//  Folium
//
//  Created by Jarrod Norwell on 22/2/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Foundation
import UIKit

@MainActor class PeachCell : DefaultCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 1).isActive = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ peachGame: PeachGame, with viewController: UIViewController) {
        set(text: peachGame.title, with: .white)
        
        guard let optionsButton else {
            return
        }
        
        var children: [UIMenuElement] = [
            UIAction(title: "Copy MD5", subtitle: "Used for Widgets, etc", image: .init(systemName: "clipboard"), handler: { _ in
                UIPasteboard.general.string = peachGame.fileDetails.md5
            }),
            UIAction(title: "Delete", image: .init(systemName: "trash"), attributes: [.destructive], handler: { _ in
                guard let viewController = viewController as? LibraryController else {
                    return
                }
                
                viewController.present(viewController.alert(title: "Delete \(peachGame.title)",
                                                            message: "Are you sure you want to delete \(peachGame.title)?",
                                                            preferredStyle: .alert, actions: [
                                                                .init(title: "Dismiss", style: .cancel),
                                                                .init(title: "Delete", style: .destructive, handler: { _ in
                                                                    do {
                                                                        try FileManager.default.removeItem(at: peachGame.fileDetails.url)
                                                                        viewController.beginPopulatingGames(with: try LibraryManager.shared.games().get())
                                                                    } catch {
                                                                        print(#function, error, error.localizedDescription)
                                                                    }
                                                                })
                                                            ]),
                                       animated: true)
            })
        ]
        
        if peachGame.skins.count > 0 {
            children.append(UIMenu(title: "Skins", children: peachGame.skins.reduce(into: [UIAction](), { partialResult, element in
                partialResult.append(.init(title: element.title, subtitle: element.author.name, handler: { _ in
                    // let cytrusEmulationController = Nintendo3DSEmulationController(game: cytrusGame, skin: element)
                    // cytrusEmulationController.modalPresentationStyle = .fullScreen
                    // viewController.present(cytrusEmulationController, animated: true)
                }))
            })))
        }
        
        optionsButton.menu = .init(children: children)
    }
}
