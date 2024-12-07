//
//  Orientation.swift
//  Folium
//
//  Created by Jarrod Norwell on 13/6/2024.
//

import Foundation
import UIKit

struct Orientation : Codable, Hashable {
    // TODO:
    var backgroundImageName: String? = nil
    var sharedAlpha: Double? = 1
    
    let buttons: [Button]
    var screens: [Screen]
    let thumbsticks: [Thumbstick]
}

struct Orientations : Codable, Hashable {
    let portrait: Orientation
    var portraitUpsideDown: Orientation? = nil
    var landscapeLeft: Orientation? = nil, landscapeRight: Orientation? = nil
    
    let supportedDevices: [Machine] // iPhone16,2
    
    var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        var mask = UIInterfaceOrientationMask.portrait
        
        if portraitUpsideDown != nil {
            mask.insert(.portraitUpsideDown)
        }
        
        if landscapeLeft != nil {
            mask.insert(.landscapeLeft)
        }
        
        if landscapeRight != nil {
            mask.insert(.landscapeRight)
        }
        
        return mask
    }
}
