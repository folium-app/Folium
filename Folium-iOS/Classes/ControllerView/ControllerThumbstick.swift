//
//  ControllerThumbstick.swift
//  Folium
//
//  Created by Jarrod Norwell on 10/6/2024.
//

import Foundation
import UIKit

protocol ControllerThumbstickDelegate {
    func touchBegan(with type: Thumbstick.`Type`, position: (x: Float, y: Float))
    func touchEnded(with type: Thumbstick.`Type`, position: (x: Float, y: Float))
    func touchMoved(with type: Thumbstick.`Type`, position: (x: Float, y: Float))
}

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
        
        delegate.touchBegan(with: thumbstick.type, position: position(in: self, with: touch.location(in: self)))
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
        
        delegate.touchEnded(with: thumbstick.type, position: (x: 0, y: 0))
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
        
        delegate.touchMoved(with: thumbstick.type, position: position(in: self, with: touchLocation))
    }
}
