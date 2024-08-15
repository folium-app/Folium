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

class ControllerView : PassthroughView {
    var screensView: UIView? = nil
    
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
    
    func updateFrames(for orientation: Orientation) {
        subviews.filter {
            $0.isKind(of: ControllerButton.classForCoder()) || $0.isKind(of: ControllerThumbstick.classForCoder())
        }.forEach { $0.removeFromSuperview() }
        
        self.orientation = orientation
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
        
        /*
        subviews.filter { $0.isKind(of: ControllerButton.classForCoder()) || $0.isKind(of: ControllerThumbstick.classForCoder()) }.forEach { subview in
            switch subview {
            case let button as ControllerButton:
                guard let orientationButton = self.orientation.buttons.first(where: { $0 == button.button }) else {
                    return
                }
                
                button.frame = .init(x: orientationButton.x, y: orientationButton.y, width: orientationButton.width, height: orientationButton.height)
            case let thumbstick as ControllerThumbstick:
                guard let orientationThumbstick = self.orientation.thumbsticks.first(where: { $0 == thumbstick.thumbstick }) else {
                    return
                }
                
                thumbstick.frame = .init(x: orientationThumbstick.x, y: orientationThumbstick.y, width: orientationThumbstick.width, height: orientationThumbstick.height)
            default:
                break
            }
        }*/
    }
}

/*
class ControllerView : PassthroughView {
    var device: Device
    var delegates: (button: ControllerButtonDelegate, thumbstick: ControllerThumbstickDelegate?)
    var skin: Skin
    init(with device: Device, delegates: (button: ControllerButtonDelegate, thumbstick: ControllerThumbstickDelegate?), skin: Skin) {
        self.device = device
        self.delegates = delegates
        self.skin = skin
        super.init(frame: .zero)
        
        if let backgroundImageName = device.backgroundImageName, let path = skin.path {
            let imageView = UIImageView(image: .init(contentsOfFile: path
                .appendingPathComponent("backgrounds", conformingTo: .folder)
                .appendingPathComponent(machine, conformingTo: .folder)
                .appendingPathComponent(backgroundImageName, conformingTo: .fileURL).path))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.alpha = (skin.isDebug ?? false) ? 0.33 : 1
            addSubview(imageView)
            
            imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        }
        
        device.thumbsticks.forEach { thumbstick in
            let controllerThumbstick = ControllerThumbstick(with: thumbstick, delegate: delegates.thumbstick, skin: skin)
            controllerThumbstick.frame = .init(x: thumbstick.x, y: thumbstick.y, width: thumbstick.width, height: thumbstick.height)
            addSubview(controllerThumbstick)
        }
        
        device.buttons.forEach { button in
            let controllerButton = ControllerButton(with: button, colors: skin.core.newButtonColors[button.type] ?? (.black, .white), delegate: delegates.button, skin: skin)
            controllerButton.frame = .init(x: button.x, y: button.y, width: button.width, height: button.height)
            addSubview(controllerButton)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func orientationChanged(with device: Device) {
        subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        
        if let backgroundImageName = device.backgroundImageName, let path = skin.path {
            let imageView = UIImageView(image: .init(contentsOfFile: path
                .appendingPathComponent("backgrounds", conformingTo: .folder)
                .appendingPathComponent(machine, conformingTo: .folder)
                .appendingPathComponent(backgroundImageName, conformingTo: .fileURL).path))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(imageView)
            
            imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        }
        
        device.thumbsticks.forEach { thumbstick in
            let controllerThumbstick = ControllerThumbstick(with: thumbstick, delegate: delegates.thumbstick, skin: skin)
            controllerThumbstick.frame = .init(x: thumbstick.x, y: thumbstick.y, width: thumbstick.width, height: thumbstick.height)
            controllerThumbstick.layer.cornerCurve = .continuous
            controllerThumbstick.layer.cornerRadius = CGFloat(thumbstick.height / 2)
            addSubview(controllerThumbstick)
        }
        
        device.buttons.forEach { button in
            let controllerButton = ControllerButton(with: button, colors: skin.core.newButtonColors[button.type] ?? (.black, .white), delegate: delegates.button, skin: skin)
            controllerButton.frame = .init(x: button.x, y: button.y, width: button.width, height: button.height)
            addSubview(controllerButton)
        }
    }
}
*/
