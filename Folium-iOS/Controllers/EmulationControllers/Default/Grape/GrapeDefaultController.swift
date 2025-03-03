//
//  GrapeDefaultController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 29/12/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation
import Grape
import SDL
import UIKit
import GameController

typealias GrapeAudioCallback = @convention(c)(UnsafeMutableRawPointer?, UnsafeMutablePointer<UInt8>?, Int32) -> Void
class GrapeDefaultController : SkinController {
    var audioDeviceID: SDL_AudioDeviceID!
    
    var topImageView: UIImageView? = nil, topBlurredImageView: UIImageView? = nil
    var bottomImageView: UIImageView? = nil, bottomBlurredImageView: UIImageView? = nil
    
    var portraitConstraints: [NSLayoutConstraint] = []
    var landscapeConstraints: [NSLayoutConstraint] = []
    
    override init(game: GameBase, skin: Skin) {
        super.init(game: game, skin: skin)
        _ = Grape.shared.insertCartridge(from: game.fileDetails.url)
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
        
        configureAudio()
        
        Grape.shared.framebuffer { [weak self] framebuffer in
            guard let self else { return }
            
            let size = Grape.shared.videoBufferSize()
            
            guard let topCGImage = CGImage.cgImage(framebuffer, .init(size.width), .init(size.height)) else { return }
            
            Task {
                topImageView.image = .init(cgImage: topCGImage)
                topBlurredImageView.image = .init(cgImage: topCGImage)
            }
            
            guard let bottomCGImage = CGImage.cgImage(framebuffer.advanced(by: .init(size.width * size.height)),
                                                      .init(size.width), .init(size.height)) else { return }
            
            Task {
                bottomImageView.image = .init(cgImage: bottomCGImage)
                bottomBlurredImageView.image = .init(cgImage: bottomCGImage)
            }
        }
        
        Grape.shared.start()
        
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
            
            Task { Grape.shared.pause() }
            SDL_PauseAudioDevice(self.audioDeviceID, Grape.shared.running() ? 1 : 0)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let bottomImageView else { return }
        Grape.shared.updateScreenLayout(with: bottomImageView.bounds.size)
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
    
    func configureAudio() {
        SDL_SetMainReady()
        SDL_InitSubSystem(SDL_INIT_AUDIO)
        
        let callback: GrapeAudioCallback = { userdata, stream, len in
            SDL_memcpy(stream, Grape.shared.audioBuffer(), Int(len))
        }
        
        var spec = SDL_AudioSpec()
        spec.callback = callback
        spec.userdata = nil
        spec.channels = 2
        spec.format = SDL_AudioFormat(AUDIO_S16)
        spec.freq = 48000
        spec.samples = 1024
        
        audioDeviceID = SDL_OpenAudioDevice(nil, 0, &spec, nil, 0)
        SDL_PauseAudioDevice(audioDeviceID, 0)
    }
    
    static func touchBegan(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
        switch type {
        case .dpadUp:
            Grape.shared.input(6, true)
        case .dpadDown:
            Grape.shared.input(7, true)
        case .dpadLeft:
            Grape.shared.input(5, true)
        case .dpadRight:
            Grape.shared.input(4, true)
        case .minus:
            Grape.shared.input(2, true)
        case .plus:
            Grape.shared.input(3, true)
        case .a:
            Grape.shared.input(0, true)
        case .b:
            Grape.shared.input(1, true)
        case .x:
            Grape.shared.input(10, true)
        case .y:
            Grape.shared.input(11, true)
        case .l:
            Grape.shared.input(9, true)
        case .r:
            Grape.shared.input(8, true)
        case .loadState: Grape.shared.loadState()
        case .saveState: Grape.shared.saveState()
        case .settings:
            if let viewController = UIApplication.shared.viewController as? GrapeDefaultController {
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
        case .dpadUp:
            Grape.shared.input(6, false)
        case .dpadDown:
            Grape.shared.input(7, false)
        case .dpadLeft:
            Grape.shared.input(5, false)
        case .dpadRight:
            Grape.shared.input(4, false)
        case .minus:
            Grape.shared.input(2, false)
        case .plus:
            Grape.shared.input(3, false)
        case .a:
            Grape.shared.input(0, false)
        case .b:
            Grape.shared.input(1, false)
        case .x:
            Grape.shared.input(10, false)
        case .y:
            Grape.shared.input(11, false)
        case .l:
            Grape.shared.input(9, false)
        case .r:
            Grape.shared.input(8, false)
        default:
            break
        }
    }
    
    static func touchMoved(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {}
}

extension GrapeDefaultController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let bottomImageView, let touch = touches.first else {
            return
        }
        
        Grape.shared.touchBegan(at: touch.location(in: bottomImageView))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        Grape.shared.touchEnded()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let bottomImageView, let touch = touches.first else {
            return
        }
        
        Grape.shared.touchMoved(at: touch.location(in: bottomImageView))
    }
}

extension GrapeDefaultController : UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        .init(actionProvider: { _ in
                .init(children: [
                    UIAction(title: "Stop & Exit", attributes: [.destructive], handler: { _ in
                        let alertController = UIAlertController(title: "Stop & Exit", message: "Are you sure?", preferredStyle: .alert)
                        alertController.addAction(.init(title: "Dismiss", style: .cancel))
                        alertController.addAction(.init(title: "Stop & Exit", style: .destructive, handler: { _ in
                            Grape.shared.pause()
                            
                            SDL_PauseAudioDevice(self.audioDeviceID, 1)
                            SDL_CloseAudioDevice(self.audioDeviceID)
                            
                            Grape.shared.stop()
                            
                            self.dismiss(animated: true)
                        }))
                        self.present(alertController, animated: true)
                    })
                ])
        })
    }
}
