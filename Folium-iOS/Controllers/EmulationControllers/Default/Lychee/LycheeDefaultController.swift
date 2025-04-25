//
//  LycheeDefaultController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 29/7/2024.
//

import Foundation
import GameController
import Lychee
import UIKit

class LycheeDefaultController : SkinController {
    var imageView: UIImageView? = nil, blurredImageView: UIImageView? = nil
    var thread: Thread? = nil
    var isRunning: Bool = false
    
    var portraitConstraints: [NSLayoutConstraint] = []
    var landscapeConstraints: [NSLayoutConstraint] = []
    
    override init(game: GameBase, skin: Skin) {
        super.init(game: game, skin: skin)
        Lychee.shared.insert(from: game.fileDetails.url)
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
        
        isRunning = true
        Thread.detachNewThread(step)
        
        Lychee.shared.bgr555 { [weak self] pointer, displayWidth, displayHeight, _, _ in
            guard let self, let imageView = self.imageView, let blurredImageView = self.blurredImageView else { return }
            
            guard let cgImage = CGImage.psx_bgr555(pointer, 1024, 512),
            let cropped = cgImage.cropping(to: .init(x: 0, y: 0, width: .init(displayWidth), height: .init(displayHeight))) else { return }
            
            Task {
                imageView.image = .init(cgImage: cropped)
                blurredImageView.image = .init(cgImage: cropped)
            }
        }
        
        Lychee.shared.rgb888 { [weak self] pointer, displayWidth, displayHeight, _, _ in
            guard let self, let imageView = self.imageView, let blurredImageView = self.blurredImageView else { return }
            
            guard let cgImage = CGImage.psx_rgb888(pointer, 1024, 512),
            let cropped = cgImage.cropping(to: .init(x: 0, y: 0, width: .init(displayWidth), height: .init(displayHeight))) else { return }
            
            Task {
                imageView.image = .init(cgImage: cropped)
                blurredImageView.image = .init(cgImage: cropped)
            }
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
        while isRunning { Lychee.shared.step() }
    }
    
    override func controllerDidConnect(_ notification: Notification) {
        guard let controller = notification.object as? GCController,
              let extendedGamepad = controller.extendedGamepad else { return }
        
        if let controllerView = self.controllerView { controllerView.hide() }
        
        extendedGamepad.buttonA.pressedChangedHandler = { element, value, pressed in
            let handler: LycheeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.a, controller.playerIndex)
        }
        
        extendedGamepad.buttonB.pressedChangedHandler = { element, value, pressed in
            let handler: LycheeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.b, controller.playerIndex)
        }
        
