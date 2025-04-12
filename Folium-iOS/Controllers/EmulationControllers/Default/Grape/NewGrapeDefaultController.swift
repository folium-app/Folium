//
//  GrapeDefaultController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 29/12/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation
import NewGrape
import UIKit
import GameController

class NewGrapeDefaultController : SkinController {
    var topImageView: UIImageView? = nil, topBlurredImageView: UIImageView? = nil
    var bottomImageView: UIImageView? = nil, bottomBlurredImageView: UIImageView? = nil
    
    var portraitConstraints: [NSLayoutConstraint] = []
    var landscapeConstraints: [NSLayoutConstraint] = []
    
    var displayLink: CADisplayLink? = nil
    
    override init(game: GameBase, skin: Skin) {
        var skin = skin
        // skin.orientations.portrait.buttons.removeAll(where: { [.loadState, .saveState].contains($0.type) })
        // skin.orientations.landscapeLeft?.buttons.removeAll(where: { [.loadState, .saveState].contains($0.type) })
        // skin.orientations.landscapeRight?.buttons.removeAll(where: { [.loadState, .saveState].contains($0.type) })
        // skin.orientations.portraitUpsideDown?.buttons.removeAll(where: { [.loadState, .saveState].contains($0.type) })
        super.init(game: game, skin: skin)
        
        NewGrape.shared.insert(from: game.fileDetails.url)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topBlurredImageView = .init()
        guard let topBlurredImageView else { return }
        topBlurredImageView.translatesAutoresizingMaskIntoConstraints = false
        if let controllerView {
            view.insertSubview(topBlurredImageView, belowSubview: controllerView)
        }
        
        bottomBlurredImageView = .init()
        guard let bottomBlurredImageView else { return }
        bottomBlurredImageView.translatesAutoresizingMaskIntoConstraints = false
        if let controllerView {
            view.insertSubview(bottomBlurredImageView, belowSubview: controllerView)
        }
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        if let controllerView {
            view.insertSubview(visualEffectView, belowSubview: controllerView)
        }
        
        topImageView = .init()
        guard let topImageView else { return }
        topImageView.translatesAutoresizingMaskIntoConstraints = false
        topImageView.clipsToBounds = true
        topImageView.layer.cornerCurve = .continuous
        topImageView.layer.cornerRadius = 10
        topImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        if let controllerView {
            view.insertSubview(topImageView, belowSubview: controllerView)
        }
        
        bottomImageView = .init()
        guard let bottomImageView else { return }
        bottomImageView.translatesAutoresizingMaskIntoConstraints = false
        bottomImageView.clipsToBounds = true
        bottomImageView.isUserInteractionEnabled = true
        bottomImageView.layer.cornerCurve = .continuous
        bottomImageView.layer.cornerRadius = 10
        bottomImageView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        if let controllerView {
            view.insertSubview(bottomImageView, belowSubview: controllerView)
        }
        
        portraitConstraints.append(contentsOf: UIDevice.current.userInterfaceIdiom == .pad ? [
            topBlurredImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            topBlurredImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topBlurredImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3 / 4),
            
            bottomBlurredImageView.topAnchor.constraint(equalTo: topBlurredImageView.bottomAnchor),
            bottomBlurredImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomBlurredImageView.widthAnchor.constraint(equalTo: topBlurredImageView.widthAnchor),
            
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            topImageView.topAnchor.constraint(equalTo: topBlurredImageView.topAnchor, constant: 20),
            topImageView.leadingAnchor.constraint(equalTo: topBlurredImageView.leadingAnchor, constant: 20),
            topImageView.trailingAnchor.constraint(equalTo: topBlurredImageView.trailingAnchor, constant: -20),
            topImageView.heightAnchor.constraint(equalTo: topImageView.widthAnchor, multiplier: 3 / 4),
            
            bottomImageView.topAnchor.constraint(equalTo: bottomBlurredImageView.topAnchor),
            bottomImageView.leadingAnchor.constraint(equalTo: bottomBlurredImageView.leadingAnchor, constant: 20),
            bottomImageView.trailingAnchor.constraint(equalTo: bottomBlurredImageView.trailingAnchor, constant: -20),
            bottomImageView.heightAnchor.constraint(equalTo: bottomImageView.widthAnchor, multiplier: 3 / 4),
            
            topBlurredImageView.bottomAnchor.constraint(equalTo: topImageView.bottomAnchor),
            bottomBlurredImageView.bottomAnchor.constraint(equalTo: bottomImageView.bottomAnchor, constant: 20)
        ] : [
            topBlurredImageView.topAnchor.constraint(equalTo: view.topAnchor),
            topBlurredImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBlurredImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            bottomBlurredImageView.topAnchor.constraint(equalTo: topBlurredImageView.bottomAnchor),
            bottomBlurredImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBlurredImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            topImageView.topAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            topImageView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            topImageView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            topImageView.heightAnchor.constraint(equalTo: topImageView.widthAnchor, multiplier: 3 / 4),
            
            bottomImageView.topAnchor.constraint(equalTo: topImageView.bottomAnchor),
            bottomImageView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            bottomImageView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            bottomImageView.heightAnchor.constraint(equalTo: bottomImageView.widthAnchor, multiplier: 3 / 4),
            
            topBlurredImageView.bottomAnchor.constraint(equalTo: topImageView.bottomAnchor),
            bottomBlurredImageView.bottomAnchor.constraint(equalTo: bottomImageView.bottomAnchor, constant: 20)
        ])
        
