//
//  ControllerThumbstick.swift
//  Folium
//
//  Created by Jarrod Norwell on 10/6/2024.
//

import Foundation
import GameController
import UIKit

protocol ControllerThumbstickDelegate {
    func touchBegan(with type: Thumbstick.`Type`, position: (x: Float, y: Float), playerIndex: GCControllerPlayerIndex)
    func touchEnded(with type: Thumbstick.`Type`, position: (x: Float, y: Float), playerIndex: GCControllerPlayerIndex)
    func touchMoved(with type: Thumbstick.`Type`, position: (x: Float, y: Float), playerIndex: GCControllerPlayerIndex)
}

enum ThumbstickClass : String {
    case blurredThumbstick = "blurredThumbstick"
    case defaultThumbstick = "defaultThumbstick"
}

class ControllerThumbstick : UIView {
    var centerXConstraint: NSLayoutConstraint? = nil, centerYConstraint: NSLayoutConstraint? = nil,
    widthConstraint: NSLayoutConstraint? = nil, heightConstraint: NSLayoutConstraint? = nil
    
    var stickView: UIView? = nil
    
    var thumbstick: Thumbstick
    var skin: Skin
    var delegate: ControllerThumbstickDelegate? = nil
    init(thumbstick: Thumbstick, skin: Skin, delegate: ControllerThumbstickDelegate? = nil) {
        self.thumbstick = thumbstick
        self.skin = skin
        self.delegate = delegate
        super.init(frame: .zero)
        
        stickView = .init()
        guard let stickView else {
            return
        }
        stickView.translatesAutoresizingMaskIntoConstraints = false
        stickView.clipsToBounds = true
        stickView.layer.cornerCurve = .continuous
        addSubview(stickView)
        
        centerXConstraint = stickView.centerXAnchor.constraint(equalTo: centerXAnchor)
        guard let centerXConstraint else {
            return
        }
        centerXConstraint.isActive = true
        
        centerYConstraint = stickView.centerYAnchor.constraint(equalTo: centerYAnchor)
        guard let centerYConstraint else {
            return
        }
        centerYConstraint.isActive = true
        
        widthConstraint = stickView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 3)
        guard let widthConstraint else {
            return
        }
        widthConstraint.isActive = true
        
        heightConstraint = stickView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1 / 3)
        guard let heightConstraint else {
            return
        }
        heightConstraint.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let stickView {
            stickView.layer.cornerRadius = stickView.frame.height / 2
        }
    }
    
    fileprivate func position(in view: UIView, with location: CGPoint) -> (x: Float, y: Float) {
        let radius = view.frame.width / 2
        return (Float((location.x - radius) / radius), Float(-(location.y - radius) / radius))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let delegate, let touch = touches.first else {
            return
        }
        
        guard let stickView, let widthConstraint, let heightConstraint else {
            return
        }
        
        // widthConstraint.constant = 10
        // heightConstraint.constant = 10
        // stickView.layoutIfNeeded()
        
        delegate.touchBegan(with: thumbstick.type, position: position(in: self, with: touch.location(in: self)), playerIndex: .index1)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let delegate else {
            return
        }
        
        guard let centerXConstraint, let centerYConstraint, let widthConstraint, let heightConstraint else {
            return
        }
        
        centerXConstraint.constant = 0
        centerYConstraint.constant = 0
        // widthConstraint.constant = 0
        // heightConstraint.constant = 0
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
        
        delegate.touchEnded(with: thumbstick.type, position: (x: 0, y: 0), playerIndex: .index1)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let delegate, let touch = touches.first else {
            return
        }
        
        guard let stickView, let centerXConstraint, let centerYConstraint else {
            return
        }
        
        let halfWidth: CGFloat = frame.width / 2
        let halfHeight: CGFloat = frame.height / 2
        
        let touchLocation = touch.location(in: self)
        let distanceFromCenter = CGPoint(x: touchLocation.x - halfWidth, y: touchLocation.y - halfHeight)
        
        let angle = atan2(distanceFromCenter.y, distanceFromCenter.x)
        let distance = sqrt(pow(distanceFromCenter.x, 2) + pow(distanceFromCenter.y, 2))
        
        let maxDraggableDistance = min(halfWidth, halfHeight) * 0.9
        
        let constrainedDistance = min(distance, maxDraggableDistance)
        
        let constrainedX = cos(angle) * constrainedDistance
        let constrainedY = sin(angle) * constrainedDistance
        
        centerXConstraint.constant = constrainedX
        centerYConstraint.constant = constrainedY
        stickView.layoutIfNeeded()
        
        delegate.touchMoved(with: thumbstick.type, position: position(in: self, with: touchLocation), playerIndex: .index1)
    }
}

class BlurredThumbstick : ControllerThumbstick {
    fileprivate var visualEffectView: UIVisualEffectView? = nil
    
