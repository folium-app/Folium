//
//  CytrusDefaultController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 17/2/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Cytrus
import GameController
import Metal
import UIKit

class MTKCallbackView : MTKView {
    var callback: (() -> Void)? = nil
    
    override init(frame frameRect: CGRect, device: (any MTLDevice)?) {
        super.init(frame: frameRect, device: device)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw() {
        super.draw()
        if let callback {
            callback()
        }
    }
}

class CytrusDefaultController : SkinController {
    let cytrus: Cytrus = .shared
    var isRunning: Bool = false
    
    var topMetalCallbackView: MTKCallbackView? = nil
    var bottomMetalCallbackView: MTKCallbackView? = nil
    
    override init(game: GameBase, skin: Skin) {
        super.init(game: game, skin: skin)
        cytrus.allocate()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let controllerView {
            controllerView.updateFramesCallback = {
                if let button = controllerView.button(for: .settings) {
                    let interaction = UIContextMenuInteraction(delegate: self)
                    button.addInteraction(interaction)
                }
            }
        }
        
        Cytrus.shared.diskCacheCallback { stage, progress, maximum in
            enum LoadCallbackStage : UInt8, CustomStringConvertible {
                case prepare, preload, decompile, build, complete
                
                var description: String {
                    switch self {
                    case .prepare:
                        "Prepare"
                    case .preload:
                        "Preload"
                    case .decompile:
                        "Decompile"
                    case .build:
                        "Build"
                    case .complete:
                        "Complete"
                    }
                }
            }
            
            print(LoadCallbackStage(rawValue: stage)?.description ?? "No stage available", progress, maximum)
        }
        
        topMetalCallbackView = .init(frame: .zero, device: MTLCreateSystemDefaultDevice())
        guard let topMetalCallbackView else { return }
        topMetalCallbackView.translatesAutoresizingMaskIntoConstraints = false
        topMetalCallbackView.enableSetNeedsDisplay = false
        topMetalCallbackView.preferredFramesPerSecond = 120
        topMetalCallbackView.callback = {
            
        }
        if let controllerView {
            view.insertSubview(topMetalCallbackView, belowSubview: controllerView)
        }
        
        topMetalCallbackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        topMetalCallbackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        topMetalCallbackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        topMetalCallbackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        if let controllerView = controllerView, let button = controllerView.button(for: .settings) {
            let interaction = UIContextMenuInteraction(delegate: self)
            button.addInteraction(interaction)
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name.GCControllerDidConnect, object: nil, queue: .main) { notification in
            guard let controller = notification.object as? GCController, let extendedGamepad = controller.extendedGamepad else {
                return
            }
            
            if let controllerView = self.controllerView { controllerView.hide() }
            
            extendedGamepad.buttonA.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .b, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .b, playerIndex: .index1)
                }
            }
            
