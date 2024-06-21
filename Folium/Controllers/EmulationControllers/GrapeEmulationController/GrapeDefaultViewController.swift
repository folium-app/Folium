//
//  GrapeEmulationController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 16/4/2024.
//

import Foundation
import GameController
import Grape
import Metal
// import MetalFX
import MetalKit
import SDL2
import UIKit

class GrapeDefaultViewController : UIViewController {
    fileprivate var controllerView: ControllerView!
    
    let grape: Grape = .shared
    fileprivate var isRunning: Bool = false
    
    fileprivate var topScreen: UIImageView? = nil
    fileprivate var bottomScreen: UIImageView? = nil
    
    fileprivate var audioDeviceID: SDL_AudioDeviceID!
    fileprivate var displayLink: CADisplayLink!
    
    fileprivate let device = MTLCreateSystemDefaultDevice()
    fileprivate var commandQueue: MTLCommandQueue!
    fileprivate var pipelineDescriptor: MTLRenderPipelineDescriptor!
    fileprivate var pipelineState: MTLRenderPipelineState!
    fileprivate var primaryTexture, secondaryTexture: MTLTexture!
    
    fileprivate var game: AnyHashableSendable
    fileprivate var skin: Skin
    init(with game: AnyHashableSendable, skin: Skin) {
        self.game = game
        self.skin = skin
        super.init(nibName: nil, bundle: nil)
        guard let game = game as? GrapeManager.Library.Game else {
            return
        }
        
        grape.insert(game: game.fileDetails.url)
        
        configureAudio()
        // configureMetal()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        guard let game = game as? GrapeManager.Library.Game else {
            return
        }
        
        guard let device = skin.devices.first(where: { $0.device == machine && $0.orientation == self.orientationForCurrentOrientation() }) else {
            return
        }
        
        if game.gameType == .nds {
            device.screens.enumerated().forEach { index, screen in
                let mtkView = UIImageView(frame: .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height))
                if let cornerRadius = screen.cornerRadius, cornerRadius > 0 {
                    mtkView.clipsToBounds = true
                    mtkView.layer.cornerCurve = .continuous
                    mtkView.layer.cornerRadius = cornerRadius
                }
                
                if index == 0 {
                    self.topScreen = mtkView
                    if let topScreen = self.topScreen {
                        self.view.addSubview(topScreen)
                    }
                } else {
                    mtkView.isUserInteractionEnabled = true
                    self.bottomScreen = mtkView
                    if let bottomScreen = self.bottomScreen {
                        self.view.addSubview(bottomScreen)
                    }
                }
            }
        } else {
            if let screen = device.screens.first {
                let mtkView = UIImageView(frame: .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height))
                if let cornerRadius = screen.cornerRadius, cornerRadius > 0 {
                    mtkView.clipsToBounds = true
                    mtkView.layer.cornerCurve = .continuous
                    mtkView.layer.cornerRadius = cornerRadius
                }
                
                topScreen = mtkView
                if let topScreen = self.topScreen {
                    self.view.addSubview(topScreen)
                }
            }
        }
        
        controllerView = .init(with: device, delegates: (button: self, thumbstick: nil), skin: skin)
        controllerView.translatesAutoresizingMaskIntoConstraints = false
        if let alpha = device.alpha {
            controllerView.alpha = alpha
        }
        view.addSubview(controllerView)
        view.bringSubviewToFront(controllerView)
        
        controllerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controllerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        controllerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        controllerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        NotificationCenter.default.addObserver(forName: .init("sceneDidChange"), object: nil, queue: .main) { notification in
            guard let state = notification.object as? SceneDelegate.ApplicationState else {
                return
            }
            
            self.grape.setPaused(state == .background)
        }
        
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
            guard let device = self.skin.devices.first(where: { $0.device == machine && $0.orientation == self.orientationForCurrentOrientation() }) else {
                return
            }
            
            if game.gameType == .nds {
                device.screens.enumerated().forEach { index, screen in
                    if index == 0 {
                        if let topScreen = self.topScreen {
                            topScreen.frame = .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height)
                        }
                    } else {
                        if let bottomScreen = self.bottomScreen {
                            bottomScreen.frame = .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height)
                        }
                    }
                }
            } else {
                if let screen = device.screens.first, let topScreen = self.topScreen {
                    topScreen.frame = .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height)
                }
            }
            
            self.controllerView.orientationChanged(with: device)
        }
        
        NotificationCenter.default.addObserver(forName: .init(NSNotification.Name.GCControllerDidConnect), object: nil, queue: .main, using: controllerDidConnect)
        NotificationCenter.default.addObserver(forName: .init(NSNotification.Name.GCControllerDidDisconnect), object: nil, queue: .main, using: controllerDidDisconnect)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isRunning {
            isRunning = true
            guard let game = game as? GrapeManager.Library.Game else {
                return
            }
            
            if game.gameType == .nds, let bottomScreen = self.bottomScreen {
                grape.updateScreenLayout(with: bottomScreen.frame.size)
            }
            
            Thread.setThreadPriority(1.0)
            Thread.detachNewThread(run)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        skin.supportedOrientations()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let game = game as? GrapeManager.Library.Game, let touch = touches.first, touch.view == bottomScreen, game.gameType == .nds else {
            return
        }
        
        grape.touchBegan(at: touch.location(in: bottomScreen))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let game = game as? GrapeManager.Library.Game, game.gameType == .nds else {
            return
        }
        
        grape.touchEnded()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let game = game as? GrapeManager.Library.Game, let touch = touches.first, touch.view == bottomScreen, game.gameType == .nds else {
            return
        }
        
        grape.touchMoved(at: touch.location(in: bottomScreen))
    }
}