        landscapeConstraints.append(contentsOf: [
            topBlurredImageView.topAnchor.constraint(equalTo: view.topAnchor),
            topBlurredImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBlurredImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            bottomBlurredImageView.topAnchor.constraint(equalTo: view.topAnchor),
            bottomBlurredImageView.leadingAnchor.constraint(equalTo: topBlurredImageView.trailingAnchor),
            bottomBlurredImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            topImageView.topAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            topImageView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            topImageView.bottomAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            topImageView.widthAnchor.constraint(equalTo: topImageView.heightAnchor, multiplier: 4 / 3),
            
            bottomImageView.topAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            bottomImageView.leadingAnchor.constraint(equalTo: topImageView.trailingAnchor),
            bottomImageView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            bottomImageView.heightAnchor.constraint(equalTo: bottomImageView.widthAnchor, multiplier: 3 / 4),
            
            topBlurredImageView.trailingAnchor.constraint(equalTo: topImageView.trailingAnchor, constant: 20),
            bottomBlurredImageView.bottomAnchor.constraint(equalTo: bottomImageView.bottomAnchor, constant: 20)
        ])
        
        switch interfaceOrientation() {
        case .portrait, .portraitUpsideDown:
            view.addConstraints(portraitConstraints)
        default:
            view.addConstraints(landscapeConstraints)
        }
        
        NewGrape.shared.ab { buffer, samples in }
        
        NewGrape.shared.fbs { top, bottom in
            guard let cgImage = CGImage.ds_dsi(top, 256, 192) else { return }
            
            Task {
                topImageView.image = .init(cgImage: cgImage)
                topBlurredImageView.image = .init(cgImage: cgImage)
            }
            
            guard let cgImage = CGImage.ds_dsi(bottom, 256, 192) else { return }
            
            Task {
                bottomImageView.image = .init(cgImage: cgImage)
                bottomBlurredImageView.image = .init(cgImage: cgImage)
            }
        }
        