            extendedGamepad.buttonB.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .a, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .a, playerIndex: .index1)
                }
            }
            
            extendedGamepad.buttonX.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .y, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .y, playerIndex: .index1)
                }
            }
            
            extendedGamepad.buttonY.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .x, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .x, playerIndex: .index1)
                }
            }
            
            extendedGamepad.dpad.up.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .dpadUp, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .dpadUp, playerIndex: .index1)
                }
            }
            
            extendedGamepad.dpad.down.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .dpadDown, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .dpadDown, playerIndex: .index1)
                }
            }
            
            extendedGamepad.dpad.left.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .dpadLeft, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .dpadLeft, playerIndex: .index1)
                }
            }
            
            extendedGamepad.dpad.right.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .dpadRight, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .dpadRight, playerIndex: .index1)
                }
            }
            
            extendedGamepad.leftThumbstick.valueChangedHandler = { element, x, y in
                self.touchMoved(with: .left, position: (x, y), playerIndex: .index1)
            }
            
            extendedGamepad.rightThumbstick.valueChangedHandler = { element, x, y in
                self.touchMoved(with: .right, position: (x, y), playerIndex: .index1)
            }
            
            extendedGamepad.leftShoulder.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .l, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .l, playerIndex: .index1)
                }
            }
            
            extendedGamepad.rightShoulder.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .r, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .r, playerIndex: .index1)
                }
            }
            
            extendedGamepad.leftTrigger.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .zl, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .zl, playerIndex: .index1)
                }
            }
            
            extendedGamepad.rightTrigger.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .zr, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .zr, playerIndex: .index1)
                }
            }
            
            extendedGamepad.buttonOptions?.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .minus, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .minus, playerIndex: .index1)
                }
            }
            
            extendedGamepad.buttonMenu.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .plus, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .plus, playerIndex: .index1)
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name.GCControllerDidDisconnect, object: nil, queue: .main) { _ in
            if let controllerView = self.controllerView { controllerView.show() }
        }
        
        NotificationCenter.default.addObserver(forName: .init("applicationStateDidChange"), object: nil, queue: .main) { notification in
            guard let applicationState = notification.object as? ApplicationState else {
                return
            }
            
            self.cytrus.pausePlay(applicationState == .foregrounded)
        }
        
        NotificationCenter.default.addObserver(forName: .init("openKeyboard"), object: nil, queue: .main) { notification in
            guard let config = notification.object as? ButtonConfig else {
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cytrus.deallocate()
        cytrus.deinitialize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        if let cytrusGame = game as? CytrusGame {
            cytrusGame.update() // update cheats, saves, etc?
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in } completion: { _ in
            guard let topMetalCallbackView = self.topMetalCallbackView else { return }
            self.cytrus.orientationChange(with: self.interfaceOrientation(), using: topMetalCallbackView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isRunning {
            isRunning = true
            
            Task {
                guard let topMetalCallbackView, let layer = topMetalCallbackView.layer as? CAMetalLayer else { return }
                cytrus.initialize(layer, layer.frame.size)
            }
            
            // let displayLink: CADisplayLink = .init(target: self, selector: #selector(run))
            // displayLink.preferredFrameRateRange = .init(minimum: 60, maximum: 120)
            // displayLink.add(to: .main, forMode: .common)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                Thread.setThreadPriority(1.0)
                Thread.detachNewThread { [ weak self] in
                    guard let self else { return }
                    self.cytrus.insert(self.game.fileDetails.url)
                }
            }
        }
    }
    
    @objc func run() {
        DispatchQueue(label: "com.antique.Folium-iOS.renderQueue", qos: .userInteractive).async { [weak self] in
            guard let self else { return }
            self.cytrus.insert(self.game.fileDetails.url)
        }
    }
    
    static func touchBegan(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
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
        
        print(buttonType.rawValue)
        
        Cytrus.shared.input(playerIndex.rawValue, buttonType, true)
    }
    
    static func touchEnded(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
        guard let buttonType = CytrusButtonType.type(type.rawValue) else { return }
        Cytrus.shared.input(playerIndex.rawValue, buttonType, false)
    }
    
    static func touchMoved(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {}
    
    static func touchBegan(with type: Thumbstick.`Type`, position: (x: Float, y: Float), playerIndex: GCControllerPlayerIndex) {
        Cytrus.shared.thumbstickMoved(type == .left ? .circlePad : .cStick, position.x, position.y)
    }
    
    static func touchMoved(with type: Thumbstick.`Type`, position: (x: Float, y: Float), playerIndex: GCControllerPlayerIndex) {
        Cytrus.shared.thumbstickMoved(type == .left ? .circlePad : .cStick, position.x, position.y)
    }
    
    static func touchEnded(with type: Thumbstick.`Type`, position: (x: Float, y: Float), playerIndex: GCControllerPlayerIndex) {
        Cytrus.shared.thumbstickMoved(type == .left ? .circlePad : .cStick, position.x, position.y)
    }
}

extension CytrusDefaultController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first, let view = touch.view else {
            return
        }
        
        cytrus.touchBegan(at: touch.location(in: view))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        cytrus.touchEnded()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first, let view = touch.view else {
            return
        }
        
        cytrus.touchMoved(at: touch.location(in: view))
    }
}

extension CytrusDefaultController : UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        .init(actionProvider: { _ in
                .init(children: [
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
                        self.cytrus.pausePlay(self.cytrus.isPaused())
                    }),
                    UIAction(title: "Stop & Exit", attributes: [.destructive], handler: { _ in
                        let alertController = UIAlertController(title: "Stop & Exit", message: "Are you sure?", preferredStyle: .alert)
                        alertController.addAction(.init(title: "Dismiss", style: .cancel))
                        alertController.addAction(.init(title: "Stop & Exit", style: .destructive, handler: { _ in
                            self.cytrus.stop()
                            self.dismiss(animated: true)
                        }))
                        self.present(alertController, animated: true)
                    })
                ])
        })
    }
}
