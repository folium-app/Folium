//
//  SuperNESEmulationController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 24/8/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation
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
class SuperNESEmulationController : UIViewController {
    var controllerView: ControllerView? = nil
    var imageView: UIImageView? = nil
    
    let mango = Mango.shared
    
    var audioDeviceID: SDL_AudioDeviceID!
    
    var game: SuperNESGame
    var skin: Skin
    init(game: SuperNESGame, skin: Skin) {
        self.game = game
        self.skin = skin
        super.init(nibName: nil, bundle: nil)
        mango.insertCartridge(from: game.fileDetails.url)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        guard let orientation = skin.orientation(for: interfaceOrientation()) else {
            return
        }
        
        imageView = if !orientation.screens.isEmpty, let screen = orientation.screens.first {
            .init(frame: .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height))
        } else {
            .init(frame: view.bounds)
        }
        guard let imageView else {
            return
        }
        
        controllerView = .init(orientation: orientation, skin: skin, delegates: (self, self))
        guard let controllerView, let screensView = controllerView.screensView else {
            return
        }
        
        controllerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controllerView)
        
        controllerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controllerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        controllerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        controllerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        screensView.addSubview(imageView)
        
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
        
        let pal = mango.type() == .PAL
        
        let displayLink = CADisplayLink(target: self, selector: #selector(step))
        displayLink.preferredFrameRateRange = .init(minimum: 30, maximum: pal ? 50 : 60)
        displayLink.add(to: .main, forMode: .common)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in } completion: { _ in
            guard let imageView = self.imageView, let controllerView = self.controllerView, let skin = SkinManager.shared.mangoSkin else {
                return
            }
            
            self.skin = skin
            
            guard let orientation = self.skin.orientation(for: self.interfaceOrientation()) else {
                return
            }
            
            controllerView.updateFrames(for: orientation)
            
            imageView.frame = if !orientation.screens.isEmpty, let screen = orientation.screens.first {
                .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height)
            } else {
                self.view.bounds
            }
        }
    }
    
    @MainActor
    @objc func step() {
        mango.step()
        
        let pal = mango.type() == .PAL
        
        let wantedSamples = 48000 / (pal ? 50 : 60)
        if SDL_GetQueuedAudioSize(audioDeviceID) <= wantedSamples * 4 * 6 {
            SDL_QueueAudio(audioDeviceID, mango.audioBuffer(), UInt32(wantedSamples * 4))
        }
        
        let videoBuffer = mango.videoBuffer()
        guard let imageView, let cgImage = CGImage.cgImage(buffer8: videoBuffer, 512, 480) else {
            return
        }
        
        Task {
            imageView.image = .init(cgImage: cgImage)
        }
    }
}


// MARK: Button Delegate
extension SuperNESEmulationController : ControllerButtonDelegate {
    func touchBegan(with type: Button.`Type`) {
        switch type {
        case .a:
            mango.button(button: SNESControllerButton.a.rawValue, player: 1, pressed: true)
        case .b:
            mango.button(button: SNESControllerButton.b.rawValue, player: 1, pressed: true)
        case .x:
            mango.button(button: SNESControllerButton.x.rawValue, player: 1, pressed: true)
        case .y:
            mango.button(button: SNESControllerButton.y.rawValue, player: 1, pressed: true)
        case .dpadUp:
            mango.button(button: SNESControllerButton.up.rawValue, player: 1, pressed: true)
        case .dpadDown:
            mango.button(button: SNESControllerButton.down.rawValue, player: 1, pressed: true)
        case .dpadLeft:
            mango.button(button: SNESControllerButton.left.rawValue, player: 1, pressed: true)
        case .dpadRight:
            mango.button(button: SNESControllerButton.right.rawValue, player: 1, pressed: true)
        case .minus:
            mango.button(button: SNESControllerButton.select.rawValue, player: 1, pressed: true)
        case .plus:
            mango.button(button: SNESControllerButton.start.rawValue, player: 1, pressed: true)
        case .l:
            mango.button(button: SNESControllerButton.l.rawValue, player: 1, pressed: true)
        case .r:
            mango.button(button: SNESControllerButton.r.rawValue, player: 1, pressed: true)
        default:
            break
        }
    }
    
    func touchEnded(with type: Button.`Type`) {
        switch type {
        case .a:
            mango.button(button: SNESControllerButton.a.rawValue, player: 1, pressed: false)
        case .b:
            mango.button(button: SNESControllerButton.b.rawValue, player: 1, pressed: false)
        case .x:
            mango.button(button: SNESControllerButton.x.rawValue, player: 1, pressed: false)
        case .y:
            mango.button(button: SNESControllerButton.y.rawValue, player: 1, pressed: false)
        case .dpadUp:
            mango.button(button: SNESControllerButton.up.rawValue, player: 1, pressed: false)
        case .dpadDown:
            mango.button(button: SNESControllerButton.down.rawValue, player: 1, pressed: false)
        case .dpadLeft:
            mango.button(button: SNESControllerButton.left.rawValue, player: 1, pressed: false)
        case .dpadRight:
            mango.button(button: SNESControllerButton.right.rawValue, player: 1, pressed: false)
        case .minus:
            mango.button(button: SNESControllerButton.select.rawValue, player: 1, pressed: false)
        case .plus:
            mango.button(button: SNESControllerButton.start.rawValue, player: 1, pressed: false)
        case .l:
            mango.button(button: SNESControllerButton.l.rawValue, player: 1, pressed: false)
        case .r:
            mango.button(button: SNESControllerButton.r.rawValue, player: 1, pressed: false)
        default:
            break
        }
    }
    
    func touchMoved(with type: Button.`Type`) {}
}

// MARK: Thumbstick Delegate
extension SuperNESEmulationController : ControllerThumbstickDelegate {
    func touchBegan(with type: Thumbstick.`Type`, position: (x: Float, y: Float)) {}
    
    func touchEnded(with type: Thumbstick.`Type`, position: (x: Float, y: Float)) {}
    
    func touchMoved(with type: Thumbstick.`Type`, position: (x: Float, y: Float)) {}
}
