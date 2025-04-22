//
//  GrapeDefaultController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 29/12/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation
import GameController
import HQx
import NewGrape
import SDL
import UIKit

class NewGrapeDefaultController : SkinController {
    var audioDeviceID: SDL_AudioDeviceID!
    
    var topImageView: UIImageView? = nil, topBlurredImageView: UIImageView? = nil
    var bottomImageView: UIImageView? = nil, bottomBlurredImageView: UIImageView? = nil
    
    var portraitConstraints: [NSLayoutConstraint] = []
    var landscapeConstraints: [NSLayoutConstraint] = []
    
    var displayLink: CADisplayLink? = nil
    
    override init(game: GameBase, skin: Skin) {
        super.init(game: game, skin: skin)
        NewGrape.shared.insert(from: game.fileDetails.url)
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
        
        if let controllerView = controllerView, let button = controllerView.button(for: .settings) {
            let interaction = UIContextMenuInteraction(delegate: self)
            button.addInteraction(interaction)
        }
        
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
        
        NewGrape.shared.ab { buffer, samples in
            SDL_QueueAudio(self.audioDeviceID, buffer, .init(samples * 4))
        }
        
        hqxInit()
        
        let scale: Int = .init(UserDefaults.standard.double(forKey: "grape.resolutionFactor"))
        var width: Int = 256, height: Int = 192
        if scale > 1 {
            width *= scale
            height *= scale
        }
        
        let topScaled: UnsafeMutablePointer<UInt32> = .allocate(capacity: width * height)
        let bottomScaled: UnsafeMutablePointer<UInt32> = .allocate(capacity: width * height)
        
        NewGrape.shared.fbs { top, bottom in
            let hqx = switch scale {
            case 2: hq2x_32
            case 3: hq3x_32
            case 4: hq4x_32
            default: hq2x_32
            }
            
            if scale > 1 {
                hqx(top, topScaled, 256, 192)
                hqx(bottom, bottomScaled, 256, 192)
            }
            
            let topBuffer = if scale > 1 { topScaled } else { top }
            let bottomBuffer = if scale > 1 { bottomScaled } else { bottom }
            
            guard let cgImage = CGImage.ds_dsi(topBuffer, width, height) else { return }
            
            Task {
                topImageView.image = .init(cgImage: cgImage)
                topBlurredImageView.image = .init(cgImage: cgImage)
            }
            
            guard let cgImage = CGImage.ds_dsi(bottomBuffer, width, height) else { return }
            
            Task {
                bottomImageView.image = .init(cgImage: cgImage)
                bottomBlurredImageView.image = .init(cgImage: cgImage)
            }
        }
        
        displayLink = .init(target: self, selector: #selector(step))
        guard let displayLink else { return }
        displayLink.preferredFrameRateRange = .init(minimum: 30, maximum: 60)
        displayLink.add(to: .main, forMode: .common)
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
    
    func configureAudio() {
        SDL_SetMainReady()
        SDL_InitSubSystem(SDL_INIT_AUDIO)
        
        var spec: SDL_AudioSpec = .init()
        spec.callback = nil
        spec.userdata = nil
        spec.channels = 2
        spec.format = .init(AUDIO_S16)
        spec.freq = 32768
        spec.samples = 1024
        
        audioDeviceID = SDL_OpenAudioDevice(nil, 0, &spec, nil, 0)
        SDL_PauseAudioDevice(audioDeviceID, 0)
    }
    
    @objc func step() {
        NewGrape.shared.step()
    }
    
    override func controllerDidConnect(_ notification: Notification) {
        guard let controller = notification.object as? GCController,
              let extendedGamepad = controller.extendedGamepad else { return }
        
        if let controllerView = self.controllerView { controllerView.hide() }
        
        extendedGamepad.buttonA.pressedChangedHandler = { element, value, pressed in
            let handler: GrapeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.a, controller.playerIndex)
        }
        
        extendedGamepad.buttonB.pressedChangedHandler = { element, value, pressed in
            let handler: GrapeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.b, controller.playerIndex)
        }
        
        extendedGamepad.buttonX.pressedChangedHandler = { element, value, pressed in
            let handler: GrapeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.x, controller.playerIndex)
        }
        
        extendedGamepad.buttonY.pressedChangedHandler = { element, value, pressed in
            let handler: GrapeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.y, controller.playerIndex)
        }
        
        extendedGamepad.dpad.up.pressedChangedHandler = { element, value, pressed in
            let handler: GrapeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.up, controller.playerIndex)
        }
        
        extendedGamepad.dpad.down.pressedChangedHandler = { element, value, pressed in
            let handler: GrapeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.down, controller.playerIndex)
        }
        
        extendedGamepad.dpad.left.pressedChangedHandler = { element, value, pressed in
            let handler: GrapeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.left, controller.playerIndex)
        }
        
        extendedGamepad.dpad.right.pressedChangedHandler = { element, value, pressed in
            let handler: GrapeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.right, controller.playerIndex)
        }
        
        extendedGamepad.leftShoulder.pressedChangedHandler = { element, value, pressed in
            let handler: GrapeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.l, controller.playerIndex)
        }
        
        extendedGamepad.rightShoulder.pressedChangedHandler = { element, value, pressed in
            let handler: GrapeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.r, controller.playerIndex)
        }
        
        extendedGamepad.buttonOptions?.pressedChangedHandler = { element, value, pressed in
            let handler: GrapeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.minus, controller.playerIndex)
        }
        
        extendedGamepad.buttonMenu.pressedChangedHandler = { element, value, pressed in
            let handler: GrapeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.plus, controller.playerIndex)
        }
    }
    
    override func controllerDidDisconnect(_ notification: Notification) {
        if let controllerView = self.controllerView { controllerView.show() }
    }
    
    override func applicationStateDidChange(_ notification: Notification) {
        guard let _ = notification.object as? ApplicationState else {
            return
        }
        
        guard let displayLink = self.displayLink else { return }
        displayLink.isPaused.toggle()
        
        SDL_PauseAudioDevice(self.audioDeviceID, displayLink.isPaused ? 1 : 0)
    }
    
    static func touchBegan(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
        switch type {
        case .up:
            NewGrape.shared.button(button: .up, pressed: true)
        case .down:
            NewGrape.shared.button(button: .down, pressed: true)
        case .left:
            NewGrape.shared.button(button: .left, pressed: true)
        case .right:
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
        case .up:
            NewGrape.shared.button(button: .up, pressed: false)
        case .down:
            NewGrape.shared.button(button: .down, pressed: false)
        case .left:
            NewGrape.shared.button(button: .left, pressed: false)
        case .right:
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
        guard let bottomImageView, let touch = touches.first, touch.view == bottomImageView else {
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
        guard let bottomImageView, let touch = touches.first, touch.view == bottomImageView else {
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
                            
                            SDL_PauseAudioDevice(self.audioDeviceID, 1)
                            SDL_CloseAudioDevice(self.audioDeviceID)
                            
                            NewGrape.shared.stop()
                            
                            self.dismiss(animated: true)
                        }))
                        self.present(alertController, animated: true)
                    })
                ])
        })
    }
}
