//
//  LycheeSkinController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 29/7/2024.
//

import Foundation
import Lychee
import UIKit
import GameController

class LycheeSkinController : SkinController {
    var imageView: UIImageView? = nil
    var thread: Thread? = nil
    var isRunning: Bool = false
    
    override init(game: GameBase, skin: Skin) {
        super.init(game: game, skin: skin)
        Lychee.shared.insert(from: game.fileDetails.url)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let orientation = skin.orientation(for: interfaceOrientation()) else { return }
        
        imageView = if let screen = orientation.screens.first {
            .init(frame: .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height))
        } else {
            .init(frame: view.bounds)
        }
        guard let controllerView, let imageView else { return }
        view.insertSubview(imageView, belowSubview: controllerView)
        
        isRunning = true
        Thread.detachNewThread(step)
        
        Lychee.shared.bgr555 { [weak self] pointer, displayWidth, displayHeight, _, _ in
            guard let self, let imageView = self.imageView else { return }
            
            guard let cgImage = CGImage.psx_bgr555(pointer, 1024, 512),
            let cropped = cgImage.cropping(to: .init(x: 0, y: 0, width: .init(displayWidth), height: .init(displayHeight))) else { return }
            
            Task {
                imageView.image = .init(cgImage: cropped)
            }
        }
        
        Lychee.shared.rgb888 { [weak self] pointer, displayWidth, displayHeight, _, _ in
            guard let self, let imageView = self.imageView else { return }
            
            guard let cgImage = CGImage.psx_rgb888(pointer, 1024, 512),
            let cropped = cgImage.cropping(to: .init(x: 0, y: 0, width: .init(displayWidth), height: .init(displayHeight))) else { return }
            
            Task {
                imageView.image = .init(cgImage: cropped)
            }
        }
        
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { context in } completion: { context in
            guard let orientation = self.skin.orientation(for: self.interfaceOrientation()) else { return }
            guard let imageView = self.imageView else { return }
            imageView.frame = if let screen = orientation.screens.first {
                .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height)
            } else {
                self.view.bounds
            }
        }
    }
    
    @objc func step() {
        while isRunning { Lychee.shared.step() }
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
        case .dpadUp:
            Lychee.shared.input(playerIndex.rawValue, .up, true)
        case .dpadDown:
            Lychee.shared.input(playerIndex.rawValue, .down, true)
        case .dpadLeft:
            Lychee.shared.input(playerIndex.rawValue, .left, true)
        case .dpadRight:
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
        case .settings:
            if let viewController = UIApplication.shared.viewController as? LycheeSkinController {
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
            Lychee.shared.input(playerIndex.rawValue, .circle, false)
        case .b:
            Lychee.shared.input(playerIndex.rawValue, .cross, false)
        case .x:
            Lychee.shared.input(playerIndex.rawValue, .triangle, false)
        case .y:
            Lychee.shared.input(playerIndex.rawValue, .square, false)
        case .dpadUp:
            Lychee.shared.input(playerIndex.rawValue, .up, false)
        case .dpadDown:
            Lychee.shared.input(playerIndex.rawValue, .down, false)
        case .dpadLeft:
            Lychee.shared.input(playerIndex.rawValue, .left, false)
        case .dpadRight:
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

extension LycheeSkinController : UIContextMenuInteractionDelegate {
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
