//
//  ControllerButton.swift
//  Folium
//
//  Created by Jarrod Norwell on 9/6/2024.
//

import Foundation
import GameController
import UIKit

protocol ControllerButtonDelegate {
    func touchBegan(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex)
    func touchEnded(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex)
    func touchMoved(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex)
}

enum ButtonClass : String {
    case blurredButton = "blurredButton"
    case borderedButton = "borderedButton"
    case defaultButton = "defaultButton"
}

class ControllerButton : UIView {
    var button: Button
    var skin: Skin
    var delegate: ControllerButtonDelegate? = nil
    
    var movedToSelf: Bool = false
    
    init(button: Button, skin: Skin, delegate: ControllerButtonDelegate? = nil) {
        self.button = button
        self.skin = skin
        self.delegate = delegate
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let delegate else {
            return
        }
        
        if let vibrateOnTap = button.vibrateOnTap, vibrateOnTap {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        delegate.touchBegan(with: button.type, playerIndex: .index1)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let delegate else {
            return
        }
        
        delegate.touchEnded(with: button.type, playerIndex: .index1)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let delegate else {
            return
        }
        
        delegate.touchMoved(with: button.type, playerIndex: .index1)
    }
    
    func touchUpInside() {
        guard let delegate else {
            return
        }
        
        movedToSelf = false
        
        delegate.touchEnded(with: button.type, playerIndex: .index1)
    }
    
    func touchDown() {
        guard let delegate else {
            return
        }
        
        if let vibrateOnTap = button.vibrateOnTap, vibrateOnTap, !movedToSelf {
            UIImpactFeedbackGenerator().impactOccurred()
            movedToSelf = true
        }
        
        delegate.touchBegan(with: button.type, playerIndex: .index1)
    }
}

class BlurredButton : ControllerButton {
    fileprivate var visualEffectView: UIVisualEffectView? = nil
    fileprivate var imageView: UIImageView? = nil
    fileprivate var label: UILabel? = nil
    
    override init(button: Button, skin: Skin, delegate: (any ControllerButtonDelegate)? = nil) {
        super.init(button: button, skin: skin, delegate: delegate)
        
        visualEffectView = .init(effect: UIBlurEffect(style: .systemMaterialDark))
        guard let visualEffectView else {
            return
        }
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.backgroundColor = skin.core.color[button.type]?.withAlphaComponent(1 / 5)
        visualEffectView.clipsToBounds = true
        visualEffectView.layer.cornerCurve = .continuous
        addSubview(visualEffectView)
        
        visualEffectView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        if [.l, .zl, .r, .zr].contains(button.type) {
            label = .init(frame: .zero)
            guard let label else { return }
            label.translatesAutoresizingMaskIntoConstraints = false
            label.alpha = 1 / 5
            label.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize)
            label.text = button.letter(for: skin.core)
            label.textAlignment = .center
            label.textColor = .white
            visualEffectView.contentView.addSubview(label)
            
            label.topAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
            label.leadingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
            label.bottomAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
            label.trailingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        } else {
            imageView = .init(image: button.image(for: skin.core))
            guard let imageView else { return }
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.alpha = 1 / 5
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .white
            visualEffectView.contentView.addSubview(imageView)
            
            imageView.topAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.topAnchor, constant: [.minus, .home, .plus, .settings].contains(button.type) ? 4 : 8).isActive = true
            imageView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.leadingAnchor, constant: [.minus, .home, .plus, .settings].contains(button.type) ? 4 : 8).isActive = true
            imageView.bottomAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.bottomAnchor, constant: [.minus, .home, .plus, .settings].contains(button.type) ? -4 : -8).isActive = true
            imageView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.trailingAnchor, constant: [.minus, .home, .plus, .settings].contains(button.type) ? -4 : -8).isActive = true
        }
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let visualEffectView {
            switch button.type {
            case .l, .zl, .r, .zr:
                visualEffectView.layer.cornerRadius = visualEffectView.frame.height / 3
            default:
                visualEffectView.layer.cornerRadius = visualEffectView.frame.height / 2
            }
        }
    }
}

