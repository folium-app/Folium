//
//  ControllerView.swift
//  Folium
//
//  Created by Jarrod Norwell on 4/6/2024.
//

import Foundation
import UIKit

struct Skin : Codable, Hashable {
    struct Button : Codable, Hashable {
        enum `Type` : String, Codable, Hashable {
            case north = "north", east = "east", south = "south", west = "west"
            case dpadUp = "dpadUp", dpadDown = "dpadDown", dpadLeft = "dpadLeft", dpadRight = "dpadRight"
            case l = "l", zl = "zl", r = "r", zr = "zr"
        }
        
        var vibrateWhenTapped: Bool
        var vibrationStrength: Int 
        
        let x, y: Double
        let width, height: Double
        let type: `Type`
        
        func image(for core: Core) -> UIImage? {
            switch type {
            case .north: .init(systemName: core.isNintendo ? "x.circle.fill" : "triangle.circle.fill")
            case .east: .init(systemName: core.isNintendo ? "a.circle.fill" : "circle.circle.fill")
            case .south: .init(systemName: core.isNintendo ? "b.circle.fill" : "xmark.circle.fill")
            case .west: .init(systemName: core.isNintendo ? "y.circle.fill" : "square.circle.fill")
            case .dpadUp: .init(systemName: "arrowtriangle.up.circle.fill")
            case .dpadDown: .init(systemName: "arrowtriangle.down.circle.fill")
            case .dpadLeft: .init(systemName: "arrowtriangle.left.circle.fill")
            case .dpadRight: .init(systemName: "arrowtriangle.right.circle.fill")
            case .l:
                if #available(iOS 17, *) {
                    .init(systemName: core.isNintendo ? "l.button.roundedbottom.horizontal.fill" : "l1.button.roundedbottom.horizontal.fill")
                } else {
                    .init(systemName: core.isNintendo ? "l.rectangle.roundedbottom.fill" : "l1.rectangle.roundedbottom.fill")
                }
            case .zl:
                if #available(iOS 17, *) {
                    .init(systemName: core.isNintendo ? "zl.button.roundedbottom.horizontal.fill" : "l2.button.roundedbottom.horizontal.fill")
                } else {
                    .init(systemName: core.isNintendo ? "zl.rectangle.roundedbottom.fill" :"l2.rectangle.roundedbottom.fill")
                }
            case .r:
                if #available(iOS 17, *) {
                    .init(systemName: core.isNintendo ? "r.button.roundedbottom.horizontal.fill" : "r1.button.roundedbottom.horizontal.fill")
                } else {
                    .init(systemName: core.isNintendo ? "r.rectangle.roundedbottom.fill" : "r1.rectangle.roundedbottom.fill")
                }
            case .zr:
                if #available(iOS 17, *) {
                    .init(systemName: core.isNintendo ? "zr.button.roundedbottom.horizontal.fill" : "r2.button.roundedbottom.horizontal.fill")
                } else {
                    .init(systemName: core.isNintendo ? "zr.rectangle.roundedbottom.fill" :"r2.rectangle.roundedbottom.fill")
                }
            }
        }
    }
    
    struct Screen : Codable, Hashable {
        let x, y: Double
        let width, height: Double
    }
    
    struct Thumbstick : Codable, Hashable {
        enum `Type` : String, Codable, Hashable {
            case left = "left", right = "right"
        }
        
        let x, y: Double
        let width, height: Double
        let type: `Type`
    }
    
    struct Device : Codable, Hashable {
        enum Orientation : String, Codable, Hashable {
            case portrait = "portrait", landscape = "landscape"
        }
        
        let device: String
        let orientation: Orientation
        
        let buttons: [Button]
        let screens: [Screen]
        let thumbsticks: [Thumbstick]
        
        static func == (lhs: Skin.Device, rhs: Skin.Device) -> Bool {
            lhs.device == rhs.device
        }
    }
    
    let author, description, name: String
    let core: Core
    
    let devices: [Device]
}

var machine: String {
    var utsnameInstance = utsname()
    uname(&utsnameInstance)
    let optionalString: String? = withUnsafePointer(to: &utsnameInstance.machine) {
        $0.withMemoryRebound(to: CChar.self, capacity: 1) {
            ptr in String.init(validatingUTF8: ptr)
        }
    }
    return optionalString ?? "N/A"
}

class ControllerView : PassthroughView {
    var device: Skin.Device
    var delegates: (button: ControllerButtonDelegate, thumbstick: ControllerThumbstickDelegate)
    var skin: Skin
    init(with device: Skin.Device, delegates: (button: ControllerButtonDelegate, thumbstick: ControllerThumbstickDelegate), skin: Skin) {
        self.device = device
        self.delegates = delegates
        self.skin = skin
        super.init(frame: .zero)
        
        device.thumbsticks.forEach { thumbstick in
            let controllerThumbstick = ControllerThumbstick(with: thumbstick, delegate: delegates.thumbstick, skin: skin)
            controllerThumbstick.frame = .init(x: thumbstick.x, y: thumbstick.y, width: thumbstick.width, height: thumbstick.height)
            controllerThumbstick.layer.cornerCurve = .continuous
            controllerThumbstick.layer.cornerRadius = CGFloat(thumbstick.height / 2)
            addSubview(controllerThumbstick)
        }
        
        device.buttons.forEach { button in
            let controllerButton = ControllerButton(with: button, colors: skin.core.newButtonColors[button.type] ?? (.black, .white), delegate: delegates.button, skin: skin)
            controllerButton.frame = .init(x: button.x, y: button.y, width: button.width, height: button.height)
            addSubview(controllerButton)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func orientationChanged(with device: Skin.Device) {
        subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        
        device.thumbsticks.forEach { thumbstick in
            let controllerThumbstick = ControllerThumbstick(with: thumbstick, delegate: delegates.thumbstick, skin: skin)
            controllerThumbstick.frame = .init(x: thumbstick.x, y: thumbstick.y, width: thumbstick.width, height: thumbstick.height)
            controllerThumbstick.layer.cornerCurve = .continuous
            controllerThumbstick.layer.cornerRadius = CGFloat(thumbstick.height / 2)
            addSubview(controllerThumbstick)
        }
        
        device.buttons.forEach { button in
            let controllerButton = ControllerButton(with: button, colors: skin.core.newButtonColors[button.type] ?? (.black, .white), delegate: delegates.button, skin: skin)
            controllerButton.frame = .init(x: button.x, y: button.y, width: button.width, height: button.height)
            addSubview(controllerButton)
        }
    }
}
