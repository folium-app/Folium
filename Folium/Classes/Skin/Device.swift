//
//  Device.swift
//  Folium
//
//  Created by Jarrod Norwell on 13/6/2024.
//

import Foundation

struct Device : Codable, Hashable {
    let device: String
    let orientation: Orientation
    
    var alpha: CGFloat? = 1
    
    var backgroundImageName: String?
    
    let buttons: [Button]
    let screens: [Screen]
    let thumbsticks: [Thumbstick]
    
    static func == (lhs: Device, rhs: Device) -> Bool {
        lhs.device == rhs.device
    }
}
