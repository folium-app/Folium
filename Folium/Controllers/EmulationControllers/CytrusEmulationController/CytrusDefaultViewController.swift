//
//  CytrusDefaultViewController.swift
//  Folium
//
//  Created by Jarrod Norwell on 9/6/2024.
//

import Cytrus
import Foundation
import GameController
import MetalKit
import UIKit

class CytrusDefaultViewController : UIViewController {
    fileprivate var controllerView: ControllerView!
    fileprivate var mtkView: MTKView!
    
    let cytrus: Cytrus = .shared
    
    fileprivate var game: AnyHashable
    fileprivate var skin: Skin
    init(with game: AnyHashable, skin: Skin) {
        self.game = game
        self.skin = skin
        super.init(nibName: nil, bundle: nil)
        cytrus.getVulkanLibrary()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        guard let device = skin.devices.first(where: { $0.device == machine && $0.orientation == orientationForCurrentOrientation() }) else {
            return
        }
        
        guard let screen = device.screens.first else {
            return
        }
        
        mtkView = MTKView(frame: .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height), device: MTLCreateSystemDefaultDevice())
        view.addSubview(mtkView)
        
        cytrus.setMTKView(mtkView, mtkView.frame.size)
        
        Thread.setThreadPriority(1.0)
        Thread.detachNewThread(run)
        
        controllerView = .init(with: device, delegates: (button: self, thumbstick: self), skin: skin)
        controllerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controllerView)
        
        controllerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controllerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        controllerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        controllerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        var config = UIButton.Configuration.plain()
        config.buttonSize = traitCollection.userInterfaceIdiom == .pad ? .medium : .small
        config.image = .init(systemName: "gearshape.fill")?
            .applyingSymbolConfiguration(.init(paletteColors: [.white]))
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.showsMenuAsPrimaryAction = true
        button.menu = CytrusManager.shared.menu(button, self, true)
        view.addSubview(button)
        
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        NotificationCenter.default.addObserver(forName: .init("sceneDidChange"), object: nil, queue: .main) { notification in
            guard let userInfo = notification.userInfo, let state = userInfo["state"] as? Int else {
                return
            }
            
            self.cytrus.pausePlay(state == 1)
            button.menu = CytrusManager.shared.menu(button, self, true)
        }
        
        NotificationCenter.default.addObserver(forName: .init("openKeyboard"), object: nil, queue: .main) { notification in
            guard let config = notification.object as? KeyboardConfig else {
                return
            }
            
            let selector = NSSelectorFromString("_setHeaderContentViewController:")
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertController.perform(selector, with: KeyboardController(keyboardConfig: config))
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
            
            self.mtkView.frame = .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height)
            self.cytrus.setMTKViewSize(size: self.mtkView.frame.size)
            self.cytrus.orientationChanged(windowScene.interfaceOrientation, self.mtkView)
            
            self.controllerView.orientationChanged(with: device)
        }
        
        NotificationCenter.default.addObserver(forName: .init(NSNotification.Name.GCControllerDidConnect), object: nil, queue: .main, using: controllerDidConnect)
        NotificationCenter.default.addObserver(forName: .init(NSNotification.Name.GCControllerDidDisconnect), object: nil, queue: .main, using: controllerDidDisconnect)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .init("sceneDidChange"), object: nil)
        NotificationCenter.default.removeObserver(self, name: .init("openKeyboard"), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.GCControllerDidConnect, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.GCControllerDidDisconnect, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let orientations = skin.devices.reduce(into: [Skin.Device.Orientation](), { $0.append($1.orientation) })
        
        let containsPortrait = orientations.contains(.portrait)
        let containsLandscape = orientations.contains(.landscape)
        
        if containsPortrait && containsLandscape {
            return [.all]
        } else if containsPortrait {
            return [.portrait, .portraitUpsideDown]
        } else if containsLandscape {
            return [.landscape]
        } else {
            return [.all]
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first, let view = touch.view, view == mtkView else {
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
        guard let touch = touches.first, let view = touch.view, view == mtkView else {
            return
        }
        
        cytrus.touchMoved(touch.location(in: view))
    }
}

extension CytrusDefaultViewController {
    func controllerDidConnect(_ notification: Notification) {
        guard let controller = notification.object as? GCController else {
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            self.controllerView.alpha = 0
        }
    }
    
    func controllerDidDisconnect(_ notification: Notification) {
        guard let controller = notification.object as? GCController, let extendedGamepad = controller.extendedGamepad else {
            return
        }
        
        extendedGamepad.dpad.up.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .dpadUp) : self.touchEnded(with: .dpadUp)
        }
        
        extendedGamepad.dpad.down.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .dpadDown) : self.touchEnded(with: .dpadDown)
        }
        
        extendedGamepad.dpad.left.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .dpadLeft) : self.touchEnded(with: .dpadLeft)
        }
        
        extendedGamepad.dpad.right.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .dpadRight) : self.touchEnded(with: .dpadRight)
        }
        
        // extendedGamepad.buttonOptions?.pressedChangedHandler = { button, value, pressed in
        //     pressed ? self.touchDown(.minus) : self.touchUpInside(.minus)
        // }
        //
        // extendedGamepad.buttonMenu.pressedChangedHandler = { button, value, pressed in
        //     pressed ? self.touchDown(.plus) : self.touchUpInside(.plus)
        // }
        
        extendedGamepad.buttonA.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .east) : self.touchEnded(with: .east)
        }
        
        extendedGamepad.buttonB.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .south) : self.touchEnded(with: .south)
        }
        
        extendedGamepad.buttonX.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .north) : self.touchEnded(with: .north)
        }
        
        extendedGamepad.buttonY.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .west) : self.touchBegan(with: .west)
        }
        
        extendedGamepad.leftShoulder.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .l) : self.touchBegan(with: .l)
        }
        
        extendedGamepad.leftTrigger.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .zl) : self.touchBegan(with: .zl)
        }
        
        extendedGamepad.rightShoulder.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .r) : self.touchBegan(with: .r)
        }
        
        extendedGamepad.rightTrigger.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .zr) : self.touchBegan(with: .zr)
        }
        
        extendedGamepad.leftThumbstick.valueChangedHandler = { dpad, x, y in
            self.cytrus.thumbstickMoved(.circlePad, x, y)
        }
        
        extendedGamepad.rightThumbstick.valueChangedHandler = { dpad, x, y in
            self.cytrus.thumbstickMoved(.cStick, x, y)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.controllerView.alpha = 1
        }
    }
    
    func orientationForCurrentOrientation() -> Skin.Device.Orientation {
        switch UIApplication.shared.statusBarOrientation {
        case .unknown, .portrait, .portraitUpsideDown:
            .portrait
        case .landscapeLeft, .landscapeRight:
            .landscape
        }
    }
    
    @objc func run() {
        guard let game = game as? CytrusManager.Library.Game else {
            return
        }
        
        cytrus.run(game.fileDetails.url)
    }
}

