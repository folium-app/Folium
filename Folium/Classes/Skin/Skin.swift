//
//  Skin.swift
//  Folium
//
//  Created by Jarrod Norwell on 13/6/2024.
//

import Foundation
import UIKit

struct Skin : Codable, Hashable {
    let author, description, name: String
    let core: Core
    
    let devices: [Device]
    
    var isDebug: Bool? = false
    
    var path: URL? = nil
    
    func supportedOrientations() -> UIInterfaceOrientationMask {
        let orientations = devices.reduce(into: [Orientation](), { $0.append($1.orientation) })
        
        let containsPortrait = orientations.contains(.portrait)
        let containsLandscape = orientations.contains(.landscape)
        
        if containsPortrait && containsLandscape {
            return [.all]
        } else if containsPortrait {
            return [.portrait, .portraitUpsideDown]
        } else if containsLandscape {
            return [.landscape]
        } else {
            return [.portrait, .portraitUpsideDown]
        }
    }
}
