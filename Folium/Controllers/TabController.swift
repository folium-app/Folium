//
//  TabController.swift
//  Folium
//
//  Created by Jarrod Norwell on 3/6/2026.
//

import UIKit

class TabController : UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        tabs = [
            UITab(title: "Games", image: UIImage(systemName: "opticaldisc.fill"), identifier: "games") { tab in
                UINavigationController(rootViewController: GamesController())
            },
            UITab(title: "Emulation", image: UIImage(systemName: "gamecontroller.fill"), identifier: "emulation") { tab in
                EmulationController()
            },
            UITab(title: "Settings", image: UIImage(systemName: "gearshape.fill"), identifier: "settings") { tab in
                UINavigationController(rootViewController: SettingsController())
            }
        ]
    }
    
    func switchEmulationController(with controller: UIViewController) {
        var old = tabs
        old[.emulationController] = UITab(title: "Emulation", image: UIImage(systemName: "gamecontroller.fill"), identifier: "emulation") { tab in
            controller
        }
        
        old[.emulationController].badgeValue = "1"
        
        tabs = old
    }
}