typealias GrapeCallback = @convention(c)(UnsafeMutableRawPointer?, UnsafeMutablePointer<UInt8>?, Int32) -> Void
extension GrapeDefaultViewController {
    fileprivate func configureAudio() {
        SDL_SetMainReady()
        SDL_InitSubSystem(SDL_INIT_AUDIO)
        
        let callback: GrapeCallback = { userdata, stream, len in
            guard let userdata else {
                return
            }
            
            let viewController = Unmanaged<GrapeDefaultViewController>.fromOpaque(userdata).takeUnretainedValue()
            SDL_memcpy(stream, viewController.grape.audioBuffer(), Int(len))
        }
        
        var spec = SDL_AudioSpec()
        spec.callback = callback
        spec.userdata = Unmanaged.passUnretained(self).toOpaque()
        spec.channels = 2
        spec.format = SDL_AudioFormat(AUDIO_S16)
        spec.freq = 48000
        spec.samples = 1024
        
        audioDeviceID = SDL_OpenAudioDevice(nil, 0, &spec, nil, 0)
        SDL_PauseAudioDevice(audioDeviceID, 0)
    }
    
    func configureMetal() {
        guard let game = game as? GrapeManager.Library.Game, let device else {
            return
        }
        
        let isGBA = game.gameType == .gba
        let upscalingFilter = grape.useUpscalingFilter()
        let upscalingFactor = Int(grape.useUpscalingFactor())
        
        var width = isGBA ? 240 : 256
        var height = isGBA ? 160 : 192
        
        if [0, 1, 2].contains(upscalingFilter) {
            width *= upscalingFactor
            height *= upscalingFactor
        }
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false)
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        primaryTexture = device.makeTexture(descriptor: textureDescriptor)
        secondaryTexture = device.makeTexture(descriptor: textureDescriptor)
        
        guard let defaultLibrary = device.makeDefaultLibrary() else {
            return
        }
        
        let vertexFunction = defaultLibrary.makeFunction(name: "vertexShader")
        let fragmentFunction = defaultLibrary.makeFunction(name: "fragmentShader")
        
        pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        commandQueue = device.makeCommandQueue()
    }
    
    func controllerDidConnect(_ notification: Notification) {
        guard let controller = notification.object as? GCController, let extendedGamepad = controller.extendedGamepad else {
            return
        }
        
        extendedGamepad.dpad.up.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .dpadUp) : self.touchEnded(with: .dpadUp)
        }
        
        extendedGamepad.dpad.down.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .dpadDown) : self.touchEnded(with: .dpadDown)
        }
        
        extendedGamepad.dpad.left.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .dpadLeft) : self.touchEnded(with: .dpadLeft)
        }
        
        extendedGamepad.dpad.right.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .dpadRight) : self.touchEnded(with: .dpadRight)
        }
        
        extendedGamepad.buttonOptions?.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .minus) : self.touchEnded(with: .minus)
        }
        
        extendedGamepad.buttonMenu.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .plus) : self.touchEnded(with: .plus)
        }
        
        extendedGamepad.buttonA.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .a) : self.touchEnded(with: .a)
        }
        
        extendedGamepad.buttonB.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .b) : self.touchEnded(with: .b)
        }
        
        extendedGamepad.buttonX.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .x) : self.touchEnded(with: .x)
        }
        
        extendedGamepad.buttonY.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .y) : self.touchBegan(with: .y)
        }
        
        extendedGamepad.leftShoulder.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .l) : self.touchBegan(with: .l)
        }
        
        extendedGamepad.rightShoulder.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchBegan(with: .r) : self.touchBegan(with: .r)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.controllerView.alpha = 0
        }
    }
    
    func controllerDidDisconnect(_ notification: Notification) {
        UIView.animate(withDuration: 0.2) {
            self.controllerView.alpha = 1
        }
    }
    
    @objc func run() {
        guard let game = game as? GrapeManager.Library.Game else {
            return
        }
        
        while !Grape.shared.isStopped() {
            grape.step()
            
            let videoBuffer = grape.videoBuffer(isGBA: game.gameType == .gba)
            
            let upscalingFilter = grape.useUpscalingFilter()
            let upscalingFactor = Int(grape.useUpscalingFactor())
            
            var width = game.gameType == .gba ? 240 : 256
            var height = game.gameType == .gba ? 160 : 192
            
            if [0, 1, 2].contains(upscalingFilter) {
                width *= upscalingFactor
                height *= upscalingFactor
            }
            
            if let topScreen = topScreen, let cgImage = CGImage.cgImage(videoBuffer, width, height) {
                Task {
                    topScreen.image = .init(cgImage: cgImage)
                }
            }
            
            if let bottomScreen = bottomScreen, let cgImage = CGImage.cgImage(videoBuffer.advanced(by: width * height), width, height) {
                Task {
                    bottomScreen.image = .init(cgImage: cgImage)
                }
            }
        }
    }
}

extension GrapeDefaultViewController : ControllerButtonDelegate {
    func touchBegan(with type: Button.`Type`) {
        switch type {
        case .dpadUp:
            grape.virtualControllerButtonDown(6)
        case .dpadDown:
            grape.virtualControllerButtonDown(7)
        case .dpadLeft:
            grape.virtualControllerButtonDown(5)
        case .dpadRight:
            grape.virtualControllerButtonDown(4)
        case .minus:
            grape.virtualControllerButtonDown(2)
        case .plus:
            grape.virtualControllerButtonDown(3)
        case .a:
            grape.virtualControllerButtonDown(0)
        case .b:
            grape.virtualControllerButtonDown(1)
        case .x:
            grape.virtualControllerButtonDown(10)
        case .y:
            grape.virtualControllerButtonDown(11)
        case .l:
            grape.virtualControllerButtonDown(9)
        case .r:
            grape.virtualControllerButtonDown(8)
        default:
            break
        }
    }
    
