//
//  PlayStation1Cell.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 29/7/2024.
//

import Foundation
import UIKit

@MainActor class PlayStation1Cell : DefaultCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 1).isActive = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ playStation1Game: PlayStation1Game, with viewController: UIViewController) {
        guard let blurredImageView, let imageView else { return }
        
        if let url = playStation1Game.icon {
            let task = Task {
                let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
                let (data, _) = try await URLSession.shared.data(for: request)
                return data
            }
            
            Task {
                switch await task.result {
                case .success(let data):
                    set(text: playStation1Game.title, image: data, with: .white)
                    if let image = UIImage(data: data) {
                        playStation1Game.iconData = image.pngData()
                        blurredImageView.image = image
                        imageView.image = image.blurMasked(radius: 2)
                    } else {
                        print(playStation1Game.title, "success but no image")
                        blurredImageView.image = nil
                        imageView.image = nil
                        set(text: playStation1Game.title, image: nil, with: .white)
                    }
                case .failure(let error):
                    print(playStation1Game.title, error.localizedDescription)
                    set(text: playStation1Game.title, image: nil, with: .white)
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
                UIPasteboard.general.string = playStation1Game.fileDetails.sha256
            }),
            UIAction(title: "Delete", image: .init(systemName: "trash"), attributes: [.destructive], handler: { _ in
                guard let viewController = viewController as? LibraryController else {
                    return
                }
                
                viewController.present(viewController.alert(title: "Delete \(playStation1Game.title)",
                                                            message: "Are you sure you want to delete \(playStation1Game.title)?",
                                                            preferredStyle: .alert, actions: [
                                                                .init(title: "Dismiss", style: .cancel),
                                                                .init(title: "Delete", style: .destructive, handler: { _ in
                                                                    do {
                                                                        let cueFileURL = playStation1Game.fileDetails.url
                                                                        let binFileURLs = try PlayStation1Game.getBinFiles(from: cueFileURL)
                                                                        try binFileURLs.forEach { url in
                                                                            try FileManager.default.removeItem(at: cueFileURL
                                                                                .deletingLastPathComponent()
                                                                                .appending(path: url))
                                                                        }
                                                                        
                                                                        try FileManager.default.removeItem(at: playStation1Game.fileDetails.url)
                                                                        viewController.beginPopulatingGames(with: try LibraryManager.shared.games().get())
                                                                    } catch {
                                                                        print(#function, error, error.localizedDescription)
                                                                    }
                                                                })
                                                            ]),
                                       animated: true)
            })
        ]
        
        if playStation1Game.skins.count > 0 {
            children.append(UIMenu(title: "Skins", children: playStation1Game.skins.reduce(into: [UIAction](), { partialResult, element in
                partialResult.append(.init(title: element.title, subtitle: element.author.name, handler: { _ in
                    let playStation1EmulationController = LycheeSkinController(game: playStation1Game, skin: element)
                    playStation1EmulationController.modalPresentationStyle = .fullScreen
                    viewController.present(playStation1EmulationController, animated: true)
                }))
            })))
        }
        
        optionsButton.menu = .init(children: children)
    }
}
