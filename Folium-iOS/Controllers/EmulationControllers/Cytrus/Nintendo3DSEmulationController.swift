//
//  CytrusSkinController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 25/7/2024.
//

import AVFoundation
import Cytrus
import Foundation
import GameController
import MetalKit
import UIKit

class CytrusSkinController : LastPlayedPlayTimeController {
    var controllerView: ControllerView? = nil
    var metalView: MTKView? = nil
    
    var skin: Skin
    init(game: CytrusGame, skin: Skin) {
        self.skin = skin
        super.init(game: game)
        Cytrus.shared.allocate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        skin.orientations.supportedInterfaceOrientations
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        AVCaptureDevice.requestAccess(for: .video) { _ in }
        
        guard let orientation = skin.orientation(for: interfaceOrientation()) else {
            return
        }
        
        metalView = if !orientation.screens.isEmpty, let screen = orientation.screens.first {
            .init(frame: .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height), device: MTLCreateSystemDefaultDevice())
        } else {
            .init(frame: view.bounds, device: MTLCreateSystemDefaultDevice())
        }
        
        guard let metalView, let layer = metalView.layer as? CAMetalLayer else { return }
        
        controllerView = .init(orientation: orientation, skin: skin, delegates: (self, self))
        guard let controllerView else {
            return
        }
        
        controllerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controllerView)
        
        controllerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controllerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        controllerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        controllerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        view.insertSubview(metalView, belowSubview: controllerView)
        
        Cytrus.shared.initialize(layer, layer.bounds.size)
        
        var config = UIButton.Configuration.plain()
        config.buttonSize = .small
        config.cornerStyle = .capsule
        config.image = .init(systemName: "gearshape.fill")?
            .applyingSymbolConfiguration(.init(paletteColors: [.white]))
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.showsMenuAsPrimaryAction = true
        button.menu = .init(children: [
            UIAction(title: "Open Cheats", image: .init(systemName: "hammer"), handler: { _ in
                guard let game = self.game as? CytrusGame else {
                    return
                }
                
                let cheatsController = GameIntermediateController(game, fromGame: true)
                cheatsController.modalPresentationStyle = .overFullScreen
                self.present(cheatsController, animated: true)
            }),
            UIAction(title: "Open Settings", image: .init(systemName: "gearshape"), handler: { _ in
                var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                configuration.headerMode = .supplementary
                let listCollectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
                
                let cytrusSettingsController = UINavigationController(rootViewController: CytrusSettingsController(collectionViewLayout: listCollectionViewLayout))
                if let sheetPresentationController = cytrusSettingsController.sheetPresentationController {
                    sheetPresentationController.detents = [.medium(), .large()]
                }
                self.present(cytrusSettingsController, animated: true)
            }),
            UIAction(title: "Toggle Play/Pause", handler: { _ in
                Cytrus.shared.pause(!Cytrus.shared.isPaused())
            }),
            UIAction(title: "Stop & Exit", attributes: [.destructive], handler: { _ in
                let alertController = UIAlertController(title: "Stop & Exit", message: "Are you sure?", preferredStyle: .alert)
                alertController.addAction(.init(title: "Dismiss", style: .cancel))
                alertController.addAction(.init(title: "Stop & Exit", style: .destructive, handler: { _ in
                    Cytrus.shared.stop()
                    self.dismiss(animated: true)
                }))
                self.present(alertController, animated: true)
            })
        ])
        view.addSubview(button)
        
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        
        Task {
            await GCController.startWirelessControllerDiscovery()
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name.GCControllerDidConnect, object: nil, queue: .main) { notification in
            guard let controller = notification.object as? GCController, let extendedGamepad = controller.extendedGamepad else {
                return
            }
            
            if let controllerView = self.controllerView {
                controllerView.hide()
            }
            
            extendedGamepad.buttonA.pressedChangedHandler = { element, value, pressed in
                let handler: CytrusButtonHandler = pressed ? self.touchBegan : self.touchEnded
                handler(.a, controller.playerIndex)
            }
            
            extendedGamepad.buttonB.pressedChangedHandler = { element, value, pressed in
                let handler: CytrusButtonHandler = pressed ? self.touchBegan : self.touchEnded
                handler(.b, controller.playerIndex)
            }
            
            extendedGamepad.buttonX.pressedChangedHandler = { element, value, pressed in
                let handler: CytrusButtonHandler = pressed ? self.touchBegan : self.touchEnded
                handler(.x, controller.playerIndex)
            }
            
            extendedGamepad.buttonY.pressedChangedHandler = { element, value, pressed in
                let handler: CytrusButtonHandler = pressed ? self.touchBegan : self.touchEnded
                handler(.y, controller.playerIndex)
            }
            
            extendedGamepad.dpad.up.pressedChangedHandler = { element, value, pressed in
                let handler: CytrusButtonHandler = pressed ? self.touchBegan : self.touchEnded
                handler(.up, controller.playerIndex)
            }
            
            extendedGamepad.dpad.down.pressedChangedHandler = { element, value, pressed in
                let handler: CytrusButtonHandler = pressed ? self.touchBegan : self.touchEnded
                handler(.down, controller.playerIndex)
            }
            
            extendedGamepad.dpad.left.pressedChangedHandler = { element, value, pressed in
                let handler: CytrusButtonHandler = pressed ? self.touchBegan : self.touchEnded
                handler(.left, controller.playerIndex)
            }
            
            extendedGamepad.dpad.right.pressedChangedHandler = { element, value, pressed in
                let handler: CytrusButtonHandler = pressed ? self.touchBegan : self.touchEnded
                handler(.right, controller.playerIndex)
            }
            
            extendedGamepad.leftThumbstick.valueChangedHandler = { element, x, y in
                self.touchMoved(with: .left, position: (x, y), playerIndex: .index1)
            }
            
            extendedGamepad.rightThumbstick.valueChangedHandler = { element, x, y in
                self.touchMoved(with: .right, position: (x, y), playerIndex: .index1)
            }
            
            extendedGamepad.leftShoulder.pressedChangedHandler = { element, value, pressed in
                let handler: CytrusButtonHandler = pressed ? self.touchBegan : self.touchEnded
                handler(.l, controller.playerIndex)
            }
            
            extendedGamepad.rightShoulder.pressedChangedHandler = { element, value, pressed in
                let handler: CytrusButtonHandler = pressed ? self.touchBegan : self.touchEnded
                handler(.r, controller.playerIndex)
            }
            
            extendedGamepad.leftTrigger.pressedChangedHandler = { element, value, pressed in
                let handler: CytrusButtonHandler = pressed ? self.touchBegan : self.touchEnded
                handler(.zl, controller.playerIndex)
            }
            
            extendedGamepad.rightTrigger.pressedChangedHandler = { element, value, pressed in
                let handler: CytrusButtonHandler = pressed ? self.touchBegan : self.touchEnded
                handler(.zr, controller.playerIndex)
            }
            
            extendedGamepad.buttonHome?.pressedChangedHandler = { element, value, pressed in
                let handler: CytrusButtonHandler = pressed ? self.touchBegan : self.touchEnded
                handler(.home, controller.playerIndex)
            }
            
            extendedGamepad.buttonOptions?.pressedChangedHandler = { element, value, pressed in
                let handler: CytrusButtonHandler = pressed ? self.touchBegan : self.touchEnded
                handler(.minus, controller.playerIndex)
            }
            
            extendedGamepad.buttonMenu.pressedChangedHandler = { element, value, pressed in
                let handler: CytrusButtonHandler = pressed ? self.touchBegan : self.touchEnded
                handler(.plus, controller.playerIndex)
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name.GCControllerDidDisconnect, object: nil, queue: .main) { _ in
            if let controllerView = self.controllerView {
                controllerView.show()
            }
        }
        
        NotificationCenter.default.addObserver(forName: .init("applicationStateDidChange"), object: nil, queue: .main) { notification in
            guard let applicationState = notification.object as? ApplicationState else {
                return
            }
            
            Cytrus.shared.pause(applicationState.shouldPause)
        }
        
        NotificationCenter.default.addObserver(forName: .init("openKeyboard"), object: nil, queue: .main) { notification in
            guard let config = notification.object as? KeyboardButtonConfig else {
                return
            }
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            
            let cancelAction: UIAlertAction = .init(title: "Cancel", style: .cancel) { _ in
                NotificationCenter.default.post(name: .init("closeKeyboard"), object: nil, userInfo: [
                    "buttonPressed" : 0,
                    "keyboardText" : ""
                ])
            }
            
            let okayButton: UIAlertAction = .init(title: "Okay", style: .default) { _ in
                guard let textFields = alertController.textFields, let textField = textFields.first else {
                    return
                }
                
                NotificationCenter.default.post(name: .init("closeKeyboard"), object: nil, userInfo: [
                    "buttonPressed" : 0,
                    "keyboardText" : textField.text ?? ""
                ])
            }
            
            
            
            switch config {
            case .single:
                alertController.addAction(okayButton)
            case .dual:
                alertController.addAction(cancelAction)
                alertController.addAction(okayButton)
            case .triple:
                break
            case .none:
                break
            @unknown default:
                break
            }
            
            
            alertController.addTextField()
            self.present(alertController, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !Cytrus.shared.running() {
            Thread.setThreadPriority(1.0)
            Thread.detachNewThread(boot)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let cytrusGame = game as? CytrusGame {
            cytrusGame.update() // update cheats, saves, etc?
        }
        
        NotificationCenter.default.removeObserver(self)
        if Cytrus.shared.stopped() {
            Cytrus.shared.deallocate()
            Cytrus.shared.deinitialize()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in } completion: { _ in
            let skin = if let url = self.skin.url {
                try? SkinManager.shared.skin(from: url)
            } else {
                cytrusSkin
            }
            
            guard let skin, let metalView = self.metalView, let controllerView = self.controllerView else {
                return
            }
            
            self.skin = skin
            
            guard let orientation = skin.orientation(for: self.interfaceOrientation()) else {
                return
            }
            
            controllerView.updateFrames(for: orientation, controllerDisconnected: GCController.controllers().isEmpty)
            
            metalView.frame = if !orientation.screens.isEmpty, let screen = orientation.screens.first {
                .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height)
            } else {
                self.view.bounds
            }
            
            Cytrus.shared.orientationChange(with: self.interfaceOrientation(), using: metalView)
        }
    }
    
    @objc fileprivate func boot() {
        Cytrus.shared.insert(game.fileDetails.url)
    }
}

// MARK: Touches
extension CytrusSkinController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first, let view = touch.view, view == metalView else {
            return
        }
        
        Cytrus.shared.touchBegan(at: touch.location(in: view))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        Cytrus.shared.touchEnded()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first, let view = touch.view, view == metalView else {
            return
        }
        
        Cytrus.shared.touchMoved(at: touch.location(in: view))
    }
}

