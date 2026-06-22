//
//  ScreensController.swift
//  Folium
//
//  Created by Jarrod Norwell on 23/6/2026.
//

import ConstraintKit
import UIKit

class ScreensController : UIViewController {
    var aspectRatios: [System : (portrait: CGFloat, landscape: CGFloat)] = [
        .mandarine : (3.0 / 4.0, 4.0 / 3.0),
        .tomato : (3.0 / 4.0, 4.0 / 3.0)
    ]
    
    var constraints: (pad: (portrait: [NSLayoutConstraint], landscape: [NSLayoutConstraint]),
                      phone: (portrait: [NSLayoutConstraint], landscape: [NSLayoutConstraint])) = (([], []), ([], []))
    
    var primaryRenderingView: UIView? = nil
    // TODO: secondary
    
    var system: System = .mandarine
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        guard let tabController: TabController = tabBarController as? TabController,
            let game: Game = tabController.game else {
            return
        }
        
        switch game {
        case is MandarineGame:
            primaryRenderingView = UIImageView()
            system = .mandarine
        case is TomatoGame:
            primaryRenderingView = UIImageView()
            system = .tomato
        default:
            break
        }
        
        guard let primaryRenderingView: UIView else {
            return
        }
        primaryRenderingView.translatesAutoresizingMaskIntoConstraints = false
        primaryRenderingView.backgroundColor = .secondarySystemBackground
        primaryRenderingView.cornerConfiguration = .corners(radius: UICornerRadius.fixed(16.0))
        switch type(of: primaryRenderingView.self) {
        case is UIImageView.Type:
            primaryRenderingView.clipsToBounds = true
        default:
            break
        }
        view.addSubview(primaryRenderingView)
    }
    
    var game: Game? = nil
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarItem.badgeValue = nil
        if let tabController: TabController = tabBarController as? TabController {
            game = tabController.game
        }
        
        guard let windowScene: UIWindowScene, let tabController: TabController = tabBarController as? TabController else {
            return
        }
        
        tabController.setTabBarHidden(windowScene.effectiveGeometry.interfaceOrientation.isLandscape, animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let windowScene: UIWindowScene, let tabController: TabController = tabBarController as? TabController else {
            return
        }
        
        let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
        coordinator.animate { context in } completion: { context in
            tabController.setTabBarHidden(!windowScene.effectiveGeometry.interfaceOrientation.isPortrait, animated: true)
            if windowScene.effectiveGeometry.interfaceOrientation.isPortrait {
                self.view.removeConstraints(isPad ? self.constraints.pad.landscape : self.constraints.phone.landscape)
                self.view.addConstraints(isPad ? self.constraints.pad.portrait : self.constraints.phone.portrait)
            } else {
                self.view.removeConstraints(isPad ? self.constraints.pad.portrait : self.constraints.phone.portrait)
                self.view.addConstraints(isPad ? self.constraints.pad.landscape : self.constraints.phone.landscape)
            }
            
            self.view.setNeedsUpdateConstraints()
        }
    }
    
    func calculateAspectRatio(for system: System, isPortrait: Bool) -> CGFloat {
        if let aspectRatio: (portrait: CGFloat, landscape: CGFloat) = aspectRatios[system] {
            isPortrait ? aspectRatio.portrait : aspectRatio.landscape
        } else {
            0.0
        }
    }
}

extension ScreensController {
    func configureConstraintsForMandarine() {
        guard let primaryRenderingView: UIView else {
            return
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            constraints.pad.portrait.append(contentsOf: [
                
            ])
            
            constraints.pad.landscape.append(contentsOf: [
                
            ])
        } else {
            constraints.phone.portrait.append(contentsOf: [
                primaryRenderingView.top.constraint(equalTo: view.salg.top, constant: 20.0),
                primaryRenderingView.left.constraint(equalTo: view.salg.left, constant: 20.0),
                primaryRenderingView.right.constraint(equalTo: view.salg.right, constant: -20.0),
                primaryRenderingView.height.constraint(equalTo: primaryRenderingView.salg.width, multiplier: calculateAspectRatio(for: .mandarine, isPortrait: true))
            ])
            
            constraints.phone.landscape.append(contentsOf: [
                primaryRenderingView.top.constraint(equalTo: view.salg.top, constant: 20.0),
                primaryRenderingView.bottom.constraint(equalTo: view.salg.bottom, constant: -20.0),
                primaryRenderingView.centerX.constraint(equalTo: view.salg.centerX),
                primaryRenderingView.width.constraint(equalTo: primaryRenderingView.salg.height, multiplier: calculateAspectRatio(for: .mandarine, isPortrait: false))
            ])
        }
    }
    
    func configureConstraintsForTomato() {
        guard let primaryRenderingView: UIView else {
            return
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            constraints.pad.portrait.append(contentsOf: [
                
            ])
            
            constraints.pad.landscape.append(contentsOf: [
                
            ])
        } else {
            constraints.phone.portrait.append(contentsOf: [
                primaryRenderingView.top.constraint(equalTo: view.salg.top, constant: 20.0),
                primaryRenderingView.left.constraint(equalTo: view.salg.left, constant: 20.0),
                primaryRenderingView.right.constraint(equalTo: view.salg.right, constant: -20.0),
                primaryRenderingView.height.constraint(equalTo: primaryRenderingView.salg.width, multiplier: calculateAspectRatio(for: .tomato, isPortrait: true))
            ])
            
            constraints.phone.landscape.append(contentsOf: [
                primaryRenderingView.top.constraint(equalTo: view.salg.top, constant: 20.0),
                primaryRenderingView.bottom.constraint(equalTo: view.salg.bottom, constant: -20.0),
                primaryRenderingView.centerX.constraint(equalTo: view.salg.centerX),
                primaryRenderingView.width.constraint(equalTo: primaryRenderingView.salg.height, multiplier: calculateAspectRatio(for: .tomato, isPortrait: false))
            ])
        }
    }
}
