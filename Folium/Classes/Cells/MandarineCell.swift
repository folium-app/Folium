//
//  MandarineCell.swift
//  Folium
//
//  Created by Jarrod Norwell on 17/6/2026.
//

import ConstraintKit
import ExtensionsKit
import FontKit
import UniformTypeIdentifiers
import UIKit

import Mandarine

class MandarineCell : GameCell {
    var game: MandarineGame? = nil
    override func configureCell<T>(with game: T, controller: GamesController) {
        self.game = game as? MandarineGame
        guard let game: MandarineGame = self.game else {
            return
        }
        
        guard let imageView: UIImageView, let backgroundImageView: UIImageView,
              let label: UILabel, let secondaryLabel: UILabel,
              let button: UIButton else {
            return
        }
        
        guard let documentDirectoryURL: URL = .documentDirectoryURL else {
            return
        }
        
        let artworkDirectoryURL: URL = documentDirectoryURL
            .appending(component: game.system.string)
            .appending(component: "artworks")
        
        let customArtworkURL: URL = artworkDirectoryURL.appending(component: "\(game.details.nameWithoutSpaces.lowercased())_custom.jpg")
        let defaultArtworkURL: URL = artworkDirectoryURL.appending(component: "\(game.details.nameWithoutSpaces.lowercased()).jpg")
        
        hasCustomArtwork = fileManager.fileExists(atPath: customArtworkURL.path)
        hasDefaultArtwork = fileManager.fileExists(atPath: defaultArtworkURL.path)
        
        if hasCustomArtwork {
            imageView.image = UIImage(contentsOfFile: customArtworkURL.path)
        } else if hasDefaultArtwork {
            imageView.image = UIImage(contentsOfFile: defaultArtworkURL.path)
        } else if let boxartURLString: String = game.boxartURLString, let boxartURL: URL = URL(string: boxartURLString) {
            _ = Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: boxartURL)
                    imageView.image = UIImage(data: data)
                    try data.write(to: defaultArtworkURL)
                } catch {
                    imageView.image = nil
                }
            }
        } else {
            imageView.image = nil
        }
        
        backgroundImageView.image = imageView.image
        
        if let image: UIImage = imageView.image {
            averageImageColour = image.averageColorBottomRight()
        }
        
        label.text = game.details.name
        secondaryLabel.text = game.details.size
        
        button.menu = UIMenu(children: [
            UIMenu(title: "Artwork", image: UIImage(systemName: "photo"), children: [
                UIDeferredMenuElement.uncached { completion in
                    var elements: [UIMenuElement] = [
                        UIAction(title: "Import", image: UIImage(systemName: "arrow.down.circle")) { action in
                            let imagePickerController: UIImagePickerController = .init()
                            imagePickerController.allowsEditing = true
                            imagePickerController.delegate = self
                            imagePickerController.mediaTypes = [UTType.image.identifier]
                            imagePickerController.modalPresentationStyle = .fullScreen
                            controller.present(imagePickerController, animated: true)
                        }
                    ]
                    
                    if self.hasCustomArtwork {
                        elements.append(UIAction(title: "Delete",
                                                 image: UIImage(systemName: "minus.circle"),
                                                 attributes: .destructive) { action in
                            _ = Task {
                                do {
                                    try self.fileManager.removeItem(at: customArtworkURL)
                                    self.hasCustomArtwork = false
                                    
                                    await controller.populateGames()
                                } catch {
                                    await controller.populateGames()
                                }
                            }
                        })
                    }
                    
                    completion(elements)
                }
            ]),
            UIAction(title: "Delete", image: UIImage(systemName: "minus.circle"), attributes: .destructive) { action in
                let parentDirectoryURL: URL = game.details.url.deletingLastPathComponent()
                
                let alertController: UIAlertController = UIAlertController(title: "Delete Game?",
                                                                           message: "Deleting this game is destructive and cannot be undone",
                                                                           preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { action in
                    _ = Task {
                        do {
                            for file in game.mandarineSystem.files(from: game.details.url) {
                                try self.fileManager.removeItem(at: parentDirectoryURL.appending(component: file))
                            }
                            
                            try self.fileManager.removeItem(at: game.details.url)
                            
                            if parentDirectoryURL.lastPathComponent != "games" {
                                try self.fileManager.removeItem(at: parentDirectoryURL)
                            }
                            
                            await controller.populateGames()
                        } catch {
                            print(error, error.localizedDescription)
                        }
                    }
                })
                alertController.preferredAction = alertController.actions.last
                controller.present(alertController, animated: true)
            }
        ])
    }
}

extension MandarineCell : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image: UIImage = info[.editedImage] as? UIImage else {
            return
        }
        
        guard let imageView: UIImageView, let backgroundImageView: UIImageView,
              let game: MandarineGame else {
            return
        }
        
        guard let documentDirectoryURL: URL = .documentDirectoryURL else {
            return
        }
        
        let artworkDirectoryURL: URL = documentDirectoryURL
            .appending(component: game.system.string)
            .appending(component: "artworks")
        
        let customArtworkURL: URL = artworkDirectoryURL.appending(component: "\(game.details.nameWithoutSpaces.lowercased())_custom.jpg")
        let defaultArtworkURL: URL = artworkDirectoryURL.appending(component: "\(game.details.nameWithoutSpaces.lowercased()).jpg")
        
        hasCustomArtwork = fileManager.fileExists(atPath: customArtworkURL.path)
        
        imageView.image = UIImage(contentsOfFile: customArtworkURL.path)
        backgroundImageView.image = imageView.image
        
        _  = Task {
            do {
                if fileManager.fileExists(atPath: customArtworkURL.path) {
                    try fileManager.removeItem(at: customArtworkURL)
                }
                
                if let data: Data = image.jpegData(compressionQuality: 1.0) {
                    try data.write(to: customArtworkURL)
                }
            } catch {
                imageView.image = if fileManager.fileExists(atPath: defaultArtworkURL.path) {
                    UIImage(contentsOfFile: defaultArtworkURL.path)
                } else {
                    nil
                }
                
                backgroundImageView.image = imageView.image
            }
        }
        
        picker.dismiss(animated: true)
    }
}
