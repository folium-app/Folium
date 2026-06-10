//
//  GamesController.swift
//  Folium
//
//  Created by Jarrod Norwell on 3/6/2026.
//

import UIKit

class GamesController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController {
            navigationController.navigationBar.prefersLargeTitles = true
        }
        navigationItem.largeTitle = "Games"
        navigationItem.title = navigationItem.largeTitle
        navigationItem.style = .browser
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Test", primaryAction: UIAction { action in
            if let tabBarController: TabController = self.tabBarController as? TabController {
                let oldColor: UIColor? = tabBarController.tabs[.emulationController].viewController?.view.backgroundColor
                
                var colors: [UIColor] = [
                    UIColor.systemRed,
                    UIColor.systemGreen,
                    UIColor.systemBlue,
                    UIColor.systemOrange,
                    UIColor.systemYellow,
                    UIColor.systemPink,
                    UIColor.systemIndigo,
                    UIColor.systemMint,
                    UIColor.systemPurple
                ]
                
                if let oldColor, let found: Int = colors.firstIndex(of: oldColor) {
                    colors.remove(at: found)
                }
                
                let controller: EmulationController = EmulationController()
                controller.view.backgroundColor = colors.randomElement()
                
                tabBarController.switchEmulationController(with: controller)
            }
        })
    }
}
