//
//  ControllerView.swift
//  Folium
//
//  Created by Jarrod Norwell on 4/6/2024.
//

import Foundation
import UIKit

var machine: String {
    var utsnameInstance = utsname()
    uname(&utsnameInstance)
    let optionalString: String? = withUnsafePointer(to: &utsnameInstance.machine) {
        $0.withMemoryRebound(to: CChar.self, capacity: 1) {
            ptr in String.init(validatingUTF8: ptr)
        }
    }
    return optionalString ?? "N/A"
}

class PassthroughView : UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        super.hitTest(point, with: event) == self ? nil : super.hitTest(point, with: event)
    }
}

class ScreensView : UIView {}

class ControllerView : PassthroughView {
    var screensView: ScreensView? = nil
    var imageView: UIImageView? = nil
    
    var orientation: Orientation
    var skin: Skin
    var delegates: (button: ControllerButtonDelegate?, thumbstick: ControllerThumbstickDelegate?)
    init(orientation: Orientation, skin: Skin, delegates: (button: ControllerButtonDelegate?, thumbstick: ControllerThumbstickDelegate?)) {
        self.orientation = orientation
        self.skin = skin
        self.delegates = delegates
        super.init(frame: .zero)
        
        screensView = .init()
        guard let screensView else {
            return
        }
        
        screensView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(screensView)
        
        screensView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        screensView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        screensView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        screensView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        imageView = if let backgroundImageName = orientation.backgroundImageName, let url = skin.url {
            .init(image: .init(contentsOfFile: url
                .appendingPathComponent("backgrounds", conformingTo: .folder)
                .appendingPathComponent(backgroundImageName, conformingTo: .fileURL)
                .path
            ))
        } else {
            .init()
        }
        
        guard let imageView else {
            return
        }
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        orientation.thumbsticks.forEach { thumbstick in
            let controllerThumbstick = ControllerThumbstick(thumbstick: thumbstick, skin: skin, delegate: delegates.thumbstick)
            controllerThumbstick.frame = .init(x: thumbstick.x, y: thumbstick.y, width: thumbstick.width, height: thumbstick.height)
            controllerThumbstick.alpha = orientation.sharedAlpha ?? thumbstick.alpha ?? 1
            addSubview(controllerThumbstick)
        }
        
        orientation.buttons.forEach { button in
            let controllerButton = ControllerButton(button: button, skin: skin, delegate: delegates.button)
            controllerButton.frame = .init(x: button.x, y: button.y, width: button.width, height: button.height)
            controllerButton.alpha = orientation.sharedAlpha ?? button.alpha ?? 1
            addSubview(controllerButton)
        }
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        touches.forEach { touch in
            guard let currentlyTouchedSubviews = subviews.filter({ $0.isKind(of: ControllerButton.classForCoder() )}) as? [ControllerButton] else {
                return
            }
    
            currentlyTouchedSubviews.forEach { button in
                if button.frame.contains(touch.location(in: self)) {
                    button.touchDown()
                } else {
                    button.touchUpInside()
                }
            }
        }
    }
    
    func updateFrames(for orientation: Orientation, controllerConnected: Bool = false) {
        subviews.filter {
            $0.isKind(of: ControllerButton.classForCoder()) || $0.isKind(of: ControllerThumbstick.classForCoder())
        }.forEach { $0.removeFromSuperview() }
        
        self.orientation = orientation
        
        guard let imageView else {
            return
        }
        
        if let backgroundImageName = orientation.backgroundImageName, let url = skin.url {
            imageView.image = .init(contentsOfFile: url
                .appendingPathComponent("backgrounds", conformingTo: .folder)
                .appendingPathComponent(backgroundImageName, conformingTo: .fileURL)
                .path
            )
        }
        
        orientation.thumbsticks.forEach { thumbstick in
            let controllerThumbstick = ControllerThumbstick(thumbstick: thumbstick, skin: skin, delegate: delegates.thumbstick)
            controllerThumbstick.frame = .init(x: thumbstick.x, y: thumbstick.y, width: thumbstick.width, height: thumbstick.height)
            addSubview(controllerThumbstick)
        }
        
        orientation.buttons.forEach { button in
            let controllerButton = ControllerButton(button: button, skin: skin, delegate: delegates.button)
            controllerButton.frame = .init(x: button.x, y: button.y, width: button.width, height: button.height)
            addSubview(controllerButton)
        }
        
        controllerConnected ? hide() : show()
    }
    
    func hide() {
        UIView.transition(with: self, duration: 0.2) {
            self.subviews.filter {
                $0.isKind(of: ControllerButton.classForCoder()) || $0.isKind(of: ControllerThumbstick.classForCoder())
            }.forEach { $0.alpha = 0 }
        }
    }
    
    func show() {
        UIView.transition(with: self, duration: 0.2) {
            self.subviews.filter {
                $0.isKind(of: ControllerButton.classForCoder()) || $0.isKind(of: ControllerThumbstick.classForCoder())
            }.forEach { $0.alpha = 1 }
        }
    }
}
