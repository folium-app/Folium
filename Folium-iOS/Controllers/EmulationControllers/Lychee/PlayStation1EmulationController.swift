//
//  PlayStation1EmulationController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 29/7/2024.
//

import Foundation
import Lychee
import UIKit
import GameController

class PlayStation1EmulationController : UIViewController {
    var controllerView: ControllerView? = nil
    var imageView: UIImageView? = nil
    
    var game: PlayStation1Game
    var skin: Skin
    init(game: PlayStation1Game, skin: Skin) {
        self.game = game
        self.skin = skin
        super.init(nibName: nil, bundle: nil)
        Lychee.shared.insertCartridge(from: game.fileDetails.url)
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
        
        Thread.detachNewThread(step)
        Lychee.shared.buffer { buffer in
            Task {
                let width = Lychee.shared.size().0
                let height = Lychee.shared.size().1
                if Lychee.shared.displayMode() == 0 {
                    if let image = self.image(from: self.convertBGR555toRGB888(pointer: buffer, count: 1024 * 512 * MemoryLayout<UInt16>.size), with: 1024, and: 512), let cgImage = image.cgImage,
                       let cropped = cgImage.cropping(to: .init(x: 0, y: 0, width: Int(width), height: Int(height))) {
                        imageView.image = .init(cgImage: cropped)
                    }
                } else {
                    if let image = self.image(from: self.convertBGR555toRGB888(pointer: buffer, count: 1024 * 512 * MemoryLayout<UInt16>.size), with: 1024, and: 512), let cgImage = image.cgImage,
                       let cropped = cgImage.cropping(to: .init(x: 0, y: 0, width: Int(width), height: Int(height))) {
                        imageView.image = .init(cgImage: cropped)
                    }
                }
            }
        }
        
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
                    self.touchBegan(with: .a)
                } else {
                    self.touchEnded(with: .a)
                }
            }
            
            extendedGamepad.buttonB.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .b)
                } else {
                    self.touchEnded(with: .b)
                }
            }
            
            extendedGamepad.buttonX.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .x)
                } else {
                    self.touchEnded(with: .x)
                }
            }
            
            extendedGamepad.buttonY.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .y)
                } else {
                    self.touchEnded(with: .y)
                }
            }
            
            extendedGamepad.dpad.up.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .dpadUp)
                } else {
                    self.touchEnded(with: .dpadUp)
                }
            }
            
            extendedGamepad.dpad.down.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .dpadDown)
                } else {
                    self.touchEnded(with: .dpadDown)
                }
            }
            
            extendedGamepad.dpad.left.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .dpadLeft)
                } else {
                    self.touchEnded(with: .dpadLeft)
                }
            }
            
            extendedGamepad.dpad.right.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .dpadRight)
                } else {
                    self.touchEnded(with: .dpadRight)
                }
            }
            
            extendedGamepad.leftShoulder.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .l)
                } else {
                    self.touchEnded(with: .l)
                }
            }
            
            extendedGamepad.rightShoulder.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .r)
                } else {
                    self.touchEnded(with: .r)
                }
            }
            
            extendedGamepad.leftTrigger.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .zl)
                } else {
                    self.touchEnded(with: .zl)
                }
            }
            
            extendedGamepad.rightTrigger.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .zr)
                } else {
                    self.touchEnded(with: .zr)
                }
            }
            
            extendedGamepad.buttonOptions?.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .minus)
                } else {
                    self.touchEnded(with: .minus)
                }
            }
            
            extendedGamepad.buttonMenu.pressedChangedHandler = { element, value, pressed in
                if pressed {
                    self.touchBegan(with: .plus)
                } else {
                    self.touchEnded(with: .plus)
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name.GCControllerDidDisconnect, object: nil, queue: .main) { _ in
            if let controllerView = self.controllerView {
                controllerView.show()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in } completion: { _ in
            let skin = if let url = self.skin.url {
                try? SkinManager.shared.skin(from: url)
            } else {
                lycheeSkin
            }
            
            guard let skin, let imageView = self.imageView, let controllerView = self.controllerView else {
                return
            }
            
            self.skin = skin
            
            guard let orientation = skin.orientation(for: self.interfaceOrientation()) else {
                return
            }
            
            controllerView.updateFrames(for: orientation, controllerConnected: GCController.controllers().count > 0)
            
            imageView.frame = if !orientation.screens.isEmpty, let screen = orientation.screens.first {
                .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height)
            } else {
                self.view.bounds
            }
        }
    }
    
    @objc func step() {
        while true {
            Lychee.shared.step()
        }
    }
    
    func rgb24(from pointer: UnsafeMutablePointer<UInt16>, width: Int, height: Int) -> CGImage? {
        let bytesPerPixel = 3
            let totalBytes = width * height * bytesPerPixel
            
            // Allocate a new buffer for the RGB24 data
            let rgbBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: totalBytes)
            defer { rgbBuffer.deallocate() }
            
            for i in 0..<(width * height) {
                // Read RGB24 data from the UInt16 pointer
                let rgb16 = pointer[i]
                let r = UInt8((rgb16 >> 8) & 0xFF)
                let g = UInt8((rgb16 >> 4) & 0xFF)
                let b = UInt8((rgb16 >> 0) & 0xFF)
                
                // Write to the RGB24 buffer
                rgbBuffer[i * 3 + 0] = r
                rgbBuffer[i * 3 + 1] = g
                rgbBuffer[i * 3 + 2] = b
            }
            
            // Create a CGImage from the RGB24 buffer
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bytesPerRow = width * bytesPerPixel
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
            
            guard let dataProvider = CGDataProvider(data: Data(
                bytesNoCopy: rgbBuffer,
                count: totalBytes,
                deallocator: .none
            ) as CFData) else {
                return nil
            }
            
            return CGImage(
                width: width,
                height: height,
                bitsPerComponent: 8,
                bitsPerPixel: 24,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: bitmapInfo,
                provider: dataProvider,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent
            )
    }
    
    func image(from buffer: [UInt32], with width: Int = 640, and height: Int = 480) -> UIImage? {
        let bitsPerComponent = 8
        let bytesPerPixel = 4 // 32 bits per pixel (RGB32)
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow
        
        let buffer = Data(bytes: buffer, count: totalBytes)
        
        // Create a CGDataProvider from the Data object.
        guard let provider = CGDataProvider(data: buffer as CFData) else {
            return nil
        }
        
        // Define the color space. BGR555 is typically treated as RGB.
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Create a bitmap CGImage.
        guard let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        ) else {
            return nil
        }
        
        return .init(cgImage: cgImage)
    }
    
    func convertRGB24ToCGImage(rgb24Pointer: UnsafeMutablePointer<UInt16>, width: Int, height: Int) -> CGImage? {
        // Allocate space for a byte array to hold the pixel data in RGB888 format
        let pixelCount = width * height
        var rgb888Data = [UInt8](repeating: 0, count: pixelCount * 3) // 3 bytes per pixel
        
        // Convert each RGB24 pixel (16-bit) into RGB888 format (8-bit per channel)
        for i in 0..<pixelCount {
            let rgb24Pixel = rgb24Pointer[i]
            
            // Extract the RGB channels from the 16-bit RGB24 value (stored as 5-bit for each channel)
            let red = (rgb24Pixel >> 11) & 0x1F
            let green = (rgb24Pixel >> 5) & 0x3F
            let blue = rgb24Pixel & 0x1F
            
            // Expand 5-bit to 8-bit (by shifting left and adding the higher bits)
            rgb888Data[i * 3] = UInt8((red << 3) | (red >> 2)) // Red
            rgb888Data[i * 3 + 1] = UInt8((green << 2) | (green >> 4)) // Green
            rgb888Data[i * 3 + 2] = UInt8((blue << 3) | (blue >> 2)) // Blue
        }

        // Create a data provider from the RGB888 data
        let dataProvider = CGDataProvider(data: NSData(bytes: &rgb888Data, length: rgb888Data.count))
        
        // Create the CGImage from the provider
        let cgImage = CGImage(width: width,
                              height: height,
                              bitsPerComponent: 8,
                              bitsPerPixel: 24,
                              bytesPerRow: width * 3,
                              space: CGColorSpaceCreateDeviceRGB(),
                              bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
                              provider: dataProvider!,
                              decode: nil,
                              shouldInterpolate: true,
                              intent: .defaultIntent)
        
        return cgImage
    }
    
    
    func expand5to8(_ value: UInt8) -> UInt8 {
        return (value << 3) | (value >> 2) // Expand from 5 bits to 8 bits
    }

    // Convert a single BGR555 value to RGB888
    func bgr555ToRgb888(bgr555: UInt16) -> UInt32 {
        // Extract the 5-bit channels for Blue, Green, Red
        let blue = UInt8(bgr555 & 0x1F)      // Extract Blue (5 bits)
        let green = UInt8((bgr555 >> 5) & 0x1F) // Extract Green (5 bits)
        let red = UInt8((bgr555 >> 10) & 0x1F)  // Extract Red (5 bits)

        // Expand the channels to 8 bits
        let expandedBlue = expand5to8(blue)
        let expandedGreen = expand5to8(green)
        let expandedRed = expand5to8(red)

        // Combine into RGB888 format (32-bit)
        let rgb888 = (UInt32(expandedRed) << 16) | (UInt32(expandedGreen) << 8) | UInt32(expandedBlue)
        return rgb888
    }

    // Convert an UnsafeMutablePointer<UInt16> array of BGR555 pixels to RGB888
    func convertBGR555toRGB888(pointer: UnsafeMutablePointer<UInt16>, count: Int) -> [UInt32] {
        var rgb888Data = [UInt32](repeating: 0, count: count)

        // Iterate through the pointer data and convert each BGR555 pixel to RGB888
        for i in 0..<count {
            let bgr555Pixel = pointer[i]
            rgb888Data[i] = bgr555ToRgb888(bgr555: bgr555Pixel)
        }

        return rgb888Data
    }
}