        displayLink = .init(target: self, selector: #selector(step))
        guard let displayLink else { return }
        displayLink.preferredFrameRateRange = .init(minimum: 30, maximum: 60)
        displayLink.add(to: .main, forMode: .common)
        
        Task {
            await GCController.startWirelessControllerDiscovery()
        }
        
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
            guard let _ = notification.object as? ApplicationState else {
                return
            }
            
            // Task { Grape.shared.pause() }
            // SDL_PauseAudioDevice(self.audioDeviceID, Grape.shared.running() ? 1 : 0)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { context in } completion: { context in
            switch self.interfaceOrientation() {
            case .portrait, .portraitUpsideDown:
                self.view.removeConstraints(self.landscapeConstraints)
                self.view.addConstraints(self.portraitConstraints)
                
                guard let topImageView = self.topImageView, let bottomImageView = self.bottomImageView else { return }
                topImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                bottomImageView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                
                topImageView.layoutIfNeeded()
                bottomImageView.layoutIfNeeded()
            default:
                self.view.removeConstraints(self.portraitConstraints)
                self.view.addConstraints(self.landscapeConstraints)
                
                guard let topImageView = self.topImageView, let bottomImageView = self.bottomImageView else { return }
                topImageView.layer.maskedCorners = [
                    .layerMinXMinYCorner,
                    .layerMinXMaxYCorner,
                    .layerMaxXMaxYCorner
                ]
                bottomImageView.layer.maskedCorners = [
                    .layerMaxXMinYCorner,
                    .layerMaxXMaxYCorner
                ]
                
                topImageView.layoutIfNeeded()
                bottomImageView.layoutIfNeeded()
            }
            
            self.view.setNeedsUpdateConstraints()
        }
    }
    
    @objc func step() {
        NewGrape.shared.step()
    }
    
    static func touchBegan(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
        switch type {
        case .dpadUp:
            NewGrape.shared.button(button: .up, pressed: true)
        case .dpadDown:
            NewGrape.shared.button(button: .down, pressed: true)
        case .dpadLeft:
            NewGrape.shared.button(button: .left, pressed: true)
        case .dpadRight:
            NewGrape.shared.button(button: .right, pressed: true)
        case .minus:
            NewGrape.shared.button(button: .select, pressed: true)
        case .plus:
            NewGrape.shared.button(button: .start, pressed: true)
        case .a:
            NewGrape.shared.button(button: .a, pressed: true)
        case .b:
            NewGrape.shared.button(button: .b, pressed: true)
        case .x:
            NewGrape.shared.button(button: .x, pressed: true)
        case .y:
            NewGrape.shared.button(button: .y, pressed: true)
        case .l:
            NewGrape.shared.button(button: .l, pressed: true)
        case .r:
            NewGrape.shared.button(button: .r, pressed: true)
        case .loadState:
            NewGrape.shared.loadState { result in
                UINotificationFeedbackGenerator().notificationOccurred(result ? .success : .error)
            }
        case .saveState:
            NewGrape.shared.saveState { result in
                UINotificationFeedbackGenerator().notificationOccurred(result ? .success : .error)
            }
        default:
            break
        }
    }
    
    static func touchEnded(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
        switch type {
        case .dpadUp:
            NewGrape.shared.button(button: .up, pressed: false)
        case .dpadDown:
            NewGrape.shared.button(button: .down, pressed: false)
        case .dpadLeft:
            NewGrape.shared.button(button: .left, pressed: false)
        case .dpadRight:
            NewGrape.shared.button(button: .right, pressed: false)
        case .minus:
            NewGrape.shared.button(button: .select, pressed: false)
        case .plus:
            NewGrape.shared.button(button: .start, pressed: false)
        case .a:
            NewGrape.shared.button(button: .a, pressed: false)
        case .b:
            NewGrape.shared.button(button: .b, pressed: false)
        case .x:
            NewGrape.shared.button(button: .x, pressed: false)
        case .y:
            NewGrape.shared.button(button: .y, pressed: false)
        case .l:
            NewGrape.shared.button(button: .l, pressed: false)
        case .r:
            NewGrape.shared.button(button: .r, pressed: false)
        default:
            break
        }
    }
    
    static func touchMoved(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {}
}

extension NewGrapeDefaultController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let bottomImageView, let touch = touches.first else {
            return
        }
        
        let locationInView = touch.location(in: bottomImageView)
        let viewSize = bottomImageView.frame.size
        
        let mappedX = (locationInView.x / viewSize.width) * 256
        let mappedY = (locationInView.y / viewSize.height) * 192

        let finalPoint = CGPoint(x: mappedX, y: mappedY)
        
        NewGrape.shared.touchBegan(at: finalPoint)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        NewGrape.shared.touchEnded()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let bottomImageView, let touch = touches.first else {
            return
        }
        
        let locationInView = touch.location(in: bottomImageView)
        let viewSize = bottomImageView.frame.size
        
        let mappedX = (locationInView.x / viewSize.width) * 256
        let mappedY = (locationInView.y / viewSize.height) * 192

        let finalPoint = CGPoint(x: mappedX, y: mappedY)
        
        NewGrape.shared.touchMoved(at: finalPoint)
    }
}

extension NewGrapeDefaultController : UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        .init(actionProvider: { _ in
                .init(children: [
                    UIAction(title: "Stop & Exit", attributes: [.destructive], handler: { _ in
                        let alertController = UIAlertController(title: "Stop & Exit", message: "Are you sure?", preferredStyle: .alert)
                        alertController.addAction(.init(title: "Dismiss", style: .cancel))
                        alertController.addAction(.init(title: "Stop & Exit", style: .destructive, handler: { _ in
                            guard let displayLink = self.displayLink else { return }
                            displayLink.remove(from: .main, forMode: .common)
                            self.displayLink = nil
                            
                            NewGrape.shared.stop()
                            
                            self.dismiss(animated: true)
                        }))
                        self.present(alertController, animated: true)
                    })
                ])
        })
    }
}
