//
//  ControlsController.swift
//  Folium
//
//  Created by Jarrod Norwell on 23/6/2026.
//


import Cherry
import Cytrus
import Grape
import Kiwi
import Mandarine
import Tomato

class ControlsController : ScreensController {
    // MARK: Cherry (CV)
    nonisolated func press(button: CherryButton, index: Int32 = 0, using cherrySystem: CherrySystem) {
        cherrySystem.press(button: button, index: index)
    }
    
    nonisolated func release(button: CherryButton, index: Int32 = 0, using cherrySystem: CherrySystem) {
        cherrySystem.release(button: button, index: index)
    }
    
    // MARK: Cytrus (3DS)
    func press(button: CytrusButton, using cytrusSystem: CytrusSystem) {
        cytrusSystem.press(button: button)
    }
    
    func release(button: CytrusButton, using cytrusSystem: CytrusSystem) {
        cytrusSystem.release(button: button)
    }
    
    func move(thumbstick: Int32, x: Float, y: Float, using cytrusSystem: CytrusSystem) {
        cytrusSystem.moveThumbstick(with: thumbstick, x: x, y: y)
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
