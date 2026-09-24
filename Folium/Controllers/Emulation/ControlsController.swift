//
//  ControlsController.swift
//  Folium
//
//  Created by Jarrod Norwell on 23/6/2026.
//


import Cherry
import Cytrus
import Durian
import GameController
import Grape
import Kiwi
import Lychee
import Mandarine
import Mango
import Plum
import Tomato

class ControlsController : ScreensController {
    nonisolated func controllerDidConnect(controller: GCController) {}
    nonisolated func controllerDidDisconnect(controller: GCController) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let controller: GCController = GCController.controllers().first {
            controllerDidConnect(controller: controller)
        }
        
        NotificationCenter.default.addObserver(forName: .GCControllerDidConnect, object: nil, queue: .main) { notification in
            guard let controller: GCController = notification.object as? GCController else {
                return
            }
            
            self.controllerDidConnect(controller: controller)
        }
        
        NotificationCenter.default.addObserver(forName: .GCControllerDidDisconnect, object: nil, queue: .main) { notification in
            guard let controller: GCController = notification.object as? GCController else {
                return
            }
            
            self.controllerDidDisconnect(controller: controller)
        }
    }
    
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
    
    // MARK: Durian (WS)
    func press(button: DurianButton, using durianSystem: DurianSystem) {
        durianSystem.press(button: button)
    }
    
    func release(button: DurianButton, using durianSystem: DurianSystem) {
        durianSystem.release(button: button)
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
    
    // MARK: Lychee (SNES)
    func press(button: LycheeButton, using lycheeSystem: LycheeSystem) {
        lycheeSystem.press(button: button)
    }
    
    func release(button: LycheeButton, using lycheeSystem: LycheeSystem) {
        lycheeSystem.release(button: button)
    }
    
    // MARK: Mandarine (PS1)
    nonisolated func press(button: MandarineButton, index: Int32 = 1, using mandarineSystem: MandarineSystem) {
        mandarineSystem.press(button: button, index: index)
    }
    
    nonisolated func release(button: MandarineButton, index: Int32 = 1, using mandarineSystem: MandarineSystem) {
        mandarineSystem.release(button: button, index: index)
    }
    
    // MARK: Mango (NES)
    func press(button: MangoButton, using mangoSystem: MangoSystem) {
        mangoSystem.press(button: button)
    }
    
    func release(button: MangoButton, using mangoSystem: MangoSystem) {
        mangoSystem.release(button: button)
    }
    
    
    // MARK: Plum (GEN/MD)
    nonisolated func press(button: PlumButton, index: Int32 = 0, using plumSystem: PlumSystem) {
        plumSystem.press(button: button, index: index)
    }
    
    nonisolated func release(button: PlumButton, index: Int32 = 0, using plumSystem: PlumSystem) {
        plumSystem.release(button: button, index: index)
    }
    
    
    // MARK: Tomato (GBA)
    func press(button: TomatoButton, using tomatoSystem: TomatoSystem) {
        tomatoSystem.press(button: button)
    }
    
    func release(button: TomatoButton, using tomatoSystem: TomatoSystem) {
        tomatoSystem.release(button: button)
    }
}
