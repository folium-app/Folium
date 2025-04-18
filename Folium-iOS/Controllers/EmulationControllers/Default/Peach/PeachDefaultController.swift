//
//  PeachDefaultController.swift
//  Folium
//
//  Created by Jarrod Norwell on 23/2/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Foundation
import GameController
import Peach
import UIKit

class PeachDefaultController : SkinController {
    var imageView: UIImageView? = nil, blurredImageView: UIImageView? = nil
    
    var portraitConstraints: [NSLayoutConstraint] = []
    var landscapeConstraints: [NSLayoutConstraint] = []
    
    var displayLink: CADisplayLink!
    
    var peach: Peach = .shared
    
    override init(game: GameBase, skin: Skin) {
        super.init(game: game, skin: skin)
        peach.insert(cartridge: game.fileDetails.url)
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
        
        blurredImageView = .init()
        guard let blurredImageView else { return }
        blurredImageView.translatesAutoresizingMaskIntoConstraints = false
        if let controllerView {
            view.insertSubview(blurredImageView, belowSubview: controllerView)
        }
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        if let controllerView {
            view.insertSubview(visualEffectView, belowSubview: controllerView)
        }
        
        imageView = .init()
        guard let imageView else { return }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerCurve = .continuous
        imageView.layer.cornerRadius = 10
        visualEffectView.contentView.addSubview(imageView)
        
        portraitConstraints.append(contentsOf: [
            blurredImageView.topAnchor.constraint(equalTo: view.topAnchor),
            blurredImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurredImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            imageView.topAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 3 / 4),
            
            blurredImageView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20)
        ])
        
        landscapeConstraints.append(contentsOf: [
            blurredImageView.topAnchor.constraint(equalTo: view.topAnchor),
            blurredImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            blurredImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 4 / 3),
            
            blurredImageView.widthAnchor.constraint(equalTo: imageView.widthAnchor, constant: 20)
        ])
        
        switch interfaceOrientation() {
        case .portrait, .portraitUpsideDown:
            view.addConstraints(portraitConstraints)
        default:
            view.addConstraints(landscapeConstraints)
        }
        
        displayLink = CADisplayLink(target: self, selector: #selector(step))
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
                    self.touchBegan(with: .a, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .a, playerIndex: .index1)
                }
            }
            
            extendedGamepad.buttonB.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .b, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .b, playerIndex: .index1)
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
            default:
                self.view.removeConstraints(self.portraitConstraints)
                self.view.addConstraints(self.landscapeConstraints)
            }
            
            self.view.setNeedsUpdateConstraints()
        }
    }
    
    @objc func step() {
        guard let imageView, let blurredImageView else { return }
        
        peach.step()
        
        guard let cgImage = CGImage.nes(peach.framebuffer(), .init(peach.width()), .init(peach.height())) else {
            return
        }
    
        Task {
            imageView.image = .init(cgImage: cgImage)
            blurredImageView.image = .init(cgImage: cgImage)
        }
    }
    
    static func touchBegan(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
        switch type {
        case .a:
            Peach.shared.button(button: .a, player: playerIndex.rawValue, pressed: true)
        case .b:
            Peach.shared.button(button: .b, player: playerIndex.rawValue, pressed: true)
        case .dpadUp:
            Peach.shared.button(button: .up, player: playerIndex.rawValue, pressed: true)
        case .dpadDown:
            Peach.shared.button(button: .down, player: playerIndex.rawValue, pressed: true)
        case .dpadLeft:
            Peach.shared.button(button: .left, player: playerIndex.rawValue, pressed: true)
        case .dpadRight:
            Peach.shared.button(button: .right, player: playerIndex.rawValue, pressed: true)
        case .minus:
            Peach.shared.button(button: .select, player: playerIndex.rawValue, pressed: true)
        case .plus:
            Peach.shared.button(button: .start, player: playerIndex.rawValue, pressed: true)
        default:
            break
        }
    }
    
    static func touchEnded(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
        switch type {
        case .a:
            Peach.shared.button(button: .a, player: playerIndex.rawValue, pressed: false)
        case .b:
            Peach.shared.button(button: .b, player: playerIndex.rawValue, pressed: false)
        case .dpadUp:
            Peach.shared.button(button: .up, player: playerIndex.rawValue, pressed: false)
        case .dpadDown:
            Peach.shared.button(button: .down, player: playerIndex.rawValue, pressed: false)
        case .dpadLeft:
            Peach.shared.button(button: .left, player: playerIndex.rawValue, pressed: false)
        case .dpadRight:
            Peach.shared.button(button: .right, player: playerIndex.rawValue, pressed: false)
        case .minus:
            Peach.shared.button(button: .select, player: playerIndex.rawValue, pressed: false)
        case .plus:
            Peach.shared.button(button: .start, player: playerIndex.rawValue, pressed: false)
        default:
            break
        }
    }
    
    static func touchMoved(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {}
}

extension PeachDefaultController : UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        .init(actionProvider: { _ in
            .init(children: [
                UIAction(title: "Stop & Exit", attributes: [.destructive], handler: { _ in
                    let alertController = UIAlertController(title: "Stop & Exit", message: "Are you sure?", preferredStyle: .alert)
                    alertController.addAction(.init(title: "Dismiss", style: .cancel))
                    alertController.addAction(.init(title: "Stop & Exit", style: .destructive, handler: { _ in
                        self.displayLink.remove(from: .main, forMode: .common)
                        
                        self.dismiss(animated: true)
                    }))
                    self.present(alertController, animated: true)
                })
            ])
        })
    }
}
