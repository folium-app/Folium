//
//  NintendoDSEmulationController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 23/7/2024.
//

import AVFoundation
import Foundation
import Grape
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
            // try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            // try AVAudioSession.sharedInstance().setActive(true)
            
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

typealias GrapeAudioCallback = @convention(c)(UnsafeMutableRawPointer?, UnsafeMutablePointer<UInt8>?, Int32) -> Void
class NintendoDSEmulationController : UIViewController {
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let bottomScreenImageView {
            Grape.shared.updateScreenLayout(with: bottomScreenImageView.frame.size)
        } else {
            if let topScreenImageView {
                Grape.shared.updateScreenLayout(with: topScreenImageView.frame.size)
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in } completion: { _ in
            guard let orientation = self.skin.orientation(for: self.interfaceOrientation()) else {
                return
            }
            
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
#if !targetEnvironment(simulator)
        audioStreamer = .init()
        guard let audioStreamer else {
            return
        }
        
        audioStreamer.delegate = self
        audioStreamer.startStreaming()
#endif
        
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
extension NintendoDSEmulationController {
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
        guard let touch = touches.first, let view = touch.view else {
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
extension NintendoDSEmulationController : ControllerButtonDelegate {
    func touchBegan(with type: Button.`Type`) {
        switch type {
        case .dpadUp:
            Grape.shared.virtualControllerButtonDown(6)
        case .dpadDown:
            Grape.shared.virtualControllerButtonDown(7)
        case .dpadLeft:
            Grape.shared.virtualControllerButtonDown(5)
        case .dpadRight:
            Grape.shared.virtualControllerButtonDown(4)
        case .minus:
            Grape.shared.virtualControllerButtonDown(2)
        case .plus:
            Grape.shared.virtualControllerButtonDown(3)
        case .a:
            Grape.shared.virtualControllerButtonDown(0)
        case .b:
            Grape.shared.virtualControllerButtonDown(1)
        case .x:
            Grape.shared.virtualControllerButtonDown(10)
        case .y:
            Grape.shared.virtualControllerButtonDown(11)
        case .l:
            Grape.shared.virtualControllerButtonDown(9)
        case .r:
            Grape.shared.virtualControllerButtonDown(8)
        default:
            break
        }
    }
    
    func touchEnded(with type: Button.`Type`) {
        switch type {
        case .dpadUp:
            Grape.shared.virtualControllerButtonUp(6)
        case .dpadDown:
            Grape.shared.virtualControllerButtonUp(7)
        case .dpadLeft:
            Grape.shared.virtualControllerButtonUp(5)
        case .dpadRight:
            Grape.shared.virtualControllerButtonUp(4)
        case .minus:
            Grape.shared.virtualControllerButtonUp(2)
        case .plus:
            Grape.shared.virtualControllerButtonUp(3)
        case .a:
            Grape.shared.virtualControllerButtonUp(0)
        case .b:
            Grape.shared.virtualControllerButtonUp(1)
        case .x:
            Grape.shared.virtualControllerButtonUp(10)
        case .y:
            Grape.shared.virtualControllerButtonUp(11)
        case .l:
            Grape.shared.virtualControllerButtonUp(9)
        case .r:
            Grape.shared.virtualControllerButtonUp(8)
        default:
            break
        }
    }
    
    func touchMoved(with type: Button.`Type`) {}
}

// MARK: Thumbstick Delegate
extension NintendoDSEmulationController : ControllerThumbstickDelegate {
    func touchBegan(with type: Thumbstick.`Type`, position: (x: Float, y: Float)) {}
    func touchEnded(with type: Thumbstick.`Type`, position: (x: Float, y: Float)) {}
    func touchMoved(with type: Thumbstick.`Type`, position: (x: Float, y: Float)) {}
}


extension NintendoDSEmulationController : AudioStreamerDelegate {
    func processMicrophoneBuffer(with buffer: AVAudioPCMBuffer) {
        let frameLength = buffer.frameLength
        let channelData = buffer.int16ChannelData

        guard let channelData else {
            return
        }
        
        Grape.shared.microphoneBuffer(with: channelData[0])
    }
}
