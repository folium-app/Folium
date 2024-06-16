//
//  ControllerButton.swift
//  Folium
//
//  Created by Jarrod Norwell on 9/6/2024.
//

import Foundation
import UIKit

protocol ControllerButtonDelegate {
    func touchBegan(with type: Button.`Type`)
    func touchEnded(with type: Button.`Type`)
    func touchMoved(with type: Button.`Type`)
}

class ControllerButton : UIView {
    fileprivate var imageView: UIImageView!
    
    var button: Button
    var delegate: ControllerButtonDelegate? = nil
    var skin: Skin
    init(with button: Button, colors: (UIColor, UIColor), delegate: ControllerButtonDelegate? = nil, skin: Skin) {
        self.button = button
        self.delegate = delegate
        self.skin = skin
        super.init(frame: .zero)
        
        if let isDebug = skin.isDebug, isDebug {
            imageView = .init()
            imageView.backgroundColor = .systemRed.withAlphaComponent(1 / 3)
        } else {
            if let customisation = button.customisation {
                if let backgroundImageName = customisation.backgroundImageName, let path = skin.path {
                    imageView = .init(image: .init(contentsOfFile: path
                        .appendingPathComponent("buttons", conformingTo: .folder)
                        .appendingPathComponent(machine, conformingTo: .folder)
                        .appendingPathComponent(backgroundImageName, conformingTo: .fileURL).pathExtension) ?? .init(systemName: backgroundImageName))
                } else {
                    if customisation.isTransparent ?? false {
                        imageView = .init()
                    } else {
                        let colors = skin.core.newButtonColors[button.type] ?? (.black, .white)
                        
                        imageView = .init(image: button.image(for: skin.core)?
                            .applyingSymbolConfiguration(.init(paletteColors: [colors.0, colors.1])))
                    }
                }
            } else {
                let colors = skin.core.newButtonColors[button.type] ?? (.black, .white)
                
                imageView = .init(image: button.image(for: skin.core)?
                    .applyingSymbolConfiguration(.init(paletteColors: [colors.0, colors.1])))
            }
        }
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let delegate, let _ = touches.first else {
            return
        }
        
        if let customisation = button.customisation, let tappedBackgroundImageName = customisation.tappedBackgroundImageName, let path = skin.path {
            imageView = .init(image: .init(contentsOfFile: path
                .appendingPathComponent("buttons", conformingTo: .folder)
                .appendingPathComponent(machine, conformingTo: .folder)
                .appendingPathComponent(tappedBackgroundImageName, conformingTo: .fileURL).pathExtension))
        }
        
        if let configuration = button.customisation, let vibrateOnTap = configuration.vibrateOnTap, vibrateOnTap, let vibrationStrength = configuration.vibrationStrength {
            if #available(iOS 17.5, *) {
                UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle(rawValue: vibrationStrength.rawValue) ?? .light, view: self).impactOccurred()
            } else {
                UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle(rawValue: vibrationStrength.rawValue) ?? .light).impactOccurred()
            }
        }
        
        delegate.touchBegan(with: button.type)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let delegate, let _ = touches.first else {
            return
        }
        
        if let customisation = button.customisation, let backgroundImageName = customisation.backgroundImageName, let path = skin.path {
            imageView = .init(image: .init(contentsOfFile: path
                .appendingPathComponent("buttons", conformingTo: .folder)
                .appendingPathComponent(machine, conformingTo: .folder)
                .appendingPathComponent(backgroundImageName, conformingTo: .fileURL).pathExtension))
        }
        
        delegate.touchEnded(with: button.type)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let delegate, let _ = touches.first else {
            return
        }
        
        delegate.touchMoved(with: button.type)
    }
}