class BorderedButton : ControllerButton {
    override init(button: Button, skin: Skin, delegate: (any ControllerButtonDelegate)? = nil) {
        super.init(button: button, skin: skin, delegate: delegate)
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        switch button.type {
        case .l, .zl, .r, .zr:
            layer.cornerRadius = frame.height / 3
        default:
            layer.cornerRadius = frame.height / 2
        }
    }
}

class DefaultButton : ControllerButton {
    fileprivate var imageView: UIImageView? = nil
    
    override init(button: Button, skin: Skin, delegate: (any ControllerButtonDelegate)? = nil) {
        super.init(button: button, skin: skin, delegate: delegate)
        
        imageView = .init()
        guard let imageView else {
            return
        }
        
        if let debugging = skin.debugging, debugging {
            imageView.backgroundColor = .systemRed.withAlphaComponent(1 / 3)
        }
        
        if let backgroundImageName = button.backgroundImageName, let url = skin.url {
            imageView.image = .init(contentsOfFile: url
                .appendingPathComponent("buttons", conformingTo: .folder)
                .appendingPathComponent(backgroundImageName, conformingTo: .fileURL)
                .path
            )
        } else {
            if let transparent = button.transparent, transparent {
                imageView.image = nil
            } else {
                let colors = skin.core.colors[button.type] ?? (.black, .white)
                
                imageView.image = button.image(for: skin.core)?
                    .applyingSymbolConfiguration(.init(paletteColors: [colors.0, colors.1]))
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
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


/*
class BlurredButton : UIView {
    var visualEffectView: UIVisualEffectView? = nil
    
    var button: Button
    var skin: Skin
    var delegate: ControllerButtonDelegate? = nil
    init(button: Button, skin: Skin, delegate: ControllerButtonDelegate? = nil) {
        self.button = button
        self.skin = skin
        self.delegate = delegate
        super.init(frame: .zero)
        
        visualEffectView = .init(effect: UIBlurEffect(style: .systemChromeMaterial))
        guard let visualEffectView else { return }
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(visualEffectView)
        
        visualEffectView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ControllerButton : UIView {
    fileprivate var imageView: UIImageView? = nil
    fileprivate var movedToSelf: Bool = false
    
    var button: Button
    var skin: Skin
    var delegate: ControllerButtonDelegate? = nil
    init(button: Button, skin: Skin, delegate: ControllerButtonDelegate? = nil) {
        self.button = button
        self.skin = skin
        self.delegate = delegate
        super.init(frame: .zero)
        
        imageView = .init()
        guard let imageView else {
            return
        }
        
        if let debugging = skin.debugging, debugging {
            imageView.backgroundColor = .systemRed.withAlphaComponent(1 / 3)
        }
        
        if let backgroundImageName = button.backgroundImageName, let url = skin.url {
            imageView.image = .init(contentsOfFile: url
                .appendingPathComponent("buttons", conformingTo: .folder)
                .appendingPathComponent(backgroundImageName, conformingTo: .fileURL)
                .path
            )
        } else {
            if let transparent = button.transparent, transparent {
                imageView.image = nil
            } else {
                let colors = skin.core.colors[button.type] ?? (.black, .white)
                
                imageView.image = button.image(for: skin.core)?
                    .applyingSymbolConfiguration(.init(paletteColors: [colors.0, colors.1]))
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
        super.touchesBegan(touches, with: event)
        guard let delegate else {
            return
        }
        
        if let vibrateOnTap = button.vibrateOnTap, vibrateOnTap {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        delegate.touchBegan(with: button.type, playerIndex: .index1)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let delegate else {
            return
        }
        
        delegate.touchEnded(with: button.type, playerIndex: .index1)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let delegate else {
            return
        }
        
        delegate.touchMoved(with: button.type, playerIndex: .index1)
    }
    
    func touchUpInside() {
        guard let delegate else {
            return
        }
        
        movedToSelf = false
        
        delegate.touchEnded(with: button.type, playerIndex: .index1)
    }
    
    func touchDown() {
        guard let delegate else {
            return
        }
        
        if let vibrateOnTap = button.vibrateOnTap, vibrateOnTap, !movedToSelf {
            UIImpactFeedbackGenerator().impactOccurred()
            movedToSelf = true
        }
        
        delegate.touchBegan(with: button.type, playerIndex: .index1)
    }
}
*/
