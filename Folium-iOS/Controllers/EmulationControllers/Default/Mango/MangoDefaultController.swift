//
//  MangoDefaultController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 24/8/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation
import GameController
import Mango
import SDL
import UIKit

class MangoDefaultController : SkinController {
    var imageView: UIImageView? = nil, blurredImageView: UIImageView? = nil
    
    var portraitConstraints: [NSLayoutConstraint] = []
    var landscapeConstraints: [NSLayoutConstraint] = []
    
    var audioDeviceID: SDL_AudioDeviceID!
    var displayLink: CADisplayLink!
    
    let mango = Mango.shared
    
    override init(game: GameBase, skin: Skin) {
        super.init(game: game, skin: skin)
        mango.insertCartridge(from: game.fileDetails.url)
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
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 7 / 8),
            
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
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 8 / 7),
            
            blurredImageView.widthAnchor.constraint(equalTo: imageView.widthAnchor, constant: 20)
        ])
        
        switch interfaceOrientation() {
        case .portrait, .portraitUpsideDown:
            view.addConstraints(portraitConstraints)
        default:
            view.addConstraints(landscapeConstraints)
        }
        
        SDL_SetMainReady()
        SDL_InitSubSystem(SDL_INIT_AUDIO)
        
        var spec = SDL_AudioSpec()
        spec.callback = nil
        spec.userdata = nil
        spec.channels = 2
        spec.format = SDL_AudioFormat(AUDIO_S16)
        spec.freq = 48000
        spec.samples = 2048
        
        audioDeviceID = SDL_OpenAudioDevice(nil, 0, &spec, nil, 0)
        SDL_PauseAudioDevice(audioDeviceID, 0)
        
        displayLink = CADisplayLink(target: self, selector: #selector(step))
        displayLink.preferredFrameRateRange = .init(minimum: 30, maximum: mango.type() == .PAL ? 50 : 60)
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
            
            extendedGamepad.buttonX.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .x, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .x, playerIndex: .index1)
                }
            }
            
            extendedGamepad.buttonY.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .y, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .y, playerIndex: .index1)
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
    
    @MainActor
    @objc func step() {
        guard let imageView, let blurredImageView else { return }
        
        mango.step()
        
        let audioBuffer = mango.audioBuffer()
        let videoBuffer = mango.videoBuffer()
        guard let audioBuffer, let videoBuffer else { return }
        guard let cgImage = CGImage.cgImage(buffer8: videoBuffer, 512, 480) else { return }
        
        let wantedSamples = 48000 / (mango.type() == .PAL ? 50 : 60)
        if SDL_GetQueuedAudioSize(audioDeviceID) <= wantedSamples * 4 * 6 {
            SDL_QueueAudio(audioDeviceID, audioBuffer, UInt32(wantedSamples * 4))
        }
        
        Task {
            imageView.image = .init(cgImage: cgImage)
            blurredImageView.image = .init(cgImage: cgImage)
        }
    }
    
    static func touchBegan(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
        switch type {
        case .a:
            Mango.shared.button(button: SNESControllerButton.a.rawValue, player: playerIndex.rawValue, pressed: true)
        case .b:
            Mango.shared.button(button: SNESControllerButton.b.rawValue, player: playerIndex.rawValue, pressed: true)
        case .x:
            Mango.shared.button(button: SNESControllerButton.x.rawValue, player: playerIndex.rawValue, pressed: true)
        case .y:
            Mango.shared.button(button: SNESControllerButton.y.rawValue, player: playerIndex.rawValue, pressed: true)
        case .dpadUp:
            Mango.shared.button(button: SNESControllerButton.up.rawValue, player: playerIndex.rawValue, pressed: true)
        case .dpadDown:
            Mango.shared.button(button: SNESControllerButton.down.rawValue, player: playerIndex.rawValue, pressed: true)
        case .dpadLeft:
            Mango.shared.button(button: SNESControllerButton.left.rawValue, player: playerIndex.rawValue, pressed: true)
        case .dpadRight:
            Mango.shared.button(button: SNESControllerButton.right.rawValue, player: playerIndex.rawValue, pressed: true)
        case .minus:
            Mango.shared.button(button: SNESControllerButton.select.rawValue, player: playerIndex.rawValue, pressed: true)
        case .plus:
            Mango.shared.button(button: SNESControllerButton.start.rawValue, player: playerIndex.rawValue, pressed: true)
        case .l:
            Mango.shared.button(button: SNESControllerButton.l.rawValue, player: playerIndex.rawValue, pressed: true)
        case .r:
            Mango.shared.button(button: SNESControllerButton.r.rawValue, player: playerIndex.rawValue, pressed: true)
        default:
            break
        }
    }
    
    static func touchEnded(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
        switch type {
        case .a:
            Mango.shared.button(button: SNESControllerButton.a.rawValue, player: playerIndex.rawValue, pressed: false)
        case .b:
            Mango.shared.button(button: SNESControllerButton.b.rawValue, player: playerIndex.rawValue, pressed: false)
        case .x:
            Mango.shared.button(button: SNESControllerButton.x.rawValue, player: playerIndex.rawValue, pressed: false)
        case .y:
            Mango.shared.button(button: SNESControllerButton.y.rawValue, player: playerIndex.rawValue, pressed: false)
        case .dpadUp:
            Mango.shared.button(button: SNESControllerButton.up.rawValue, player: playerIndex.rawValue, pressed: false)
        case .dpadDown:
            Mango.shared.button(button: SNESControllerButton.down.rawValue, player: playerIndex.rawValue, pressed: false)
        case .dpadLeft:
            Mango.shared.button(button: SNESControllerButton.left.rawValue, player: playerIndex.rawValue, pressed: false)
        case .dpadRight:
            Mango.shared.button(button: SNESControllerButton.right.rawValue, player: playerIndex.rawValue, pressed: false)
        case .minus:
            Mango.shared.button(button: SNESControllerButton.select.rawValue, player: playerIndex.rawValue, pressed: false)
        case .plus:
            Mango.shared.button(button: SNESControllerButton.start.rawValue, player: playerIndex.rawValue, pressed: false)
        case .l:
            Mango.shared.button(button: SNESControllerButton.l.rawValue, player: playerIndex.rawValue, pressed: false)
        case .r:
            Mango.shared.button(button: SNESControllerButton.r.rawValue, player: playerIndex.rawValue, pressed: false)
        default:
            break
        }
    }
    
    static func touchMoved(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {}
}

extension MangoDefaultController : UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        .init(actionProvider: { _ in
            .init(children: [
                UIAction(title: "Stop & Exit", attributes: [.destructive], handler: { _ in
                    let alertController = UIAlertController(title: "Stop & Exit", message: "Are you sure?", preferredStyle: .alert)
                    alertController.addAction(.init(title: "Dismiss", style: .cancel))
                    alertController.addAction(.init(title: "Stop & Exit", style: .destructive, handler: { _ in
                        // TODO: exit
                        SDL_PauseAudioDevice(self.audioDeviceID, 0)
                        SDL_CloseAudioDevice(self.audioDeviceID)
                        
                        self.displayLink.remove(from: .main, forMode: .common)
                        
                        self.dismiss(animated: true)
                    }))
                    self.present(alertController, animated: true)
                })
            ])
        })
    }
}
