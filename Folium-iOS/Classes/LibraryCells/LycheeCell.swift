//
//  LycheeCell.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 29/7/2024.
//

import Foundation
import UIKit

@MainActor class LycheeCell : DefaultCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 1).isActive = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ lycheeGame: LycheeGame, with viewController: UIViewController) {
        guard let blurredImageView, let imageView else { return }
        
        if let url = lycheeGame.icon {
            let task = Task {
                let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
                let (data, _) = try await URLSession.shared.data(for: request)
                return data
            }
            
            Task {
                switch await task.result {
                case .success(let data):
                    set(text: lycheeGame.title, image: data, with: .white)
                    if let image = UIImage(data: data) {
                        lycheeGame.data = image.pngData()
                        blurredImageView.image = image
                        imageView.image = image.blurMasked(radius: 2)
                    } else {
                        print(lycheeGame.title, "success but no image")
                        blurredImageView.image = nil
                        imageView.image = nil
                        set(text: lycheeGame.title, image: nil, with: .white)
                    }
                case .failure(let error):
                    print(lycheeGame.title, error.localizedDescription)
                    set(text: lycheeGame.title, image: nil, with: .white)
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
                UIPasteboard.general.string = lycheeGame.fileDetails.md5
            }),
            UIAction(title: "Delete", image: .init(systemName: "trash"), attributes: [.destructive], handler: { _ in
                guard let viewController = viewController as? LibraryController else {
                    return
                }
                
                viewController.present(viewController.alert(title: "Delete \(lycheeGame.title)",
                                                            message: "Are you sure you want to delete \(lycheeGame.title)?",
                                                            preferredStyle: .alert, actions: [
                                                                .init(title: "Dismiss", style: .cancel),
                                                                .init(title: "Delete", style: .destructive, handler: { _ in
                                                                    do {
                                                                        let cueFileURL = lycheeGame.fileDetails.url
                                                                        let binFileURLs = try LycheeGame.files(from: cueFileURL)
                                                                        try binFileURLs.forEach { url in
                                                                            try FileManager.default.removeItem(at: cueFileURL
                                                                                .deletingLastPathComponent()
                                                                                .appending(path: url))
                                                                        }
                                                                        
                                                                        try FileManager.default.removeItem(at: lycheeGame.fileDetails.url)
                                                                        viewController.beginPopulatingGames(with: try LibraryManager.shared.games().get())
                                                                    } catch {
                                                                        print(#function, error, error.localizedDescription)
                                                                    }
                                                                })
                                                            ]),
                                       animated: true)
            })
        ]
        
        if lycheeGame.skins.count > 0 {
            children.append(UIMenu(title: "Skins", children: lycheeGame.skins.reduce(into: [UIAction](), { partialResult, element in
                partialResult.append(.init(title: element.title, subtitle: element.author.name, handler: { _ in
                    let lycheeEmulationController = LycheeSkinController(game: lycheeGame, skin: element)
                    lycheeEmulationController.modalPresentationStyle = .fullScreen
                    viewController.present(lycheeEmulationController, animated: true)
                }))
            })))
        }
        
        optionsButton.menu = .init(children: children)
    }
}