extension CytrusDefaultViewController : ControllerButtonDelegate {
    func touchBegan(with type: Skin.Button.`Type`) {
        switch type {
        case .dpadUp:
            cytrus.virtualControllerButtonDown(.directionalPadUp)
        case .dpadDown:
            cytrus.virtualControllerButtonDown(.directionalPadDown)
        case .dpadLeft:
            cytrus.virtualControllerButtonDown(.directionalPadLeft)
        case .dpadRight:
            cytrus.virtualControllerButtonDown(.directionalPadRight)
        case .east:
            cytrus.virtualControllerButtonDown(.A)
        case .south:
            cytrus.virtualControllerButtonDown(.B)
        case .north:
            cytrus.virtualControllerButtonDown(.X)
        case .west:
            cytrus.virtualControllerButtonDown(.Y)
        case .l:
            cytrus.virtualControllerButtonDown(.triggerL)
        case .zl:
            cytrus.virtualControllerButtonDown(.triggerZL)
        case .r:
            cytrus.virtualControllerButtonDown(.triggerR)
        case .zr:
            cytrus.virtualControllerButtonDown(.triggerZR)
        default:
            break
        }
    }
    
    func touchEnded(with type: Skin.Button.`Type`) {
        switch type {
        case .dpadUp:
            cytrus.virtualControllerButtonUp(.directionalPadUp)
        case .dpadDown:
            cytrus.virtualControllerButtonUp(.directionalPadDown)
        case .dpadLeft:
            cytrus.virtualControllerButtonUp(.directionalPadLeft)
        case .dpadRight:
            cytrus.virtualControllerButtonUp(.directionalPadRight)
        case .east:
            cytrus.virtualControllerButtonUp(.A)
        case .south:
            cytrus.virtualControllerButtonUp(.B)
        case .north:
            cytrus.virtualControllerButtonUp(.X)
        case .west:
            cytrus.virtualControllerButtonUp(.Y)
        case .l:
            cytrus.virtualControllerButtonUp(.triggerL)
        case .zl:
            cytrus.virtualControllerButtonUp(.triggerZL)
        case .r:
            cytrus.virtualControllerButtonUp(.triggerR)
        case .zr:
            cytrus.virtualControllerButtonUp(.triggerZR)
        default:
            break
        }
    }
    
    func touchMoved(with type: Skin.Button.`Type`) {}
}

extension CytrusDefaultViewController : ControllerThumbstickDelegate {
    func touchBegan(with type: Skin.Thumbstick.`Type`, position: (x: Float, y: Float)) {
        cytrus.thumbstickMoved(type == .left ? .circlePad : .cStick, position.x, position.y)
    }
    
    func touchEnded(with type: Skin.Thumbstick.`Type`, position: (x: Float, y: Float)) {
        cytrus.thumbstickMoved(type == .left ? .circlePad : .cStick, position.x, position.y)
    }
    
    func touchMoved(with type: Skin.Thumbstick.`Type`, position: (x: Float, y: Float)) {
        cytrus.thumbstickMoved(type == .left ? .circlePad : .cStick, position.x, position.y)
    }
}
