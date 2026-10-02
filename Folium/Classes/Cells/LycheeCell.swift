//
//  LycheeCell.swift
//  Folium
//
//  Created by Jarrod Norwell on 21/6/2026.
//

import ConstraintKit
import ExtensionsKit
import FontKit
import UniformTypeIdentifiers
import UIKit

import Lychee

class LycheeCell : GameCell {
    var game: LycheeGame? = nil
    override func configureCell<T>(with game: T, controller: GamesController) {
        self.game = game as? LycheeGame
        guard let game: LycheeGame = self.game else {
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
        
        let customArtworkURL: URL = artworkDirectoryURL.appending(component: "\(game.details.fileNameWithoutSpaces.lowercased())_custom.png")
        let defaultArtworkURL: URL = artworkDirectoryURL.appending(component: "\(game.details.fileNameWithoutSpaces.lowercased()).png")
        
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
                    if let image: UIImage = UIImage(data: data) {
                        imageView.image = image
                        try data.write(to: defaultArtworkURL)
                    } else {
                        imageView.image = nil
                    }
                } catch {
                    imageView.image = nil
                }
            }
        } else {
            imageView.image = nil
        }
        
        backgroundImageView.image = imageView.image
        
        label.text = game.details.fileName
        secondaryLabel.text = "\(game.details.fileSize) • \(game.details.fileExtension.uppercased())"
        
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
            UIMenu(options: .displayInline, children: [
                UIAction(title: "Delete", image: UIImage(systemName: "minus.circle"), attributes: .destructive) { action in
                    let parentDirectoryURL: URL = game.details.fileURL.deletingLastPathComponent()
                    
                    let alertController: UIAlertController = UIAlertController(title: "Delete Game?",
                                                                               message: "Deleting this game is destructive and cannot be undone",
                                                                               preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { action in
                        _ = Task {
                            do {
                                try self.fileManager.removeItem(at: game.details.fileURL)
                                
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
        ])
    }
}

extension LycheeCell : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image: UIImage = info[.editedImage] as? UIImage else {
            return
        }
        
        guard let imageView: UIImageView, let backgroundImageView: UIImageView,
              let game: LycheeGame else {
            return
        }
        
        guard let documentDirectoryURL: URL = .documentDirectoryURL else {
            return
        }
        
        let artworkDirectoryURL: URL = documentDirectoryURL
            .appending(component: game.system.string)
            .appending(component: "artworks")
        
        let customArtworkURL: URL = artworkDirectoryURL.appending(component: "\(game.details.fileNameWithoutSpaces.lowercased())_custom.png")
        let defaultArtworkURL: URL = artworkDirectoryURL.appending(component: "\(game.details.fileNameWithoutSpaces.lowercased()).png")
        
        _  = Task {
            do {
                if fileManager.fileExists(atPath: customArtworkURL.path) {
                    try fileManager.removeItem(at: customArtworkURL)
                }
                
                if image.valid, let data: Data = image.pngData() {
                    try data.write(to: customArtworkURL)
                }
                
                hasCustomArtwork = fileManager.fileExists(atPath: customArtworkURL.path)
                
                imageView.image = UIImage(contentsOfFile: customArtworkURL.path)
                backgroundImageView.image = imageView.image
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
