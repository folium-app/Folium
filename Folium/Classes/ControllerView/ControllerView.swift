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
        enum `Type` : Int, Codable, Hashable {
            case north, east, south, west
            case dpadUp, dpadDown, dpadLeft, dpadRight
        }
        
        var useCustom: Bool // TODO: (jarrodnorwell) Add support for custom images
        var vibrateWhenTapped: Bool
        var vibrationStrength: Int 
        
        let x, y: Int
        let width, height: Int
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
            }
        }
    }
    
    struct Screen : Codable, Hashable {
        let x, y: Int
        let width, height: Int
    }
    
    struct Device : Codable, Hashable {
        enum Orientation : Int, Codable, Hashable {
            case portrait, landscape
        }
        
        let device: String
        let orientation: Orientation
        
        let buttons: [Button]
        let screens: [Screen]
        
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

class ControllerView : PassthroughView, ControllerButtonDelegate {
    var device: Skin.Device
    var skin: Skin
    init(with device: Skin.Device, skin: Skin) {
        self.device = device
        self.skin = skin
        super.init(frame: .zero)
        
        device.buttons.forEach { button in
            let controllerButton = ControllerButton(with: button, colors: skin.core.newButtonColors[button.type] ?? (.black, .white), delegate: self, skin: skin)
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
        
        device.buttons.forEach { button in
            let controllerButton = ControllerButton(with: button, colors: skin.core.newButtonColors[button.type] ?? (.black, .white), delegate: self, skin: skin)
            controllerButton.frame = .init(x: button.x, y: button.y, width: button.width, height: button.height)
            self.addSubview(controllerButton)
        }
    }
    
    func touchBegan(with type: Skin.Button.`Type`) {
        
    }
    
    func touchEnded(with type: Skin.Button.`Type`) {
        
    }
    
    func touchMoved(with type: Skin.Button.`Type`) {
        
    }
}