    func touchEnded(with type: Button.`Type`) {
        switch type {
        case .dpadUp:
            grape.virtualControllerButtonUp(6)
        case .dpadDown:
            grape.virtualControllerButtonUp(7)
        case .dpadLeft:
            grape.virtualControllerButtonUp(5)
        case .dpadRight:
            grape.virtualControllerButtonUp(4)
        case .minus:
            grape.virtualControllerButtonDown(2)
        case .plus:
            grape.virtualControllerButtonDown(3)
        case .a:
            grape.virtualControllerButtonUp(0)
        case .b:
            grape.virtualControllerButtonUp(1)
        case .x:
            grape.virtualControllerButtonUp(10)
        case .y:
            grape.virtualControllerButtonUp(11)
        case .l:
            grape.virtualControllerButtonUp(9)
        case .r:
            grape.virtualControllerButtonUp(8)
        default:
            break
        }
    }
    
    func touchMoved(with type: Button.`Type`) {}
}

/*
extension GrapeDefaultViewController : MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        guard let game = game as? GrapeManager.Library.Game, let device else {
            return
        }
        
        func draw(_ texture: MTLTexture, _ view: MTKView, _ videoBuffer: UnsafeMutablePointer<UInt32>, _ width: Int, _ height: Int) {
            pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
            
            do {
                pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } catch {
                fatalError("Failed to create pipeline state: \(error)")
            }
            
            func update(_ texture: MTLTexture, _ data: UnsafeMutablePointer<UInt32>, _ width: Int, _ height: Int) {
                texture.replace(region: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0, withBytes: data,
                    bytesPerRow: width * MemoryLayout<UInt32>.stride)
            }
            
            update(texture, videoBuffer, width, height)
            
            // func updateUpscaled(_ data: UnsafeMutablePointer<UInt32>, _ width: Int, _ height: Int) {
            //     let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false)
            //     textureDescriptor.usage = [.renderTarget, .shaderRead]
            //     textureDescriptor.storageMode = .private
            //     upscaledTexture = device.makeTexture(descriptor: textureDescriptor)
            // }
            
            guard let drawable = view.currentDrawable, let commandBuffer = commandQueue.makeCommandBuffer(),
                let renderPassDescriptor = view.currentRenderPassDescriptor else {
                return
            }
            
            // if MTLFXSpatialScalerDescriptor.supportsDevice(device) {
            //     updateUpscaled(videoBuffer, width, height)
            //
            //     let spatialDescriptor = MTLFXSpatialScalerDescriptor()
            //     spatialDescriptor.inputWidth = width
            //     spatialDescriptor.inputHeight = height
            //     spatialDescriptor.outputWidth = width
            //     spatialDescriptor.outputHeight = height
            //     spatialDescriptor.colorTextureFormat = .rgba8Unorm
            //     spatialDescriptor.outputTextureFormat = .rgba8Unorm
            //
            //     guard let scaler = spatialDescriptor.makeSpatialScaler(device: device) else {
            //         return
            //     }
            //
            //     scaler.colorTexture = texture
            //     scaler.outputTexture = upscaledTexture
            //
            //
            //     scaler.encode(commandBuffer: commandBuffer)
            // }
            
            guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                return
            }
            
            renderCommandEncoder.setRenderPipelineState(pipelineState)
            renderCommandEncoder.setFragmentTexture(texture, index: 0)
            // renderCommandEncoder.setFragmentTexture(upscaledTexture, index: 0)
            renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            renderCommandEncoder.endEncoding()
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
        
        let isGBA = game.gameType == .gba
        let upscalingFilter = grape.useUpscalingFilter()
        let upscalingFactor = Int(grape.useUpscalingFactor())
        
        var width = isGBA ? 240 : 256
        var height = isGBA ? 160 : 192
        
        if [0, 1, 2].contains(upscalingFilter) {
            width *= upscalingFactor
            height *= upscalingFactor
        }
        
        let videoBuffer = grape.videoBuffer(isGBA: isGBA)
        
        if let topScreen = topScreen {
            draw(primaryTexture, topScreen, videoBuffer, width, height)
        }
        
        if !isGBA, let bottomScreen = bottomScreen {
            let videoBuffer = videoBuffer.advanced(by: width * height)
            
            draw(secondaryTexture, bottomScreen, videoBuffer, width, height)
        }
    }
}
*/
