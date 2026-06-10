//
//  EmulationController.swift
//  Folium
//
//  Created by Jarrod Norwell on 3/6/2026.
//

import UIKit

class EmulationController : UIViewController {
    override var prefersStatusBarHidden: Bool { true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarItem.badgeValue = nil
    }
}
