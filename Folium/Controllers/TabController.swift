//
//  TabController.swift
//  Folium
//
//  Created by Jarrod Norwell on 3/6/2026.
//

import UIKit

class TabController : UITabBarController {
    var game: Game? = nil
    
    let gamesManager: GamesManager
    
    init(gamesManager: GamesManager) {
        self.gamesManager = gamesManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        tabs = [
            UITab(title: "Games", image: UIImage(systemName: "opticaldisc.fill"), identifier: "games") { tab in
                UINavigationController(rootViewController: GamesController(collectionViewLayout: LayoutManager.shared.library))
            },
            UITab(title: "Emulation", image: UIImage(systemName: "gamecontroller.fill"), identifier: "emulation") { tab in
                NoEmulationController()
            },
            UITab(title: "Settings", image: UIImage(systemName: "gearshape.fill"), identifier: "settings") { tab in
                UINavigationController(rootViewController: SettingsController(collectionViewLayout: UICollectionViewLayout()))
            }
        ]
    }
    
    func switchEmulationController(with controller: UIViewController) {
        var old: [UITab] = tabs
        old[.emulationController] = UITab(title: "Emulation", image: UIImage(systemName: "gamecontroller.fill"), identifier: "emulation") { tab in
            controller
        }
        
        if controller is ScreensController {
            old[.emulationController].badgeValue = "1"
        }
        
        tabs = old
    }
    
    func switchSettingsSnapshot(for selectedSnapshot: SelectedSnapshot) {
        if let tab: UITab = tabs.last {
            if let navigationController: UINavigationController = tab.viewController as? UINavigationController {
                if let settingsController: SettingsController = navigationController.viewControllers.first as? SettingsController {
                    settingsController.selectedSnapshot = selectedSnapshot
                }
            }
        }
    }
}
