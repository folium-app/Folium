//
//  VirtualControllerThumbstick.swift
//  Folium
//
//  Created by Jarrod Norwell on 24/5/2024.
//

import Foundation
import UIKit

class VirtualControllerThumbstick : UIView {
    enum ThumbstickType : Int {
        case thumbstickLeft, thumbstickRight
    }
    
    fileprivate var stickImageView: UIImageView!
    
    fileprivate var centerXConstraint, centerYConstraint,
    widthConstraint, heightConstraint: NSLayoutConstraint!
    
    var thumbstickType: ThumbstickType
    var virtualThumbstickDelegate: VirtualControllerThumbstickDelegate
    init(_ core: Core, _ thumbstickType: ThumbstickType, _ virtualThumbstickDelegate: VirtualControllerThumbstickDelegate) {
        self.thumbstickType = thumbstickType
        self.virtualThumbstickDelegate = virtualThumbstickDelegate
        super.init(frame: .zero)
        isUserInteractionEnabled = true
        
        stickImageView = .init(image: .init(systemName: "circle.fill")?
            .applyingSymbolConfiguration(.init(paletteColors: [.white])))
        stickImageView.translatesAutoresizingMaskIntoConstraints = false
        switch thumbstickType {
        case .thumbstickLeft:
            if core != .cytrus {
                stickImageView.alpha = 0
            }
        case .thumbstickRight:
            if core != .cytrus {
                stickImageView.alpha = 0
            }
        }
        stickImageView.isUserInteractionEnabled = true
        addSubview(stickImageView)
        
        centerXConstraint = stickImageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        centerXConstraint.isActive = true
        centerYConstraint = stickImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        centerYConstraint.isActive = true
        
        widthConstraint = stickImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2)
        widthConstraint.isActive = true
        heightConstraint = stickImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2)
        heightConstraint.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        super.hitTest(point, with: event) == self ? nil : super.hitTest(point, with: event)
    }
    
    fileprivate func position(in view: UIView, with location: CGPoint) -> (x: Float, y: Float) {
        let radius = view.frame.width / 2
        return (Float((location.x - radius) / radius), Float(-(location.y - radius) / radius))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        
        widthConstraint.constant = 20
        heightConstraint.constant = 20
        stickImageView.layoutIfNeeded()
        
        virtualThumbstickDelegate.touchDown(thumbstickType, position(in: self, with: touch.location(in: self)))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        centerXConstraint.constant = 0
        centerYConstraint.constant = 0
        widthConstraint.constant = 0
        heightConstraint.constant = 0
        stickImageView.layoutIfNeeded()
        
        virtualThumbstickDelegate.touchUpInside(thumbstickType, (0, 0))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        
        let halfWidth: Float = Float(frame.width / 2)
        let halfHeight: Float = Float(frame.height / 2)
        
        let offset = position(in: self, with: touch.location(in: self))
        
        centerXConstraint.constant = CGFloat((offset.x * halfWidth).clamped(to: -halfWidth...halfWidth))
        centerYConstraint.constant = CGFloat((-offset.y * halfHeight).clamped(to: -halfHeight...halfHeight))
        stickImageView.layoutIfNeeded()
        
        virtualThumbstickDelegate.touchDragInside(thumbstickType, position(in: self, with: touch.location(in: self)))
    }
}
