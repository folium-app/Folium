//
//  ControllerView.swift
//  Folium
//
//  Created by Jarrod Norwell on 4/6/2024.
//

import Foundation
import UIKit

struct Skin : Codable {
    struct Button : Codable {
        let origin: CGPoint
        let size: CGSize
        let type: VirtualControllerButton.ButtonType
    }
    
    struct Screen : Codable {
        let origin: CGPoint
        let size: CGSize
    }
    
    struct Device : Codable {
        enum Orientation : Int, Codable {
            case portrait, landscape
        }
        
        let device: String
        let orientation: Orientation
        
        let buttons: [Button]
        let screens: [Screen]
    }
    
    let author, description, name: String
    let core: Core
    
    let devices: [Device]
}

class ControllerView : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        _ = Skin(author: "Antique", description: "A basic skin for Game Boy Advance", name: "GBA Skin", core: .grape, devices: [
            .init(device: "iPhone16,2", orientation: .portrait, buttons: [
                .init(origin: .init(x: 100, y: 100), size: .init(width: 60, height: 60), type: .a)
            ], screens: [
                .init(origin: .init(x: 0, y: 0), size: .init(width: 0, height: 0))
            ]),
            .init(device: "iPhone16,2", orientation: .landscape, buttons: [
                .init(origin: .init(x: 100, y: 100), size: .init(width: 60, height: 60), type: .a)
            ], screens: [
                .init(origin: .init(x: 0, y: 0), size: .init(width: 0, height: 0))
            ])
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
