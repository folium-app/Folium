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
    
    var thumbstickType: ThumbstickType
    var virtualThumbstickDelegate: VirtualControllerThumbstickDelegate
    init(_ thumbstickType: ThumbstickType, _ virtualThumbstickDelegate: VirtualControllerThumbstickDelegate) {
        self.thumbstickType = thumbstickType
        self.virtualThumbstickDelegate = virtualThumbstickDelegate
        super.init(frame: .zero)
        isUserInteractionEnabled = true
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
        guard let touch = touches.first else {
            return
        }
        
        virtualThumbstickDelegate.touchDown(thumbstickType, position(in: self, with: touch.location(in: self)))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        virtualThumbstickDelegate.touchUpInside(thumbstickType, (0, 0))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        
        virtualThumbstickDelegate.touchDragInside(thumbstickType, position(in: self, with: touch.location(in: self)))
    }
}
