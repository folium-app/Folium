//
//  Skin.swift
//  Folium
//
//  Created by Jarrod Norwell on 13/6/2024.
//

import Foundation
import UIKit

struct Author : Codable, Hashable {
    let name: String
    let socials: [Social]
}

struct Skin : Codable, Hashable {
    let author: Author
    let core: Core
    let orientations: Orientations
    let title: String
    
    var debugging: Bool? = false
    
    var url: URL? = nil
    
    func orientation(for orientation: UIInterfaceOrientation) -> Orientation? {
        switch orientation {
        case .unknown:
            orientations.portrait
        case .portrait:
            orientations.portrait
        case .portraitUpsideDown:
            orientations.portraitUpsideDown
        case .landscapeLeft:
            orientations.landscapeLeft
        case .landscapeRight:
            orientations.landscapeRight
        @unknown default:
            orientations.portrait
        }
    }
    
    func skinSupportsCurrentDevice() -> Bool {
        orientations.supportedDevices.contains(where: { $0.rawValue == machine })
    }
}
