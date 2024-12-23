//
//  Nintendo3DSEmulationController.swift
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

class Nintendo3DSEmulationController : LastPlayedPlayTimeController {
    var controllerView: ControllerView? = nil
    var metalView: MTKView? = nil
    
    var skin: Skin
    init(game: Nintendo3DSGame, skin: Skin) {
        self.skin = skin
        super.init(game: game)
        Cytrus.shared.allocateVulkanLibrary()
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
        
        guard let metalView else {
            return
        }
        
        controllerView = .init(orientation: orientation, skin: skin, delegates: (self, self))
        guard let controllerView, let screensView = controllerView.screensView else {
            return
        }
        
        controllerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controllerView)
        
        controllerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controllerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        controllerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        controllerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        screensView.addSubview(metalView)
        Cytrus.shared.allocateMetalLayer(for: metalView.layer as! CAMetalLayer, with: metalView.bounds.size)
        
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
                guard let game = self.game as? Nintendo3DSGame else {
                    return
                }
                
                let cheatsController = UINavigationController(rootViewController: CheatsController(titleIdentifier: game.titleIdentifier))
                cheatsController.modalPresentationStyle = .fullScreen
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
                Cytrus.shared.pausePlay(Cytrus.shared.isPaused())
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
                if pressed {
                    self.touchBegan(with: .a)
                } else {
                    self.touchEnded(with: .a)
                }
            }
            
            extendedGamepad.buttonB.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .b)
                } else {
                    self.touchEnded(with: .b)
                }
            }
            
            extendedGamepad.buttonX.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .x)
                } else {
                    self.touchEnded(with: .x)
                }
            }
            
            extendedGamepad.buttonY.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .y)
                } else {
                    self.touchEnded(with: .y)
                }
            }
            
            extendedGamepad.dpad.up.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .dpadUp)
                } else {
                    self.touchEnded(with: .dpadUp)
                }
            }
            
            extendedGamepad.dpad.down.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .dpadDown)
                } else {
                    self.touchEnded(with: .dpadDown)
                }
            }
            
            extendedGamepad.dpad.left.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .dpadLeft)
                } else {
                    self.touchEnded(with: .dpadLeft)
                }
            }
            
            extendedGamepad.dpad.right.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .dpadRight)
                } else {
                    self.touchEnded(with: .dpadRight)
                }
            }
            
            extendedGamepad.leftThumbstick.valueChangedHandler = { element, x, y in
                self.touchMoved(with: .left, position: (x, y))
            }
            
            extendedGamepad.rightThumbstick.valueChangedHandler = { element, x, y in
                self.touchMoved(with: .right, position: (x, y))
            }
            
            extendedGamepad.leftShoulder.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .l)
                } else {
                    self.touchEnded(with: .l)
                }
            }
            
            extendedGamepad.rightShoulder.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .r)
                } else {
                    self.touchEnded(with: .r)
                }
            }
            
            extendedGamepad.leftTrigger.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .zl)
                } else {
                    self.touchEnded(with: .zl)
                }
            }
            
            extendedGamepad.rightTrigger.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .zr)
                } else {
                    self.touchEnded(with: .zr)
                }
            }
            
            extendedGamepad.buttonOptions?.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .minus)
                } else {
                    self.touchEnded(with: .minus)
                }
            }
            
            extendedGamepad.buttonMenu.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .plus)
                } else {
                    self.touchEnded(with: .plus)
                }
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
            
            Cytrus.shared.pausePlay(applicationState == .foregrounded)
        }
        
        NotificationCenter.default.addObserver(forName: .init("openKeyboard"), object: nil, queue: .main) { notification in
            guard let config = notification.object as? KeyboardConfig else {
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
            
            
            
            switch config.buttonConfig {
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        if Cytrus.shared.stopped() {
            Cytrus.shared.deallocateVulkanLibrary()
            Cytrus.shared.deallocateMetalLayers()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !Cytrus.shared.running() {
            Thread.setThreadPriority(1.0)
            Thread.detachNewThread(boot)
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
            
            controllerView.updateFrames(for: orientation, controllerConnected: GCController.controllers().count > 0)
            
            metalView.frame = if !orientation.screens.isEmpty, let screen = orientation.screens.first {
                .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height)
            } else {
                self.view.bounds
            }
            
            Cytrus.shared.orientationChange(with: self.interfaceOrientation(), using: metalView)
        }
    }
    
    @objc fileprivate func boot() {
        Cytrus.shared.insertCartridgeAndBoot(with: game.fileDetails.url)
    }
}

// MARK: Touches
extension Nintendo3DSEmulationController {
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
extension Nintendo3DSEmulationController : ControllerButtonDelegate {
    func touchBegan(with type: Button.`Type`) {
        switch type {
        case .a:
            Cytrus.shared.virtualControllerButtonDown(.A)
        case .b:
            Cytrus.shared.virtualControllerButtonDown(.B)
        case .x:
            Cytrus.shared.virtualControllerButtonDown(.X)
        case .y:
            Cytrus.shared.virtualControllerButtonDown(.Y)
            
        case .dpadUp:
            Cytrus.shared.virtualControllerButtonDown(.directionalPadUp)
        case .dpadDown:
            Cytrus.shared.virtualControllerButtonDown(.directionalPadDown)
        case .dpadLeft:
            Cytrus.shared.virtualControllerButtonDown(.directionalPadLeft)
        case .dpadRight:
            Cytrus.shared.virtualControllerButtonDown(.directionalPadRight)
            
        case .l:
            Cytrus.shared.virtualControllerButtonDown(.triggerL)
        case .r:
            Cytrus.shared.virtualControllerButtonDown(.triggerR)
            
        case .zl:
            Cytrus.shared.virtualControllerButtonDown(.triggerZL)
        case .zr:
            Cytrus.shared.virtualControllerButtonDown(.triggerZR)
            
        case .home:
            Cytrus.shared.virtualControllerButtonDown(.home)
        case .minus:
            Cytrus.shared.virtualControllerButtonDown(.select)
        case .plus:
            Cytrus.shared.virtualControllerButtonDown(.start)
            
        default:
            break
        }
    }
    
    func touchEnded(with type: Button.`Type`) {
        switch type {
        case .a:
            Cytrus.shared.virtualControllerButtonUp(.A)
        case .b:
            Cytrus.shared.virtualControllerButtonUp(.B)
        case .x:
            Cytrus.shared.virtualControllerButtonUp(.X)
        case .y:
            Cytrus.shared.virtualControllerButtonUp(.Y)
            
        case .dpadUp:
            Cytrus.shared.virtualControllerButtonUp(.directionalPadUp)
        case .dpadDown:
            Cytrus.shared.virtualControllerButtonUp(.directionalPadDown)
        case .dpadLeft:
            Cytrus.shared.virtualControllerButtonUp(.directionalPadLeft)
        case .dpadRight:
            Cytrus.shared.virtualControllerButtonUp(.directionalPadRight)
            
        case .l:
            Cytrus.shared.virtualControllerButtonUp(.triggerL)
        case .r:
            Cytrus.shared.virtualControllerButtonUp(.triggerR)
            
        case .zl:
            Cytrus.shared.virtualControllerButtonUp(.triggerZL)
        case .zr:
            Cytrus.shared.virtualControllerButtonUp(.triggerZR)
            
        case .home:
            Cytrus.shared.virtualControllerButtonUp(.home)
        case .minus:
            Cytrus.shared.virtualControllerButtonUp(.select)
        case .plus:
            Cytrus.shared.virtualControllerButtonUp(.start)
            
        default:
            break
        }
    }
    
    func touchMoved(with type: Button.`Type`) {}
}

// MARK: Thumbstick Delegate
extension Nintendo3DSEmulationController : ControllerThumbstickDelegate {
    func touchBegan(with type: Thumbstick.`Type`, position: (x: Float, y: Float)) {
        Cytrus.shared.thumbstickMoved(type == .left ? .circlePad : .cStick, position.x, position.y)
    }
    
    func touchEnded(with type: Thumbstick.`Type`, position: (x: Float, y: Float)) {
        Cytrus.shared.thumbstickMoved(type == .left ? .circlePad : .cStick, position.x, position.y)
    }
    
    func touchMoved(with type: Thumbstick.`Type`, position: (x: Float, y: Float)) {
        Cytrus.shared.thumbstickMoved(type == .left ? .circlePad : .cStick, position.x, position.y)
    }
}
