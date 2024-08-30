//
//  ControllerTestEmulationController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 8/8/2024.
//

import Cytrus
import Foundation
import MetalKit
import UIKit

class ControllerTestEmulationController : UIViewController {
    var controllerView: ControllerView? = nil
    
    var skin: Skin
    init(skin: Skin) {
        self.skin = skin
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        skin.orientations.supportedInterfaceOrientations
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        guard let orientation = skin.orientation(for: interfaceOrientation()) else {
            return
        }
        
        controllerView = .init(orientation: orientation, skin: skin, delegates: (self, self))
        guard let controllerView, let screensView = controllerView.screensView else {
            return
        }
        
        controllerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controllerView)
        
        controllerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controllerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        controllerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        controllerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in } completion: { _ in
            let skin = if let url = self.skin.url {
                try? SkinManager.shared.skin(from: url)
            } else {
                self.skin
            }
            
            guard let controllerView = self.controllerView, let skin, let orientation = skin.orientation(for: self.interfaceOrientation()) else {
                return
            }
            
            self.skin = skin
            
            controllerView.updateFrames(for: orientation)
        }
    }
}

// MARK: Button Delegate
extension ControllerTestEmulationController : ControllerButtonDelegate {
    func touchBegan(with type: Button.`Type`) {}
    func touchEnded(with type: Button.`Type`) {}
    func touchMoved(with type: Button.`Type`) {}
}

// MARK: Thumbstick Delegate
extension ControllerTestEmulationController : ControllerThumbstickDelegate {
    func touchBegan(with type: Thumbstick.`Type`, position: (x: Float, y: Float)) {}
    func touchEnded(with type: Thumbstick.`Type`, position: (x: Float, y: Float)) {}
    func touchMoved(with type: Thumbstick.`Type`, position: (x: Float, y: Float)) {}
}
