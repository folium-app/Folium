//
//  SuperNESCell.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 24/8/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation
import UIKit

@MainActor class SuperNESCell : DefaultCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 1.37).isActive = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ superNESGame: SuperNESGame, with viewController: UIViewController) {
        guard let blurredImageView, let imageView else { return }
        
        if let url = superNESGame.icon {
            let task = Task {
                let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
                let (data, _) = try await URLSession.shared.data(for: request)
                return data
            }
            
            Task {
                switch await task.result {
                case .success(let data):
                    set(text: superNESGame.title, image: data, with: .white)
                    if let image = UIImage(data: data) {
                        superNESGame.iconData = image.pngData()
                        blurredImageView.image = image
                        imageView.image = image.blurMasked(radius: 2)
                    } else {
                        print(superNESGame.title, "success but no image")
                        blurredImageView.image = nil
                        imageView.image = nil
                        set(text: superNESGame.title, image: nil, with: .white)
                    }
                case .failure(let error):
                    print(superNESGame.title, error.localizedDescription)
                    set(text: superNESGame.title, image: nil, with: .white)
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
            UIAction(title: "Delete", image: .init(systemName: "trash"), attributes: [.destructive], handler: { _ in
                guard let viewController = viewController as? LibraryController else {
                    return
                }
                
                viewController.present(viewController.alert(title: "Delete \(superNESGame.title)",
                                                            message: "Are you sure you want to delete \(superNESGame.title)?",
                                                            preferredStyle: .alert, actions: [
                                                                .init(title: "Dismiss", style: .cancel),
                                                                .init(title: "Delete", style: .destructive, handler: { _ in
                                                                    do {
                                                                        try FileManager.default.removeItem(at: superNESGame.fileDetails.url)
                                                                        viewController.beginPopulatingGames(with: try LibraryManager.shared.games().get())
                                                                    } catch {
                                                                        print(#function, error, error.localizedDescription)
                                                                    }
                                                                })
                                                            ]),
                                       animated: true)
            })
        ]
        
        if superNESGame.skins.count > 0 {
            children.append(UIMenu(title: "Skins", children: superNESGame.skins.reduce(into: [UIAction](), { partialResult, element in
                partialResult.append(.init(title: element.title, subtitle: element.author.name, handler: { _ in
                    let superNESEmulationController = MangoSkinController(game: superNESGame, skin: element)
                    superNESEmulationController.modalPresentationStyle = .fullScreen
                    viewController.present(superNESEmulationController, animated: true)
                }))
            })))
        }
        
        optionsButton.menu = .init(children: children)
    }
}