// MARK: Button Delegate
extension PlayStation1EmulationController : ControllerButtonDelegate {
    func touchBegan(with type: Button.`Type`) {
        switch type {
        case .a:
            Lychee.shared.input(0, .circle, true)
        case .b:
            Lychee.shared.input(0, .cross, true)
        case .x:
            Lychee.shared.input(0, .triangle, true)
        case .y:
            Lychee.shared.input(0, .square, true)
        case .dpadUp:
            Lychee.shared.input(0, .dpadUp, true)
        case .dpadDown:
            Lychee.shared.input(0, .dpadDown, true)
        case .dpadLeft:
            Lychee.shared.input(0, .dpadLeft, true)
        case .dpadRight:
            Lychee.shared.input(0, .dpadRight, true)
        case .minus:
            Lychee.shared.input(0, .select, true)
        case .plus:
            Lychee.shared.input(0, .start, true)
        case .l:
            Lychee.shared.input(0, .l1, true)
        case .r:
            Lychee.shared.input(0, .r1, true)
        case .zl:
            Lychee.shared.input(0, .l2, true)
        case .zr:
            Lychee.shared.input(0, .r2, true)
        default:
            break
        }
    }
    
    func touchEnded(with type: Button.`Type`) {
        switch type {
        case .a:
            Lychee.shared.input(0, .circle, false)
        case .b:
            Lychee.shared.input(0, .cross, false)
        case .x:
            Lychee.shared.input(0, .triangle, false)
        case .y:
            Lychee.shared.input(0, .square, false)
        case .dpadUp:
            Lychee.shared.input(0, .dpadUp, false)
        case .dpadDown:
            Lychee.shared.input(0, .dpadDown, false)
        case .dpadLeft:
            Lychee.shared.input(0, .dpadLeft, false)
        case .dpadRight:
            Lychee.shared.input(0, .dpadRight, false)
        case .minus:
            Lychee.shared.input(0, .select, false)
        case .plus:
            Lychee.shared.input(0, .start, false)
        case .l:
            Lychee.shared.input(0, .l1, false)
        case .r:
            Lychee.shared.input(0, .r1, false)
        case .zl:
            Lychee.shared.input(0, .l2, false)
        case .zr:
            Lychee.shared.input(0, .r2, false)
        default:
            break
        }
    }
    
    func touchMoved(with type: Button.`Type`) {}
}

// MARK: Thumbstick Delegate
extension PlayStation1EmulationController : ControllerThumbstickDelegate {
    func touchBegan(with type: Thumbstick.`Type`, position: (x: Float, y: Float)) {}
    
    func touchEnded(with type: Thumbstick.`Type`, position: (x: Float, y: Float)) {}
    
    func touchMoved(with type: Thumbstick.`Type`, position: (x: Float, y: Float)) {}
}
