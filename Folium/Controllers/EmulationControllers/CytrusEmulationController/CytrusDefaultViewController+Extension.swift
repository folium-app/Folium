//
//  CytrusDefaultViewController+Extension.swift
//  Folium
//
//  Created by Jarrod Norwell on 16/6/2024.
//

#if canImport(Cytrus)

import Cytrus
import Foundation
import GameController
import UIKit

// MARK: Subviews {
extension CytrusDefaultViewController {
    func addSubviews() {
        guard let device = skin.devices.first(where: { $0.device == machine && $0.orientation == orientationForCurrentOrientation() }),
              let screen = device.screens.first else {
            return
        }
        
        metalView = MTKView(frame: .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height), device: MTLCreateSystemDefaultDevice())
        if let cornerRadius = screen.cornerRadius, cornerRadius > 0 {
            metalView.clipsToBounds = true
            metalView.layer.cornerCurve = .continuous
            metalView.layer.cornerRadius = cornerRadius
        }
        view.addSubview(metalView)
        
        cytrus.setMTKView(metalView, metalView.frame.size)
        
        controllerView = .init(with: device, delegates: (button: self, thumbstick: self), skin: skin)
        controllerView.translatesAutoresizingMaskIntoConstraints = false
        if let alpha = device.alpha {
            controllerView.alpha = alpha
        }
        view.addSubview(controllerView)
        view.bringSubviewToFront(controllerView)
        
        controllerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controllerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        controllerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        controllerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        var config = UIButton.Configuration.plain()
        config.buttonSize = .small
        config.image = .init(systemName: "gearshape.fill")?
            .applyingSymbolConfiguration(.init(paletteColors: [.white]))
        
        button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.showsMenuAsPrimaryAction = true
        button.menu = CytrusManager.shared.menu(button, self, true)
        view.addSubview(button)
        
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
}

// MARK: Notifications
extension CytrusDefaultViewController {
    func addNotifications() {
        NotificationCenter.default.addObserver(forName: .init("sceneDidChange"), object: nil, queue: .main) { notification in
            guard let state = notification.object as? SceneDelegate.ApplicationState else {
                return
            }
            
            self.cytrus.pausePlay(state == .foreground)
            self.button.menu = CytrusManager.shared.menu(self.button, self, true)
        }
        
        NotificationCenter.default.addObserver(forName: .init("openKeyboard"), object: nil, queue: .main) { notification in
            guard let config = notification.object as? KeyboardConfig else {
                return
            }
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertController.perform(NSSelectorFromString("_setHeaderContentViewController:"), with: KeyboardController(keyboardConfig: config))
            alertController.addAction(.init(title: "Cancel", style: .cancel))
            self.present(alertController, animated: true)
        }
        
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
            guard let device = self.skin.devices.first(where: { $0.device == machine && $0.orientation == self.orientationForCurrentOrientation() }) else {
                return
            }
            
            guard let screen = device.screens.first else {
                return
            }
            
            guard let window = self.view.window, let windowScene = window.windowScene else {
                return
            }
            
            self.metalView.frame = .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height)
            self.cytrus.setMTKViewSize(size: self.metalView.frame.size)
            self.cytrus.orientationChanged(windowScene.interfaceOrientation, self.metalView)
            
            self.controllerView.orientationChanged(with: device)
        }
        
        NotificationCenter.default.addObserver(forName: .init(NSNotification.Name.GCControllerDidConnect), object: nil, queue: .main, using: controllerDidConnect)
        NotificationCenter.default.addObserver(forName: .init(NSNotification.Name.GCControllerDidDisconnect), object: nil, queue: .main, using: controllerDidDisconnect)
    }
    
    func controllerDidConnect(_ notification: Notification) {
        guard let controller = notification.object as? GCController, let extendedGamepad = controller.extendedGamepad else {
            return
        }
        
        extendedGamepad.buttonA.pressedChangedHandler = { $2 ? self.touchBegan(with: .a) : self.touchEnded(with: .a) }
        extendedGamepad.buttonB.pressedChangedHandler = { $2 ? self.touchBegan(with: .b) : self.touchEnded(with: .b) }
        extendedGamepad.buttonX.pressedChangedHandler = { $2 ? self.touchBegan(with: .x) : self.touchEnded(with: .x) }
        extendedGamepad.buttonY.pressedChangedHandler = { $2 ? self.touchBegan(with: .y) : self.touchBegan(with: .y) }
        
        extendedGamepad.dpad.up.pressedChangedHandler = { $2 ? self.touchBegan(with: .dpadUp) : self.touchEnded(with: .dpadUp) }
        extendedGamepad.dpad.down.pressedChangedHandler = { $2 ? self.touchBegan(with: .dpadDown) : self.touchEnded(with: .dpadDown) }
        extendedGamepad.dpad.left.pressedChangedHandler = { $2 ? self.touchBegan(with: .dpadLeft) : self.touchEnded(with: .dpadLeft) }
        extendedGamepad.dpad.right.pressedChangedHandler = { $2 ? self.touchBegan(with: .dpadRight) : self.touchEnded(with: .dpadRight) }
        
        extendedGamepad.leftShoulder.pressedChangedHandler = { $2 ? self.touchBegan(with: .l) : self.touchBegan(with: .l) }
        extendedGamepad.rightShoulder.pressedChangedHandler = { $2 ? self.touchBegan(with: .r) : self.touchBegan(with: .r) }
        
        extendedGamepad.leftTrigger.pressedChangedHandler = { $2 ? self.touchBegan(with: .zl) : self.touchBegan(with: .zl) }
        extendedGamepad.rightTrigger.pressedChangedHandler = { $2 ? self.touchBegan(with: .zr) : self.touchBegan(with: .zr) }
        
        // TODO: home
        extendedGamepad.buttonOptions?.pressedChangedHandler = { $2 ? self.touchBegan(with: .minus) : self.touchEnded(with: .minus) }
        extendedGamepad.buttonMenu.pressedChangedHandler = { $2 ? self.touchBegan(with: .plus) : self.touchEnded(with: .plus) }
        
        extendedGamepad.leftThumbstick.valueChangedHandler = { self.cytrus.thumbstickMoved(.circlePad, $1, $2) }
        extendedGamepad.rightThumbstick.valueChangedHandler = { self.cytrus.thumbstickMoved(.cStick, $1, $2) }
        
        UIView.animate(withDuration: 0.2) {
            self.controllerView.alpha = 0
        }
    }
    
    func controllerDidDisconnect(_ notification: Notification) {
        UIView.animate(withDuration: 0.2) {
            self.controllerView.alpha = 1
        }
    }
}

