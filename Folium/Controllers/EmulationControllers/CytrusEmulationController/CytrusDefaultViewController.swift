//
//  CytrusDefaultViewController.swift
//  Folium
//
//  Created by Jarrod Norwell on 9/6/2024.
//

#if canImport(Cytrus)

import Cytrus
import Foundation
import GameController
import MetalKit
import UIKit

class CytrusDefaultViewController : UIViewController {
    var button: UIButton!
    var controllerView: ControllerView!
    var metalView: MTKView!
    
    let cytrus: Cytrus = .shared
    fileprivate var isRunning: Bool = false
    fileprivate var bootHomeMenu: Bool = false
    
    var game: AnyHashableSendable
    var skin: Skin
    init(with game: AnyHashableSendable, skin: Skin, _ bootHomeMenu: Bool = false) {
        self.game = game
        self.skin = skin
        self.bootHomeMenu = bootHomeMenu
        super.init(nibName: nil, bundle: nil)
        cytrus.getVulkanLibrary()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        addSubviews()
        addNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isRunning {
            isRunning = true
            
            Thread.setThreadPriority(1.0)
            Thread.detachNewThread(run)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        skin.supportedOrientations()
    }
    
    @objc func run() {
        guard let game = game as? CytrusManager.Library.Game else {
            return
        }
        
        bootHomeMenu ? cytrus.bootHomeMenu() : cytrus.run(game.fileDetails.url)
    }
}

#endif
