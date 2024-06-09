//
//  CytrusDefaultViewController.swift
//  Folium
//
//  Created by Jarrod Norwell on 9/6/2024.
//

import Foundation
import MetalKit
import UIKit

class CytrusDefaultViewController : UIViewController {
    fileprivate var controllerView: ControllerView!
    fileprivate var skin: Skin
    
    init(with skin: Skin) {
        self.skin = skin
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        guard let device = skin.devices.first(where: { $0.device == machine && $0.orientation == orientationForCurrentOrientation() }) else {
            return
        }
        
        guard let screen = device.screens.first else {
            return
        }
        
        let metalView = MTKView(frame: .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height), device: MTLCreateSystemDefaultDevice())
        view.addSubview(metalView)
        
        controllerView = .init(with: device, skin: skin)
        controllerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controllerView)
        
        controllerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        controllerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        controllerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        controllerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
            guard let device = self.skin.devices.first(where: { $0.device == machine && $0.orientation == self.orientationForCurrentOrientation() }) else {
                return
            }
            
            guard let screen = device.screens.first else {
                return
            }
            
            metalView.frame = .init(x: screen.x, y: screen.y, width: screen.width, height: screen.height)
            metalView.layoutIfNeeded()
            
            self.controllerView.orientationChanged(with: device)
        }
    }
    
    func orientationForCurrentOrientation() -> Skin.Device.Orientation {
        switch UIApplication.shared.statusBarOrientation {
        case .unknown, .portrait, .portraitUpsideDown:
            .portrait
        case .landscapeLeft, .landscapeRight:
            .landscape
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let orientations = skin.devices.reduce(into: [Skin.Device.Orientation](), { $0.append($1.orientation) })
        
        let containsPortrait = orientations.contains(.portrait)
        let containsLandscape = orientations.contains(.landscape)
        
        if containsPortrait && containsLandscape {
            return [.all]
        } else if containsPortrait {
            return [.portrait, .portraitUpsideDown]
        } else if containsLandscape {
            return [.landscape]
        } else {
            return [.all]
        }
    }
}
