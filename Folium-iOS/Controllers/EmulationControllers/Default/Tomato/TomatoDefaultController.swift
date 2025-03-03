//
//  TomatoDefaultController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 29/12/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation
import Tomato
import UIKit
import GameController
import AVFAudio

class TomatoDefaultController : SkinController {
    var imageView: UIImageView? = nil, blurredImageView: UIImageView? = nil
    var framerateLabel: UILabel? = nil
    
    var portraitConstraints: [NSLayoutConstraint] = []
    var landscapeConstraints: [NSLayoutConstraint] = []
    
    override init(game: GameBase, skin: Skin) {
        super.init(game: game, skin: skin)
        Tomato.shared.insert(cartridge: game.fileDetails.url)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        framerateLabel = .init()
        guard let framerateLabel else { return }
        framerateLabel.translatesAutoresizingMaskIntoConstraints = false
        framerateLabel.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize)
        framerateLabel.layer.shadowColor = UIColor.black.cgColor
        framerateLabel.layer.shadowRadius = 3
        framerateLabel.layer.shadowOffset = .zero
        framerateLabel.layer.shadowOpacity = 1
        framerateLabel.textColor = .white
        imageView.addSubview(framerateLabel)
        
        framerateLabel.sizeToFit()
        
        portraitConstraints.append(contentsOf: [
            blurredImageView.topAnchor.constraint(equalTo: view.topAnchor),
            blurredImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurredImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            imageView.topAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 3 / 4),
            
            blurredImageView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            
            framerateLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10),
            framerateLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 10)
        ])
        
        landscapeConstraints.append(contentsOf: [
            blurredImageView.topAnchor.constraint(equalTo: view.topAnchor),
            blurredImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            blurredImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 4 / 3),
            
            blurredImageView.widthAnchor.constraint(equalTo: imageView.widthAnchor, constant: 20),
            
            framerateLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10),
            framerateLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 10)
        ])
        
        switch interfaceOrientation() {
        case .portrait, .portraitUpsideDown:
            view.addConstraints(portraitConstraints)
        default:
            view.addConstraints(landscapeConstraints)
        }
        
        Task {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
        }
        
        Tomato.shared.framebuffer { framebuffer in
            guard let imageView = self.imageView, let blurredImageView = self.blurredImageView else { return }
            guard let topCGImage = CGImage.gba(framebuffer, 240, 160) else { return }
            
            imageView.image = .init(cgImage: topCGImage)
            blurredImageView.image = .init(cgImage: topCGImage)
        }
        
        Tomato.shared.framerate { framerate in
            framerateLabel.text = .init(format: "%.2f fps", framerate)
        }
        
        Thread.detachNewThread { Tomato.shared.start() }
        
        Task {
            await GCController.startWirelessControllerDiscovery()
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
            guard let applicationState = notification.object as? ApplicationState else {
                return
            }
            
            Tomato.shared.pause(applicationState == .backgrounded)
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
    
    static func touchBegan(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
        switch type {
        case .a:
            Tomato.shared.button(button: .a, player: playerIndex.rawValue, pressed: true)
        case .b:
            Tomato.shared.button(button: .b, player: playerIndex.rawValue, pressed: true)
        case .dpadUp:
            Tomato.shared.button(button: .up, player: playerIndex.rawValue, pressed: true)
        case .dpadDown:
            Tomato.shared.button(button: .down, player: playerIndex.rawValue, pressed: true)
        case .dpadLeft:
            Tomato.shared.button(button: .left, player: playerIndex.rawValue, pressed: true)
        case .dpadRight:
            Tomato.shared.button(button: .right, player: playerIndex.rawValue, pressed: true)
        case .minus:
            Tomato.shared.button(button: .select, player: playerIndex.rawValue, pressed: true)
        case .plus:
            Tomato.shared.button(button: .start, player: playerIndex.rawValue, pressed: true)
        case .l:
            Tomato.shared.button(button: .l, player: playerIndex.rawValue, pressed: true)
        case .r:
            Tomato.shared.button(button: .r, player: playerIndex.rawValue, pressed: true)
        case .loadState: Tomato.shared.load()
        case .saveState: Tomato.shared.save()
        case .settings:
            if let viewController = UIApplication.shared.viewController as? TomatoDefaultController {
                if let controllerView = viewController.controllerView, let button = controllerView.button(for: type) {
                    let interaction = UIContextMenuInteraction(delegate: viewController)
                    button.addInteraction(interaction)
                }
            }
        default:
            break
        }
    }
    
    static func touchEnded(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
        switch type {
        case .a:
            Tomato.shared.button(button: .a, player: playerIndex.rawValue, pressed: false)
        case .b:
            Tomato.shared.button(button: .b, player: playerIndex.rawValue, pressed: false)
        case .dpadUp:
            Tomato.shared.button(button: .up, player: playerIndex.rawValue, pressed: false)
        case .dpadDown:
            Tomato.shared.button(button: .down, player: playerIndex.rawValue, pressed: false)
        case .dpadLeft:
            Tomato.shared.button(button: .left, player: playerIndex.rawValue, pressed: false)
        case .dpadRight:
            Tomato.shared.button(button: .right, player: playerIndex.rawValue, pressed: false)
        case .minus:
            Tomato.shared.button(button: .select, player: playerIndex.rawValue, pressed: false)
        case .plus:
            Tomato.shared.button(button: .start, player: playerIndex.rawValue, pressed: false)
        case .l:
            Tomato.shared.button(button: .l, player: playerIndex.rawValue, pressed: false)
        case .r:
            Tomato.shared.button(button: .r, player: playerIndex.rawValue, pressed: false)
        default:
            break
        }
    }
    
    static func touchMoved(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {}
}

extension TomatoDefaultController : UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        .init(actionProvider: { _ in
                .init(children: [
                    UIAction(title: "Stop & Exit", attributes: [.destructive], handler: { _ in
                        let alertController = UIAlertController(title: "Stop & Exit", message: "Are you sure?", preferredStyle: .alert)
                        alertController.addAction(.init(title: "Dismiss", style: .cancel))
                        alertController.addAction(.init(title: "Stop & Exit", style: .destructive, handler: { _ in
                            Tomato.shared.save()
                            Tomato.shared.stop()
                            
                            self.dismiss(animated: true)
                        }))
                        self.present(alertController, animated: true)
                    })
                ])
        })
    }
}
