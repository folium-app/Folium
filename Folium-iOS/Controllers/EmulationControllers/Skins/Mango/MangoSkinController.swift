//
//  MangoSkinController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 20/12/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation
import GameController
import Mango
import SDL
import UIKit

enum SNESControllerButton : Int32 {
    case b = 0
    case y = 1
    case select = 2
    case start = 3
    case up = 4
    case down = 5
    case left = 6
    case right = 7
    case a = 8
    case x = 9
    case l = 10
    case r = 11
}

typealias MangoAudioCallback = @convention(c)(UnsafeMutableRawPointer?, UnsafeMutablePointer<UInt8>?, Int32) -> Void
class MangoSkinController : SkinController {
    var imageView: UIImageView? = nil
    
    var audioDeviceID: SDL_AudioDeviceID!
    
    let mango = Mango.shared
    
    override init(game: GameBase, skin: Skin) {
        super.init(game: game, skin: skin)
        mango.insertCartridge(from: game.fileDetails.url)
    }
    
    required init?(coder: NSCoder) {
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
        
        let displayLink = CADisplayLink(target: self, selector: #selector(step))
        displayLink.preferredFrameRateRange = .init(minimum: 30, maximum: mango.type() == .PAL ? 50 : 60)
        displayLink.add(to: .main, forMode: .common)
        
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
                    self.touchBegan(with: .up, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .up, playerIndex: .index1)
                }
            }
            
            extendedGamepad.dpad.down.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .down, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .down, playerIndex: .index1)
                }
            }
            
            extendedGamepad.dpad.left.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .left, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .left, playerIndex: .index1)
                }
            }
            
            extendedGamepad.dpad.right.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .right, playerIndex: .index1)
                } else {
                    self.touchEnded(with: .right, playerIndex: .index1)
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
        guard let imageView else { return }
        
        mango.step()
        
        let audioBuffer = mango.audioBuffer()
        let videoBuffer = mango.videoBuffer()
        guard let audioBuffer, let videoBuffer else { return }
        guard let cgImage = CGImage.snes(videoBuffer, 512, 480) else { return }
        
        let wantedSamples = 48000 / (mango.type() == .PAL ? 50 : 60)
        if SDL_GetQueuedAudioSize(audioDeviceID) <= wantedSamples * 4 * 6 {
            SDL_QueueAudio(audioDeviceID, audioBuffer, UInt32(wantedSamples * 4))
        }
        
        Task {
            imageView.image = .init(cgImage: cgImage)
        }
    }
}

extension MangoSkinController {
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
        case .up:
            Mango.shared.button(button: SNESControllerButton.up.rawValue, player: playerIndex.rawValue, pressed: true)
        case .down:
            Mango.shared.button(button: SNESControllerButton.down.rawValue, player: playerIndex.rawValue, pressed: true)
        case .left:
            Mango.shared.button(button: SNESControllerButton.left.rawValue, player: playerIndex.rawValue, pressed: true)
        case .right:
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
        case .up:
            Mango.shared.button(button: SNESControllerButton.up.rawValue, player: playerIndex.rawValue, pressed: false)
        case .down:
            Mango.shared.button(button: SNESControllerButton.down.rawValue, player: playerIndex.rawValue, pressed: false)
        case .left:
            Mango.shared.button(button: SNESControllerButton.left.rawValue, player: playerIndex.rawValue, pressed: false)
        case .right:
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

extension MangoSkinController {
    static func touchBegan(with type: Thumbstick.`Type`, position: (x: Float, y: Float), playerIndex: GCControllerPlayerIndex) {}
    
    static func touchEnded(with type: Thumbstick.`Type`, position: (x: Float, y: Float), playerIndex: GCControllerPlayerIndex) {}
    
    static func touchMoved(with type: Thumbstick.`Type`, position: (x: Float, y: Float), playerIndex: GCControllerPlayerIndex) {}
}
