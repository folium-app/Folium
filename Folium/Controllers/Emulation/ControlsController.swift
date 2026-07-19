//
//  ControlsController.swift
//  Folium
//
//  Created by Jarrod Norwell on 23/6/2026.
//

import Cytrus
import Grape
import Kiwi
import Mandarine
import Tomato

class ControlsController : ScreensController {
    // MARK: Cytrus (3DS)
    func press(button: CytrusButton, using cytrusSystem: CytrusSystem) {
        cytrusSystem.press(button: button)
    }
    
    func release(button: CytrusButton, using cytrusSystem: CytrusSystem) {
        cytrusSystem.release(button: button)
    }
    
    
    // MARK: Grape (DS/DSi)
    func press(button: GrapeButton, using grapeSystem: GrapeSystem) {
        grapeSystem.press(button: button)
    }
    
    func release(button: GrapeButton, using grapeSystem: GrapeSystem) {
        grapeSystem.release(button: button)
    }
    
    
    // MARK: Kiwi (GB/GBC)
    func press(button: KiwiButton, using kiwiSystem: KiwiSystem) {
        kiwiSystem.press(button: button)
    }
    
    func release(button: KiwiButton, using kiwiSystem: KiwiSystem) {
        kiwiSystem.release(button: button)
    }
    
    
    // MARK: Mandarine (PS1)
    nonisolated func press(button: MandarineButton, index: Int32 = 1, using mandarineSystem: MandarineSystem) {
        mandarineSystem.press(button: button, index: index)
    }
    
    nonisolated func release(button: MandarineButton, index: Int32 = 1, using mandarineSystem: MandarineSystem) {
        mandarineSystem.release(button: button, index: index)
    }
    
    
    // MARK: Tomato (GBA)
    func press(button: TomatoButton, using tomatoSystem: TomatoSystem) {
        tomatoSystem.press(button: button)
    }
    
    func release(button: TomatoButton, using tomatoSystem: TomatoSystem) {
        tomatoSystem.release(button: button)
    }
}
