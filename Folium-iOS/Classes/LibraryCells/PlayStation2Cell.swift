//
//  PlayStation2Cell.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 22/12/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation
import UIKit

@MainActor class PlayStation2Cell : DefaultCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 23 / 16).isActive = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ playStation2Game: PlayStation2Game, with viewController: UIViewController) {
        guard let blurredImageView, let imageView else { return }
        
        if let url = playStation2Game.icon {
            let task = Task {
                let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
                let (data, _) = try await URLSession.shared.data(for: request)
                return data
            }
            
            Task {
                switch await task.result {
                case .success(let data):
                    set(text: playStation2Game.title, image: data, with: .white)
                    if let image = UIImage(data: data) {
                        playStation2Game.iconData = image.pngData()
                        blurredImageView.image = image
                        imageView.image = image.blurMasked(radius: 2)
                    } else {
                        print(playStation2Game.title, "success but no image")
                        blurredImageView.image = nil
                        imageView.image = nil
                        set(text: playStation2Game.title, image: nil, with: .white)
                    }
                case .failure(let error):
                    print(playStation2Game.title, error.localizedDescription)
                    set(text: playStation2Game.title, image: nil, with: .white)
                }
            }
        } else {
            blurredImageView.image = nil
            imageView.image = nil
        }
        
        guard let optionsButton else {
            return
        }
        
        var children: [UIMenuElement] = [
            UIAction(title: "Copy SHA256", subtitle: "Used for Widgets, etc", image: .init(systemName: "clipboard"), handler: { _ in
                UIPasteboard.general.string = playStation2Game.fileDetails.sha256
            }),
            UIAction(title: "Delete", image: .init(systemName: "trash"), attributes: [.destructive], handler: { _ in
                guard let viewController = viewController as? LibraryController else {
                    return
                }
                
                viewController.present(viewController.alert(title: "Delete \(playStation2Game.title)",
                                                            message: "Are you sure you want to delete \(playStation2Game.title)?",
                                                            preferredStyle: .alert, actions: [
                                                                .init(title: "Dismiss", style: .cancel),
                                                                .init(title: "Delete", style: .destructive, handler: { _ in
                                                                    do {
                                                                        try FileManager.default.removeItem(at: playStation2Game.fileDetails.url)
                                                                        viewController.beginPopulatingGames(with: try LibraryManager.shared.games().get())
                                                                    } catch {
                                                                        print(#function, error, error.localizedDescription)
                                                                    }
                                                                })
                                                            ]),
                                       animated: true)
            })
        ]
        
        if playStation2Game.skins.count > 0 {
            children.append(UIMenu(title: "Skins", children: playStation2Game.skins.reduce(into: [UIAction](), { partialResult, element in
                partialResult.append(.init(title: element.title, subtitle: element.author.name, handler: { _ in
                    // TODO: SkinController
                    let playStation2EmulationController = CherryDefaultController(game: playStation2Game, skin: element)
                    playStation2EmulationController.modalPresentationStyle = .fullScreen
                    viewController.present(playStation2EmulationController, animated: true)
                }))
            })))
        }
        
        optionsButton.menu = .init(children: children)
    }
}