// MARK: Button Delegate
extension CytrusSkinController : ControllerButtonDelegate {
    func touchBegan(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
        guard let buttonType = CytrusButtonType.type(type.rawValue) else {
            // not a normal button, try custom ones
            switch type {
            case .loadState:
                Cytrus.shared.loadState { result in
                    UINotificationFeedbackGenerator().notificationOccurred(result ? .success : .error)
                }
            case .saveState:
                Cytrus.shared.saveState { result in
                    UINotificationFeedbackGenerator().notificationOccurred(result ? .success : .error)
                }
                
                if let viewController = UIApplication.shared.viewController as? CytrusDefaultController {
                    if let game = viewController.game as? CytrusGame {
                        game.update()
                    }
                }
            default:
                break
            }
            
            return
        }
        
        Cytrus.shared.input(playerIndex.rawValue, buttonType, true)
    }
    
    func touchEnded(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
        guard let buttonType = CytrusButtonType.type(type.rawValue) else { return }
        Cytrus.shared.input(playerIndex.rawValue, buttonType, false)
    }
    
    func touchMoved(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {}
}

// MARK: Thumbstick Delegate
extension CytrusSkinController : ControllerThumbstickDelegate {
    func touchBegan(with type: Thumbstick.`Type`, position: (x: Float, y: Float), playerIndex: GCControllerPlayerIndex) {
        Cytrus.shared.thumbstickMoved(type == .left ? .circlePad : .cStick, position.x, position.y)
    }
    
    func touchEnded(with type: Thumbstick.`Type`, position: (x: Float, y: Float), playerIndex: GCControllerPlayerIndex) {
        Cytrus.shared.thumbstickMoved(type == .left ? .circlePad : .cStick, position.x, position.y)
    }
    
    func touchMoved(with type: Thumbstick.`Type`, position: (x: Float, y: Float), playerIndex: GCControllerPlayerIndex) {
        Cytrus.shared.thumbstickMoved(type == .left ? .circlePad : .cStick, position.x, position.y)
    }
}
