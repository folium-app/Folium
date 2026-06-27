//
//  ControlsController.swift
//  Folium
//
//  Created by Jarrod Norwell on 23/6/2026.
//

import ConstraintKit
import UIKit

import Grape
import Mandarine
import Tomato

class ControlsController : ScreensController {
    func press(button: GrapeButton, using grapeSystem: GrapeSystem) {
        grapeSystem.press(button: button)
    }
    
    func release(button: GrapeButton, using grapeSystem: GrapeSystem) {
        grapeSystem.release(button: button)
    }
    
    func press(button: MandarineButton, using mandarineSystem: MandarineSystem) {
        mandarineSystem.press(button: button)
    }
    
    func release(button: MandarineButton, using mandarineSystem: MandarineSystem) {
        mandarineSystem.release(button: button)
    }
    
    func press(button: TomatoButton, using tomatoSystem: TomatoSystem) {
        tomatoSystem.press(button: button)
    }
    
    func release(button: TomatoButton, using tomatoSystem: TomatoSystem) {
        tomatoSystem.release(button: button)
    }
}
