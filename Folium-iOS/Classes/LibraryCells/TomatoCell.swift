//
//  TomatoCell.swift
//  Folium
//
//  Created by Jarrod Norwell on 22/2/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Foundation
import UIKit

@MainActor class TomatoCell : DefaultCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 1).isActive = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ tomatoGame: TomatoGame, with viewController: UIViewController) {
        set(text: tomatoGame.title, image: tomatoGame.data, with: .white)
        guard let blurredImageView, let imageView else { return }
        
        if let url = tomatoGame.icon {
            let task = Task {
                let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
                let (data, _) = try await URLSession.shared.data(for: request)
                return data
            }
            
            Task {
                switch await task.result {
                case .success(let data):
                    set(text: tomatoGame.title, image: data, with: .white)
                    if let image = UIImage(data: data) {
                        tomatoGame.data = image.pngData()
                        blurredImageView.image = image
                        imageView.image = image.blurMasked(radius: 2)
                    } else {
                        print(tomatoGame.title, "success but no image")
                        blurredImageView.image = nil
                        imageView.image = nil
                        set(text: tomatoGame.title, image: nil, with: .white)
                    }
                case .failure(let error):
                    print(tomatoGame.title, error.localizedDescription)
                    set(text: tomatoGame.title, image: nil, with: .white)
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
            UIAction(title: "Copy MD5", subtitle: "Used for Widgets, etc", image: .init(systemName: "clipboard"), handler: { _ in
                UIPasteboard.general.string = tomatoGame.fileDetails.md5
            }),
            UIAction(title: "Delete", image: .init(systemName: "trash"), attributes: [.destructive], handler: { _ in
                guard let viewController = viewController as? LibraryController else {
                    return
                }
                
                viewController.present(viewController.alert(title: "Delete \(tomatoGame.title)",
                                                            message: "Are you sure you want to delete \(tomatoGame.title)?",
                                                            preferredStyle: .alert, actions: [
                                                                .init(title: "Dismiss", style: .cancel),
                                                                .init(title: "Delete", style: .destructive, handler: { _ in
                                                                    do {
                                                                        try FileManager.default.removeItem(at: tomatoGame.fileDetails.url)
                                                                        viewController.beginPopulatingGames(with: try LibraryManager.shared.games().get())
                                                                    } catch {
                                                                        print(#function, error, error.localizedDescription)
                                                                    }
                                                                })
                                                            ]),
                                       animated: true)
            })
        ]
        
        if tomatoGame.skins.count > 0 {
            children.append(UIMenu(title: "Skins", children: tomatoGame.skins.reduce(into: [UIAction](), { partialResult, element in
                partialResult.append(.init(title: element.title, subtitle: element.author.name, handler: { _ in
                    let tomatoDefaultController = TomatoDefaultController(game: tomatoGame, skin: element)
                    tomatoDefaultController.modalPresentationStyle = .fullScreen
                    viewController.present(tomatoDefaultController, animated: true)
                }))
            })))
        }
        
        optionsButton.menu = .init(children: children)
    }
}
