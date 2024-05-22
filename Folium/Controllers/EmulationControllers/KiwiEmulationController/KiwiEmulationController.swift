//
//  KiwiEmulationController.swift
//  Folium
//
//  Created by Jarrod Norwell on 20/5/2024.
//

import Foundation
import GameController
import Kiwi
import Metal
// import MetalFX
import MetalKit
import SDL2
import UIKit

class KiwiEmulationController : EmulationScreensController {
    fileprivate var kiwi = Kiwi.shared
    
    fileprivate var displayLink: CADisplayLink!
    fileprivate var isRunning: Bool = false
    
    fileprivate var commandQueue: MTLCommandQueue!
    fileprivate var pipelineState: MTLRenderPipelineState!
    fileprivate var texture, upscaledTexture: MTLTexture!
    
    override init(_ core: Core, _ game: AnyHashable? = nil) {
        super.init(core, game)
        guard let game = game as? KiwiManager.Library.Game else {
            return
        }
        
        kiwi.insert(game: game.fileDetails.url)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        displayLink = .init(target: self, selector: #selector(step))
        displayLink.preferredFrameRateRange = .init(minimum: 30, maximum: 60)
        
        NotificationCenter.default.addObserver(forName: .init("sceneDidChange"), object: nil, queue: .main) { notification in
            guard let userInfo = notification.userInfo, let state = userInfo["state"] as? Int else {
                return
            }
            
            switch state {
            case 0:
                self.isRunning = false
            case 1:
                self.isRunning = true
            default:
                break
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isRunning {
            isRunning = true
            
            displayLink.add(to: .main, forMode: .common)
        }
    }
    
    @objc fileprivate func step() {
        if isRunning {
            kiwi.step()
        }
    }
    
    // MARK: Physical Controller Delegates
    override func controllerDidConnect(_ notification: Notification) {
        super.controllerDidConnect(notification)
        guard let controller = notification.object as? GCController, let extendedGamepad = controller.extendedGamepad else {
            return
        }
        
        extendedGamepad.dpad.up.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.dpadUp) : self.touchUpInside(.dpadUp)
        }
        
        extendedGamepad.dpad.down.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.dpadDown) : self.touchUpInside(.dpadDown)
        }
        
        extendedGamepad.dpad.left.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.dpadLeft) : self.touchUpInside(.dpadLeft)
        }
        
        extendedGamepad.dpad.right.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.dpadRight) : self.touchUpInside(.dpadRight)
        }
        
        extendedGamepad.buttonOptions?.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.minus) : self.touchUpInside(.minus)
        }
        
        extendedGamepad.buttonMenu.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.plus) : self.touchUpInside(.plus)
        }
        
        extendedGamepad.buttonA.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.a) : self.touchUpInside(.a)
        }
        
        extendedGamepad.buttonB.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.b) : self.touchUpInside(.b)
        }
        
        extendedGamepad.buttonX.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.x) : self.touchUpInside(.x)
        }
        
        extendedGamepad.buttonY.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.y) : self.touchUpInside(.y)
        }
        
        extendedGamepad.leftShoulder.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.l) : self.touchUpInside(.l)
        }
        
        extendedGamepad.rightShoulder.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.r) : self.touchUpInside(.r)
        }
    }
    
    // MARK: Virtual Controller Delegates
    override func touchDown(_ buttonType: VirtualControllerButton.ButtonType) {
        super.touchDown(buttonType)
        
    }
    
    override func touchUpInside(_ buttonType: VirtualControllerButton.ButtonType) {
        super.touchUpInside(buttonType)
        
    }
}

extension KiwiEmulationController {
    override func draw(in view: MTKView) {
        guard let device, let primaryScreen = primaryScreen as? MTKView,
        let primaryBlurredScreen = primaryBlurredScreen as? MTKView else {
            return
        }
        
        guard let defaultLibrary = device.makeDefaultLibrary() else {
            return
        }
        
        let vertexFunction = defaultLibrary.makeFunction(name: "vertexShader")
        let fragmentFunction = defaultLibrary.makeFunction(name: "fragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        commandQueue = device.makeCommandQueue()
        
        func draw(_ view: MTKView, _ videoBuffer: UnsafeMutablePointer<UInt32>, _ width: Int, _ height: Int) {
            pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
            
            do {
                pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } catch {
                fatalError("Failed to create pipeline state: \(error)")
            }
            
            let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false)
            textureDescriptor.usage = [.renderTarget, .shaderRead]
            texture = device.makeTexture(descriptor: textureDescriptor)
            
            func update(_ data: UnsafeMutablePointer<UInt32>, _ width: Int, _ height: Int) {
                texture.replace(region: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0, withBytes: data,
                    bytesPerRow: width * MemoryLayout<UInt32>.stride)
            }
            
            update(videoBuffer, width, height)
            
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
        
        let upscalingFilter = kiwi.useUpscalingFilter()
        let upscalingFactor = Int(kiwi.useUpscalingFactor())
        
        var width = 256
        var height = 240
        
        if [0, 1].contains(upscalingFilter) {
            width *= upscalingFactor
            height *= upscalingFactor
        }
        
        let buffer = kiwi.videoBuffer()
        
        draw(primaryScreen, buffer, width, height)
        draw(primaryBlurredScreen, buffer, width, height)
    }
}