// MARK: UIResponder
extension CytrusDefaultViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first, let view = touch.view, view == metalView else {
            return
        }
        
        cytrus.touchBegan(touch.location(in: view))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let _ = touches.first else {
            return
        }
        
        cytrus.touchEnded()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first, let view = touch.view, view == metalView else {
            return
        }
        
        cytrus.touchMoved(touch.location(in: view))
    }
}

// MARK: Button Delegate
extension CytrusDefaultViewController : ControllerButtonDelegate {
    func touchBegan(with type: Button.`Type`) {
        switch type {
        case .a:
            cytrus.virtualControllerButtonDown(.A)
        case .b:
            cytrus.virtualControllerButtonDown(.B)
        case .x:
            cytrus.virtualControllerButtonDown(.X)
        case .y:
            cytrus.virtualControllerButtonDown(.Y)
            
        case .dpadUp:
            cytrus.virtualControllerButtonDown(.directionalPadUp)
        case .dpadDown:
            cytrus.virtualControllerButtonDown(.directionalPadDown)
        case .dpadLeft:
            cytrus.virtualControllerButtonDown(.directionalPadLeft)
        case .dpadRight:
            cytrus.virtualControllerButtonDown(.directionalPadRight)
            
        case .l:
            cytrus.virtualControllerButtonDown(.triggerL)
        case .r:
            cytrus.virtualControllerButtonDown(.triggerR)
            
        case .zl:
            cytrus.virtualControllerButtonDown(.triggerZL)
        case .zr:
            cytrus.virtualControllerButtonDown(.triggerZR)
            
        case .home:
            cytrus.virtualControllerButtonDown(.home)
        case .minus:
            cytrus.virtualControllerButtonDown(.select)
        case .plus:
            cytrus.virtualControllerButtonDown(.start)
        }
    }
    
    func touchEnded(with type: Button.`Type`) {
        switch type {
        case .a:
            cytrus.virtualControllerButtonUp(.A)
        case .b:
            cytrus.virtualControllerButtonUp(.B)
        case .x:
            cytrus.virtualControllerButtonUp(.X)
        case .y:
            cytrus.virtualControllerButtonUp(.Y)
            
        case .dpadUp:
            cytrus.virtualControllerButtonUp(.directionalPadUp)
        case .dpadDown:
            cytrus.virtualControllerButtonUp(.directionalPadDown)
        case .dpadLeft:
            cytrus.virtualControllerButtonUp(.directionalPadLeft)
        case .dpadRight:
            cytrus.virtualControllerButtonUp(.directionalPadRight)
            
        case .l:
            cytrus.virtualControllerButtonUp(.triggerL)
        case .r:
            cytrus.virtualControllerButtonUp(.triggerR)
            
        case .zl:
            cytrus.virtualControllerButtonUp(.triggerZL)
        case .zr:
            cytrus.virtualControllerButtonUp(.triggerZR)
            
        case .home:
            cytrus.virtualControllerButtonUp(.home)
        case .minus:
            cytrus.virtualControllerButtonUp(.select)
        case .plus:
            cytrus.virtualControllerButtonUp(.start)
        }
    }
    
    func touchMoved(with type: Button.`Type`) {}
}

// MARK: Thumbstick Delegate
extension CytrusDefaultViewController : ControllerThumbstickDelegate {
    func touchBegan(with type: Thumbstick.`Type`, position: (x: Float, y: Float)) {
        cytrus.thumbstickMoved(type == .left ? .circlePad : .cStick, position.x, position.y)
    }
    
    func touchEnded(with type: Thumbstick.`Type`, position: (x: Float, y: Float)) {
        cytrus.thumbstickMoved(type == .left ? .circlePad : .cStick, position.x, position.y)
    }
    
    func touchMoved(with type: Thumbstick.`Type`, position: (x: Float, y: Float)) {
        cytrus.thumbstickMoved(type == .left ? .circlePad : .cStick, position.x, position.y)
    }
}

#endif