    override init(thumbstick: Thumbstick, skin: Skin, delegate: (any ControllerThumbstickDelegate)? = nil) {
        super.init(thumbstick: thumbstick, skin: skin, delegate: delegate)
        
        visualEffectView = .init(effect: UIBlurEffect(style: .systemMaterialDark))
        guard let stickView, let visualEffectView else {
            return
        }
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        stickView.addSubview(visualEffectView)
        
        visualEffectView.topAnchor.constraint(equalTo: stickView.topAnchor).isActive = true
        visualEffectView.leadingAnchor.constraint(equalTo: stickView.leadingAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: stickView.bottomAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: stickView.trailingAnchor).isActive = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DefaultThumbstick : ControllerThumbstick {
    fileprivate var imageView: UIImageView? = nil
    
    override init(thumbstick: Thumbstick, skin: Skin, delegate: (any ControllerThumbstickDelegate)? = nil) {
        super.init(thumbstick: thumbstick, skin: skin, delegate: delegate)
        
        imageView = .init()
        guard let stickView, let imageView else {
            return
        }
        if let backgroundImageName = thumbstick.backgroundImageName, let url = skin.url {
            imageView.image = .init(contentsOfFile: url
                .appendingPathComponent("thumbsticks", conformingTo: .folder)
                .appendingPathComponent(backgroundImageName, conformingTo: .fileURL)
                .path
            )
        } else {
            imageView.image = .init(systemName: "circle.fill")?
                .applyingSymbolConfiguration(.init(paletteColors: [skin.core == .cytrus ? .white : .label]))
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        stickView.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: stickView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: stickView.leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: stickView.bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: stickView.trailingAnchor).isActive = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


/*
class ControllerThumbstick : UIView {
    fileprivate var stickImageView: UIImageView!
    
    fileprivate var centerXConstraint, centerYConstraint,
    widthConstraint, heightConstraint: NSLayoutConstraint!
    
    var thumbstick: Thumbstick
    var skin: Skin
    var delegate: ControllerThumbstickDelegate? = nil
    init(thumbstick: Thumbstick, skin: Skin, delegate: ControllerThumbstickDelegate? = nil) {
        self.thumbstick = thumbstick
        self.skin = skin
        self.delegate = delegate
        super.init(frame: .zero)
        
        stickImageView = .init()
        stickImageView.translatesAutoresizingMaskIntoConstraints = false
        
        if let debugging = skin.debugging, debugging {
            stickImageView.backgroundColor = .systemRed.withAlphaComponent(1 / 3)
        }
        
        if let backgroundImageName = thumbstick.backgroundImageName, let url = skin.url {
            stickImageView.image = .init(contentsOfFile: url
                .appendingPathComponent("thumbsticks", conformingTo: .folder)
                .appendingPathComponent(backgroundImageName, conformingTo: .fileURL)
                .path
            )
        } else {
            stickImageView.image = .init(systemName: "circle.fill")?
                .applyingSymbolConfiguration(.init(paletteColors: [skin.core == .cytrus ? .white : .label]))
        }
        addSubview(stickImageView)
        
        centerXConstraint = stickImageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        centerXConstraint.isActive = true
        centerYConstraint = stickImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        centerYConstraint.isActive = true
        
        widthConstraint = stickImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 3)
        widthConstraint.isActive = true
        heightConstraint = stickImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1 / 3)
        heightConstraint.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func position(in view: UIView, with location: CGPoint) -> (x: Float, y: Float) {
        let radius = view.frame.width / 2
        return (Float((location.x - radius) / radius), Float(-(location.y - radius) / radius))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let delegate, let touch = touches.first else {
            return
        }
        
        widthConstraint.constant = 10
        heightConstraint.constant = 10
        stickImageView.layoutIfNeeded()
        
        delegate.touchBegan(with: thumbstick.type, position: position(in: self, with: touch.location(in: self)), playerIndex: .index1)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let delegate else {
            return
        }
        
        centerXConstraint.constant = 0
        centerYConstraint.constant = 0
        widthConstraint.constant = 0
        heightConstraint.constant = 0
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
        
        delegate.touchEnded(with: thumbstick.type, position: (x: 0, y: 0), playerIndex: .index1)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let delegate, let touch = touches.first else {
            return
        }
        
        let halfWidth: CGFloat = frame.width / 2
        let halfHeight: CGFloat = frame.height / 2
        
        let touchLocation = touch.location(in: self)
        let distanceFromCenter = CGPoint(x: touchLocation.x - halfWidth, y: touchLocation.y - halfHeight)
        
        let angle = atan2(distanceFromCenter.y, distanceFromCenter.x)
        let distance = sqrt(pow(distanceFromCenter.x, 2) + pow(distanceFromCenter.y, 2))
        
        let maxDraggableDistance = min(halfWidth, halfHeight) * 0.9
        
        let constrainedDistance = min(distance, maxDraggableDistance)
        
        let constrainedX = cos(angle) * constrainedDistance
        let constrainedY = sin(angle) * constrainedDistance
        
        centerXConstraint.constant = constrainedX
        centerYConstraint.constant = constrainedY
        stickImageView.layoutIfNeeded()
        
        delegate.touchMoved(with: thumbstick.type, position: position(in: self, with: touchLocation), playerIndex: .index1)
    }
}
*/
