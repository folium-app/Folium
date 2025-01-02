//
//  GrapeSkinController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 23/7/2024.
//

import AVFoundation
import Foundation
import Grape
import GameController
import SDL
import UIKit

protocol AudioStreamerDelegate {
    func processMicrophoneBuffer(with buffer: AVAudioPCMBuffer)
}

class AudioStreamer : NSObject {
    var delegate: AudioStreamerDelegate? = nil
    
    private let audioEngine = AVAudioEngine()
    private let inputNode: AVAudioInputNode
    private let bus = 0

    override init() {
        inputNode = audioEngine.inputNode
    }

    func startStreaming() {
        let format = inputNode.inputFormat(forBus: bus)

        inputNode.installTap(onBus: bus, bufferSize: 1024, format: format) { (buffer, time) in
            guard let delegate = self.delegate else {
                return
            }
            
            delegate.processMicrophoneBuffer(with: buffer)
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            if #available(iOS 17, *) {
                AVAudioApplication.requestRecordPermission { success in
                    print(#function, "requestRecordPermission:", success)
                }
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission { success in
                    print(#function, "requestRecordPermission:", success)
                }
            }
            
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }

    func stopStreaming() {
        inputNode.removeTap(onBus: bus)
        audioEngine.stop()
        
        // do {
        //     try AVAudioSession.sharedInstance().setActive(false)
        // } catch {
        //     print(error.localizedDescription)
        // }
    }
}

class GrapeSkinController : UIViewController {
    fileprivate var audioStreamer: AudioStreamer? = nil
    fileprivate var audioDeviceID: SDL_AudioDeviceID!
    
    fileprivate var controllerView: ControllerView? = nil
    fileprivate var topScreenImageView: UIImageView? = nil, bottomScreenImageView: UIImageView? = nil
    
    var skin: Skin
    init(game: NintendoDSGame, skin: Skin) {
        self.skin = skin
        super.init(nibName: nil, bundle: nil)
        Grape.shared.insertCartridge(from: game.fileDetails.url)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        skin.orientations.supportedInterfaceOrientations
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        guard let orientation = skin.orientation(for: interfaceOrientation()) else {
            return
        }
        
        orientation.screens.enumerated().forEach { index, screen in
            switch index {
            case 0:
                topScreenImageView = .init(frame: .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height))
                guard let topScreenImageView else {
                    return
                }
                
                self.view.addSubview(topScreenImageView)
            case 1:
                bottomScreenImageView = .init(frame: .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height))
                guard let bottomScreenImageView else {
                    return
                }
                
                self.view.addSubview(bottomScreenImageView)
            default:
                break
            }
        }
        
        if let bottomScreenImageView {
            bottomScreenImageView.isUserInteractionEnabled = true
        } else {
            if let topScreenImageView {
                topScreenImageView.isUserInteractionEnabled = true
            }
        }
        
        controllerView = .init(orientation: orientation, skin: skin, delegates: (self, self))
        guard let controllerView else {
            return
        }
        
        controllerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controllerView)
        
        controllerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controllerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        controllerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        controllerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        configureAudio()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(step))
        displayLink.preferredFrameRateRange = .init(minimum: 30, maximum: 60)
        displayLink.add(to: .main, forMode: .common)
        
        var config = UIButton.Configuration.plain()
        config.buttonSize = .small
        config.cornerStyle = .capsule
        config.image = .init(systemName: "gearshape.fill")?
            .applyingSymbolConfiguration(.init(paletteColors: [.white]))
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.showsMenuAsPrimaryAction = true
        button.menu = .init(children: [
            UIAction(title: "Open Settings", image: .init(systemName: "gearshape"), handler: { _ in
                var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                configuration.headerMode = .supplementary
                let listCollectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
                
                let grapeSettingsController = UINavigationController(rootViewController: GrapeSettingsController(collectionViewLayout: listCollectionViewLayout))
                if let sheetPresentationController = grapeSettingsController.sheetPresentationController {
                    sheetPresentationController.detents = [.medium(), .large()]
                }
                self.present(grapeSettingsController, animated: true)
            }),
            UIAction(title: "Toggle Play/Pause", handler: { _ in
                SDL_PauseAudioDevice(self.audioDeviceID, Grape.shared.togglePause() ? 1 : 0)
            }),
            UIAction(title: "Stop & Exit", attributes: [.destructive], handler: { _ in
                let alertController = UIAlertController(title: "Stop & Exit", message: "Are you sure?", preferredStyle: .alert)
                alertController.addAction(.init(title: "Dismiss", style: .cancel))
                alertController.addAction(.init(title: "Stop & Exit", style: .destructive, handler: { _ in
                    displayLink.remove(from: .main, forMode: .common)
                    
                    SDL_CloseAudioDevice(self.audioDeviceID)
                    
                    Grape.shared.stop()
                    self.dismiss(animated: true)
                }))
                self.present(alertController, animated: true)
            })
        ])
        view.addSubview(button)
        
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        
        Task {
            await GCController.startWirelessControllerDiscovery()
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name.GCControllerDidConnect, object: nil, queue: .main) { notification in
            guard let controller = notification.object as? GCController, let extendedGamepad = controller.extendedGamepad else {
                return
            }
            
            if let controllerView = self.controllerView {
                controllerView.hide()
            }
            
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
            if let controllerView = self.controllerView {
                controllerView.show()
            }
        }
        
        NotificationCenter.default.addObserver(forName: .init("applicationStateDidChange"), object: nil, queue: .main) { notification in
            guard let _ = notification.object as? ApplicationState else {
                return
            }
            
            SDL_PauseAudioDevice(self.audioDeviceID, Grape.shared.togglePause() ? 1 : 0)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let bottomScreenImageView {
            Grape.shared.updateScreenLayout(with: bottomScreenImageView.bounds.size)
        } else {
            if let topScreenImageView {
                Grape.shared.updateScreenLayout(with: topScreenImageView.bounds.size)
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in } completion: { _ in
            let skin = if let url = self.skin.url {
                try? SkinManager.shared.skin(from: url)
            } else {
                grapeSkin
            }
            
            guard let skin, let orientation = skin.orientation(for: self.interfaceOrientation()), let controllerView = self.controllerView else {
                return
            }
            
            self.skin = skin
            
            controllerView.updateFrames(for: orientation, controllerDisconnected: GCController.controllers().isEmpty)
            
            orientation.screens.enumerated().forEach { index, screen in
                switch index {
                case 0:
                    guard let topScreenImageView = self.topScreenImageView else {
                        return
                    }
                    
                    topScreenImageView.frame = .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height)
                case 1:
                    guard let bottomScreenImageView = self.bottomScreenImageView else {
                        return
                    }
                    
                    bottomScreenImageView.frame = .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height)
                default:
                    break
                }
            }
        }
    }
    
    @objc func step() {
        Grape.shared.step()
        
        let topScreenBuffer = Grape.shared.videoBuffer()
        
        let size = Grape.shared.videoBufferSize()
        
        guard let topScreenImageView, let topScreenCGImage = CGImage.cgImage(topScreenBuffer, Int(size.width), Int(size.height)) else {
            return
        }
        
        Task {
            topScreenImageView.image = .init(cgImage: topScreenCGImage)
        }
        
        guard let bottomScreenImageView, let bottomScreenCGImage = CGImage.cgImage(topScreenBuffer.advanced(by: 256 * 192), Int(size.width), Int(size.height)) else {
            return
        }
        
        Task {
            bottomScreenImageView.image = .init(cgImage: bottomScreenCGImage)
        }
    }
    
    fileprivate func configureAudio() {
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
}

// MARK: Touches
extension GrapeSkinController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        
        if let bottomScreenImageView {
            Grape.shared.touchBegan(at: touch.location(in: bottomScreenImageView))
        } else {
            if let topScreenImageView {
                Grape.shared.touchBegan(at: touch.location(in: topScreenImageView))
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        Grape.shared.touchEnded()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        
        if let bottomScreenImageView {
            Grape.shared.touchMoved(at: touch.location(in: bottomScreenImageView))
        } else {
            if let topScreenImageView {
                Grape.shared.touchMoved(at: touch.location(in: topScreenImageView))
            }
        }
    }
}

// MARK: Button Delegate
extension GrapeSkinController : ControllerButtonDelegate {
    func touchBegan(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
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
        default:
            break
        }
    }
    
    func touchEnded(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
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
    
    func touchMoved(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {}
}

// MARK: Thumbstick Delegate
extension GrapeSkinController : ControllerThumbstickDelegate {
    func touchBegan(with type: Thumbstick.`Type`, position: (x: Float, y: Float), playerIndex: GCControllerPlayerIndex) {}
    func touchEnded(with type: Thumbstick.`Type`, position: (x: Float, y: Float), playerIndex: GCControllerPlayerIndex) {}
    func touchMoved(with type: Thumbstick.`Type`, position: (x: Float, y: Float), playerIndex: GCControllerPlayerIndex) {}
}


extension GrapeSkinController : AudioStreamerDelegate {
    func processMicrophoneBuffer(with buffer: AVAudioPCMBuffer) {
        let _ = buffer.frameLength
        let channelData = buffer.int16ChannelData

        guard let channelData else {
            return
        }
        
        Grape.shared.microphoneBuffer(with: channelData[0])
    }
}