        extendedGamepad.buttonX.pressedChangedHandler = { element, value, pressed in
            let handler: LycheeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.x, controller.playerIndex)
        }
        
        extendedGamepad.buttonY.pressedChangedHandler = { element, value, pressed in
            let handler: LycheeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.y, controller.playerIndex)
        }
        
        extendedGamepad.dpad.up.pressedChangedHandler = { element, value, pressed in
            let handler: LycheeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.up, controller.playerIndex)
        }
        
        extendedGamepad.dpad.down.pressedChangedHandler = { element, value, pressed in
            let handler: LycheeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.down, controller.playerIndex)
        }
        
        extendedGamepad.dpad.left.pressedChangedHandler = { element, value, pressed in
            let handler: LycheeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.left, controller.playerIndex)
        }
        
        extendedGamepad.dpad.right.pressedChangedHandler = { element, value, pressed in
            let handler: LycheeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.right, controller.playerIndex)
        }
        
        extendedGamepad.leftShoulder.pressedChangedHandler = { element, value, pressed in
            let handler: LycheeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.l, controller.playerIndex)
        }
        
        extendedGamepad.rightShoulder.pressedChangedHandler = { element, value, pressed in
            let handler: LycheeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.r, controller.playerIndex)
        }
        
        extendedGamepad.leftTrigger.pressedChangedHandler = { element, value, pressed in
            let handler: LycheeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.zl, controller.playerIndex)
        }
        
        extendedGamepad.rightTrigger.pressedChangedHandler = { element, value, pressed in
            let handler: LycheeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.zr, controller.playerIndex)
        }
        
        extendedGamepad.buttonOptions?.pressedChangedHandler = { element, value, pressed in
            let handler: LycheeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.minus, controller.playerIndex)
        }
        
        extendedGamepad.buttonMenu.pressedChangedHandler = { element, value, pressed in
            let handler: LycheeButtonHandler = pressed ? self.touchBegan : self.touchEnded
            handler(.plus, controller.playerIndex)
        }
    }
    
    override func controllerDidDisconnect(_ notification: Notification) {
        if let controllerView = self.controllerView { controllerView.show() }
    }
    
    static func touchBegan(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
        switch type {
        case .a:
            Lychee.shared.input(playerIndex.rawValue, .circle, true)
        case .b:
            Lychee.shared.input(playerIndex.rawValue, .cross, true)
        case .x:
            Lychee.shared.input(playerIndex.rawValue, .triangle, true)
        case .y:
            Lychee.shared.input(playerIndex.rawValue, .square, true)
        case .up:
            Lychee.shared.input(playerIndex.rawValue, .up, true)
        case .down:
            Lychee.shared.input(playerIndex.rawValue, .down, true)
        case .left:
            Lychee.shared.input(playerIndex.rawValue, .left, true)
        case .right:
            Lychee.shared.input(playerIndex.rawValue, .right, true)
        case .minus:
            Lychee.shared.input(playerIndex.rawValue, .select, true)
        case .plus:
            Lychee.shared.input(playerIndex.rawValue, .start, true)
        case .l:
            Lychee.shared.input(playerIndex.rawValue, .l1, true)
        case .r:
            Lychee.shared.input(playerIndex.rawValue, .r1, true)
        case .zl:
            Lychee.shared.input(playerIndex.rawValue, .l2, true)
        case .zr:
            Lychee.shared.input(playerIndex.rawValue, .r2, true)
        default:
            break
        }
    }
    
    static func touchEnded(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
        switch type {
        case .a:
            Lychee.shared.input(playerIndex.rawValue, .circle, false)
        case .b:
            Lychee.shared.input(playerIndex.rawValue, .cross, false)
        case .x:
            Lychee.shared.input(playerIndex.rawValue, .triangle, false)
        case .y:
            Lychee.shared.input(playerIndex.rawValue, .square, false)
        case .up:
            Lychee.shared.input(playerIndex.rawValue, .up, false)
        case .down:
            Lychee.shared.input(playerIndex.rawValue, .down, false)
        case .left:
            Lychee.shared.input(playerIndex.rawValue, .left, false)
        case .right:
            Lychee.shared.input(playerIndex.rawValue, .right, false)
        case .minus:
            Lychee.shared.input(playerIndex.rawValue, .select, false)
        case .plus:
            Lychee.shared.input(playerIndex.rawValue, .start, false)
        case .l:
            Lychee.shared.input(playerIndex.rawValue, .l1, false)
        case .r:
            Lychee.shared.input(playerIndex.rawValue, .r1, false)
        case .zl:
            Lychee.shared.input(playerIndex.rawValue, .l2, false)
        case .zr:
            Lychee.shared.input(playerIndex.rawValue, .r2, false)
        default:
            break
        }
    }
    
    static func touchMoved(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {}
}

extension LycheeDefaultController : UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        .init(actionProvider: { _ in
            .init(children: [
                UIAction(title: "Stop & Exit", attributes: [.destructive], handler: { _ in
                    let alertController = UIAlertController(title: "Stop & Exit", message: "Are you sure?", preferredStyle: .alert)
                    alertController.addAction(.init(title: "Dismiss", style: .cancel))
                    alertController.addAction(.init(title: "Stop & Exit", style: .destructive, handler: { _ in
                        if self.isRunning {
                            self.isRunning = false
                            Lychee.shared.stop()
                        }
                        
                        self.dismiss(animated: true)
                    }))
                    self.present(alertController, animated: true)
                })
            ])
        })
    }
}
