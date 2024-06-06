//
//  EmulationVirtualControllerController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 13/3/2024.
//

import Foundation
import GameController
import UIKit

class EmulationVirtualControllerController : UIViewController, VirtualControllerButtonDelegate, VirtualControllerThumbstickDelegate {
    var virtualControllerView: VirtualControllerView!
    
    fileprivate var lastTappedDate: Date = .now
    fileprivate var isDraggingThumbstick: Bool = false
    
    var core: Core
    var game: AnyHashable? = nil
    init(_ core: Core, _ game: AnyHashable? = nil) {
        self.core = core
        self.game = game
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        virtualControllerView = .init(core, self, self)
        view.addSubview(virtualControllerView)
        view.addConstraints([
            virtualControllerView.topAnchor.constraint(equalTo: view.topAnchor),
            virtualControllerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            virtualControllerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            virtualControllerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let seconds = Date.now.timeIntervalSince(self.lastTappedDate)
            if !self.isDraggingThumbstick {
                seconds > 5 ? self.virtualControllerView.fade() : self.virtualControllerView.unfade()
            }
        }
        
        NotificationCenter.default.addObserver(forName: .init(NSNotification.Name.GCControllerDidConnect), object: nil, queue: .main, using: controllerDidConnect)
        NotificationCenter.default.addObserver(forName: .init(NSNotification.Name.GCControllerDidDisconnect), object: nil, queue: .main, using: controllerDidDisconnect)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.GCControllerDidConnect, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.GCControllerDidDisconnect, object: nil)
    }
    
    func controllerDidConnect(_ notification: Notification) {
        guard let controller = notification.object as? GCController else {
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            self.virtualControllerView.alpha = 0
        }
    }
    
    func controllerDidDisconnect(_ notification: Notification) {
        guard let controller = notification.object as? GCController else {
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            self.virtualControllerView.alpha = 1
        }
    }
    
    func touchDown(_ buttonType: VirtualControllerButton.ButtonType) {
        lastTappedDate = .now
        virtualControllerView.unfade()
    }
    
    func touchUpInside(_ buttonType: VirtualControllerButton.ButtonType) {
        lastTappedDate = .now
    }
    
    func touchDown(_ thumbstickType: VirtualControllerThumbstick.ThumbstickType, _ location: (x: Float, y: Float)) {
        isDraggingThumbstick = true
        virtualControllerView.fade()
    }
    
    func touchDragInside(_ thumbstickType: VirtualControllerThumbstick.ThumbstickType, _ location: (x: Float, y: Float)) {}
    
    func touchUpInside(_ thumbstickType: VirtualControllerThumbstick.ThumbstickType, _ location: (x: Float, y: Float)) {
        isDraggingThumbstick = false
        lastTappedDate = .now
        virtualControllerView.unfade()
    }
}
