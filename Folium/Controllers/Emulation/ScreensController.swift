//
//  ScreensController.swift
//  Folium
//
//  Created by Jarrod Norwell on 23/6/2026.
//

import ColourKit
import ConstraintKit
import UIKit

class ScreensController : UIViewController {
    var aspectRatios: [System : (portrait: CGFloat, landscape: CGFloat)] = [
        .mandarine : (3.0 / 4.0, 4.0 / 3.0),
        .tomato : (3.0 / 4.0, 4.0 / 3.0)
    ]
    
    var constraints: (pad: (portrait: [NSLayoutConstraint], landscape: [NSLayoutConstraint]),
                      phone: (portrait: [NSLayoutConstraint], landscape: [NSLayoutConstraint])) = (([], []), ([], []))
    
    var primaryVisualEffectView: UIVisualEffectView? = nil
    var secondaryVisualEffectView: UIVisualEffectView? = nil
    
    var primaryRenderingView: UIView? = nil,
        primaryBackgroundRenderingView: UIView? = nil
    var secondaryRenderingView: UIView? = nil,
        secondaryBackgroundRenderingView: UIView? = nil
    
    var settingsButton: UIButton? = nil,
        selectButton: UIButton? = nil,
        startButton: UIButton? = nil
    
    var leftThumbstickView: ThumbstickView? = nil,
        rightThumbstickView: ThumbstickView? = nil
    
    var stackView: UIStackView? = nil
    
    var upButton: UIButton? = nil,
        downButton: UIButton? = nil,
        leftButton: UIButton? = nil,
        rightButton: UIButton? = nil
    
    var southButton: UIButton? = nil,
        eastButton: UIButton? = nil,
        northButton: UIButton? = nil,
        westButton: UIButton? = nil
    
    var l1Button: UIButton? = nil,
        r1Button: UIButton? = nil,
        l2Button: UIButton? = nil,
        r2Button: UIButton? = nil
    
    var system: System = .mandarine
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { UIDevice.current.userInterfaceIdiom == .pad ? .portrait : .allButUpsideDown }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        guard let tabController: TabController = tabBarController as? TabController,
            let game: Game = tabController.game else {
            return
        }
        
        switch game {
        case is GrapeGame:
            primaryRenderingView = UIImageView()
            primaryBackgroundRenderingView = UIImageView()
            
            secondaryRenderingView = UIImageView()
            secondaryBackgroundRenderingView = UIImageView()
            system = .grape
        case is MandarineGame:
            primaryRenderingView = UIImageView()
            primaryBackgroundRenderingView = UIImageView()
            
            system = .mandarine
        case is TomatoGame:
            primaryRenderingView = UIImageView()
            primaryBackgroundRenderingView = UIImageView()
            
            system = .tomato
        default:
            break
        }
        
        guard let primaryBackgroundRenderingView: UIView else {
            return
        }
        primaryBackgroundRenderingView.translatesAutoresizingMaskIntoConstraints = false
        primaryBackgroundRenderingView.backgroundColor = .secondarySystemBackground
        primaryBackgroundRenderingView.cornerConfiguration = .corners(radius: UICornerRadius.fixed(34.0))
        switch type(of: primaryBackgroundRenderingView.self) {
        case is UIImageView.Type:
            primaryBackgroundRenderingView.clipsToBounds = true
        default:
            break
        }
        view.addSubview(primaryBackgroundRenderingView)
        
        primaryVisualEffectView = UIVisualEffectView(effect: UIGlassEffect(style: .regular))
        guard let primaryVisualEffectView: UIVisualEffectView else {
            return
        }
        primaryVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        primaryVisualEffectView.cornerConfiguration = .corners(radius: UICornerRadius.fixed(40.0))
        view.addSubview(primaryVisualEffectView)
        
        guard let primaryRenderingView: UIView else {
            return
        }
        primaryRenderingView.translatesAutoresizingMaskIntoConstraints = false
        primaryRenderingView.backgroundColor = .secondarySystemBackground
        primaryRenderingView.cornerConfiguration = .corners(radius: UICornerRadius.fixed(34.0))
        switch type(of: primaryRenderingView.self) {
        case is UIImageView.Type:
            primaryRenderingView.clipsToBounds = true
        default:
            break
        }
        primaryVisualEffectView.contentView.addSubview(primaryRenderingView)
        
        // MARK: Secondary
        guard let secondaryBackgroundRenderingView: UIView else {
            return
        }
        secondaryBackgroundRenderingView.translatesAutoresizingMaskIntoConstraints = false
        secondaryBackgroundRenderingView.backgroundColor = .secondarySystemBackground
        secondaryBackgroundRenderingView.cornerConfiguration = .corners(radius: UICornerRadius.fixed(34.0))
        switch type(of: secondaryBackgroundRenderingView.self) {
        case is UIImageView.Type:
            secondaryBackgroundRenderingView.clipsToBounds = true
        default:
            break
        }
        view.addSubview(secondaryBackgroundRenderingView)
        
        secondaryVisualEffectView = UIVisualEffectView(effect: UIGlassEffect(style: .regular))
        guard let secondaryVisualEffectView: UIVisualEffectView else {
            return
        }
        secondaryVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        secondaryVisualEffectView.cornerConfiguration = .corners(radius: UICornerRadius.fixed(40.0))
        view.addSubview(secondaryVisualEffectView)
        
        guard let secondaryRenderingView: UIView else {
            return
        }
        secondaryRenderingView.translatesAutoresizingMaskIntoConstraints = false
        secondaryRenderingView.backgroundColor = .secondarySystemBackground
        secondaryRenderingView.cornerConfiguration = .corners(radius: UICornerRadius.fixed(34.0))
        switch type(of: secondaryRenderingView.self) {
        case is UIImageView.Type:
            secondaryRenderingView.clipsToBounds = true
        default:
            break
        }
        secondaryVisualEffectView.contentView.addSubview(secondaryRenderingView)
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
    func configureConstraintsForGrape() {
        guard let primaryVisualEffectView: UIVisualEffectView, let secondaryVisualEffectView: UIVisualEffectView,
              let primaryRenderingView: UIView, let primaryBackgroundRenderingView: UIView,
              let secondaryRenderingView: UIView, let secondaryBackgroundRenderingView: UIView else {
            return
        }
        
        guard let stackView: UIStackView else {
            return
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            constraints.pad.portrait.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 46.0),
                primaryBackgroundRenderingView.left.constraint(equalTo: view.salg.left, constant: 46.0),
                primaryBackgroundRenderingView.right.constraint(equalTo: view.salg.right, constant: -46.0),
                primaryBackgroundRenderingView.height.constraint(equalTo: primaryBackgroundRenderingView.salg.width, multiplier: calculateAspectRatio(for: .mandarine, isPortrait: true)),
                
                primaryVisualEffectView.top.constraint(equalTo: primaryBackgroundRenderingView.salg.top, constant: -6.0),
                primaryVisualEffectView.left.constraint(equalTo: primaryBackgroundRenderingView.salg.left, constant: -6.0),
                primaryVisualEffectView.bottom.constraint(equalTo: primaryBackgroundRenderingView.salg.bottom, constant: 6.0),
                primaryVisualEffectView.right.constraint(equalTo: primaryBackgroundRenderingView.salg.right, constant: 6.0),
                
                primaryRenderingView.top.constraint(equalTo: primaryVisualEffectView.contentView.salg.top, constant: 6.0),
                primaryRenderingView.left.constraint(equalTo: primaryVisualEffectView.contentView.salg.left, constant: 6.0),
                primaryRenderingView.bottom.constraint(equalTo: primaryVisualEffectView.contentView.salg.bottom, constant: -6.0),
                primaryRenderingView.right.constraint(equalTo: primaryVisualEffectView.contentView.salg.right, constant: -6.0)
            ])
            
            constraints.pad.landscape.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 46.0),
                primaryBackgroundRenderingView.bottom.constraint(lessThanOrEqualTo: stackView.salg.top, constant: -46.0),
                primaryBackgroundRenderingView.width.constraint(equalTo: primaryBackgroundRenderingView.salg.height, multiplier: calculateAspectRatio(for: .mandarine, isPortrait: false)),
                primaryBackgroundRenderingView.centerX.constraint(equalTo: view.salg.centerX),
                
                primaryVisualEffectView.top.constraint(equalTo: primaryBackgroundRenderingView.salg.top, constant: -6.0),
                primaryVisualEffectView.left.constraint(equalTo: primaryBackgroundRenderingView.salg.left, constant: -6.0),
                primaryVisualEffectView.bottom.constraint(equalTo: primaryBackgroundRenderingView.salg.bottom, constant: 6.0),
                primaryVisualEffectView.right.constraint(equalTo: primaryBackgroundRenderingView.salg.right, constant: 6.0),
                
                primaryRenderingView.top.constraint(equalTo: primaryVisualEffectView.contentView.salg.top, constant: 6.0),
                primaryRenderingView.left.constraint(equalTo: primaryVisualEffectView.contentView.salg.left, constant: 6.0),
                primaryRenderingView.bottom.constraint(equalTo: primaryVisualEffectView.contentView.salg.bottom, constant: -6.0),
                primaryRenderingView.right.constraint(equalTo: primaryVisualEffectView.contentView.salg.right, constant: -6.0)
            ])
        } else {
            constraints.phone.portrait.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 26.0),
                primaryBackgroundRenderingView.left.constraint(equalTo: view.salg.left, constant: 26.0),
                primaryBackgroundRenderingView.right.constraint(equalTo: view.salg.right, constant: -26.0),
                primaryBackgroundRenderingView.height.constraint(equalTo: primaryBackgroundRenderingView.salg.width, multiplier: calculateAspectRatio(for: .mandarine, isPortrait: true)),
                
                primaryVisualEffectView.top.constraint(equalTo: primaryBackgroundRenderingView.salg.top, constant: -6.0),
                primaryVisualEffectView.left.constraint(equalTo: primaryBackgroundRenderingView.salg.left, constant: -6.0),
                primaryVisualEffectView.bottom.constraint(equalTo: primaryBackgroundRenderingView.salg.bottom, constant: 6.0),
                primaryVisualEffectView.right.constraint(equalTo: primaryBackgroundRenderingView.salg.right, constant: 6.0),
                
                primaryRenderingView.top.constraint(equalTo: primaryVisualEffectView.contentView.salg.top, constant: 6.0),
                primaryRenderingView.left.constraint(equalTo: primaryVisualEffectView.contentView.salg.left, constant: 6.0),
                primaryRenderingView.bottom.constraint(equalTo: primaryVisualEffectView.contentView.salg.bottom, constant: -6.0),
                primaryRenderingView.right.constraint(equalTo: primaryVisualEffectView.contentView.salg.right, constant: -6.0)
            ])
            
            constraints.phone.landscape.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 26.0),
                primaryBackgroundRenderingView.bottom.constraint(equalTo: view.salg.bottom, constant: -26.0),
                primaryBackgroundRenderingView.width.constraint(equalTo: primaryBackgroundRenderingView.salg.height, multiplier: calculateAspectRatio(for: .mandarine, isPortrait: false)),
                primaryBackgroundRenderingView.centerX.constraint(equalTo: view.salg.centerX),
                
                primaryVisualEffectView.top.constraint(equalTo: primaryBackgroundRenderingView.salg.top, constant: -6.0),
                primaryVisualEffectView.left.constraint(equalTo: primaryBackgroundRenderingView.salg.left, constant: -6.0),
                primaryVisualEffectView.bottom.constraint(equalTo: primaryBackgroundRenderingView.salg.bottom, constant: 6.0),
                primaryVisualEffectView.right.constraint(equalTo: primaryBackgroundRenderingView.salg.right, constant: 6.0),
                
                primaryRenderingView.top.constraint(equalTo: primaryVisualEffectView.contentView.salg.top, constant: 6.0),
                primaryRenderingView.left.constraint(equalTo: primaryVisualEffectView.contentView.salg.left, constant: 6.0),
                primaryRenderingView.bottom.constraint(equalTo: primaryVisualEffectView.contentView.salg.bottom, constant: -6.0),
                primaryRenderingView.right.constraint(equalTo: primaryVisualEffectView.contentView.salg.right, constant: -6.0)
            ])
        }
    }
    
    func configureConstraintsForMandarine() {
        guard let primaryVisualEffectView: UIVisualEffectView,
              let primaryRenderingView: UIView, let primaryBackgroundRenderingView: UIView else {
            return
        }
        
        guard let stackView: UIStackView else {
            return
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            constraints.pad.portrait.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 46.0),
                primaryBackgroundRenderingView.left.constraint(equalTo: view.salg.left, constant: 46.0),
                primaryBackgroundRenderingView.right.constraint(equalTo: view.salg.right, constant: -46.0),
                primaryBackgroundRenderingView.height.constraint(equalTo: primaryBackgroundRenderingView.salg.width, multiplier: calculateAspectRatio(for: .mandarine, isPortrait: true)),
                
                primaryVisualEffectView.top.constraint(equalTo: primaryBackgroundRenderingView.salg.top, constant: -6.0),
                primaryVisualEffectView.left.constraint(equalTo: primaryBackgroundRenderingView.salg.left, constant: -6.0),
                primaryVisualEffectView.bottom.constraint(equalTo: primaryBackgroundRenderingView.salg.bottom, constant: 6.0),
                primaryVisualEffectView.right.constraint(equalTo: primaryBackgroundRenderingView.salg.right, constant: 6.0),
                
                primaryRenderingView.top.constraint(equalTo: primaryVisualEffectView.contentView.salg.top, constant: 6.0),
                primaryRenderingView.left.constraint(equalTo: primaryVisualEffectView.contentView.salg.left, constant: 6.0),
                primaryRenderingView.bottom.constraint(equalTo: primaryVisualEffectView.contentView.salg.bottom, constant: -6.0),
                primaryRenderingView.right.constraint(equalTo: primaryVisualEffectView.contentView.salg.right, constant: -6.0)
            ])
            
            constraints.pad.landscape.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 46.0),
                primaryBackgroundRenderingView.bottom.constraint(lessThanOrEqualTo: stackView.salg.top, constant: -46.0),
                primaryBackgroundRenderingView.width.constraint(equalTo: primaryBackgroundRenderingView.salg.height, multiplier: calculateAspectRatio(for: .mandarine, isPortrait: false)),
                primaryBackgroundRenderingView.centerX.constraint(equalTo: view.salg.centerX),
                
                primaryVisualEffectView.top.constraint(equalTo: primaryBackgroundRenderingView.salg.top, constant: -6.0),
                primaryVisualEffectView.left.constraint(equalTo: primaryBackgroundRenderingView.salg.left, constant: -6.0),
                primaryVisualEffectView.bottom.constraint(equalTo: primaryBackgroundRenderingView.salg.bottom, constant: 6.0),
                primaryVisualEffectView.right.constraint(equalTo: primaryBackgroundRenderingView.salg.right, constant: 6.0),
                
                primaryRenderingView.top.constraint(equalTo: primaryVisualEffectView.contentView.salg.top, constant: 6.0),
                primaryRenderingView.left.constraint(equalTo: primaryVisualEffectView.contentView.salg.left, constant: 6.0),
                primaryRenderingView.bottom.constraint(equalTo: primaryVisualEffectView.contentView.salg.bottom, constant: -6.0),
                primaryRenderingView.right.constraint(equalTo: primaryVisualEffectView.contentView.salg.right, constant: -6.0)
            ])
        } else {
            constraints.phone.portrait.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 26.0),
                primaryBackgroundRenderingView.left.constraint(equalTo: view.salg.left, constant: 26.0),
                primaryBackgroundRenderingView.right.constraint(equalTo: view.salg.right, constant: -26.0),
                primaryBackgroundRenderingView.height.constraint(equalTo: primaryBackgroundRenderingView.salg.width, multiplier: calculateAspectRatio(for: .mandarine, isPortrait: true)),
                
                primaryVisualEffectView.top.constraint(equalTo: primaryBackgroundRenderingView.salg.top, constant: -6.0),
                primaryVisualEffectView.left.constraint(equalTo: primaryBackgroundRenderingView.salg.left, constant: -6.0),
                primaryVisualEffectView.bottom.constraint(equalTo: primaryBackgroundRenderingView.salg.bottom, constant: 6.0),
                primaryVisualEffectView.right.constraint(equalTo: primaryBackgroundRenderingView.salg.right, constant: 6.0),
                
                primaryRenderingView.top.constraint(equalTo: primaryVisualEffectView.contentView.salg.top, constant: 6.0),
                primaryRenderingView.left.constraint(equalTo: primaryVisualEffectView.contentView.salg.left, constant: 6.0),
                primaryRenderingView.bottom.constraint(equalTo: primaryVisualEffectView.contentView.salg.bottom, constant: -6.0),
                primaryRenderingView.right.constraint(equalTo: primaryVisualEffectView.contentView.salg.right, constant: -6.0)
            ])
            
            constraints.phone.landscape.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 26.0),
                primaryBackgroundRenderingView.bottom.constraint(equalTo: view.salg.bottom, constant: -26.0),
                primaryBackgroundRenderingView.width.constraint(equalTo: primaryBackgroundRenderingView.salg.height, multiplier: calculateAspectRatio(for: .mandarine, isPortrait: false)),
                primaryBackgroundRenderingView.centerX.constraint(equalTo: view.salg.centerX),
                
                primaryVisualEffectView.top.constraint(equalTo: primaryBackgroundRenderingView.salg.top, constant: -6.0),
                primaryVisualEffectView.left.constraint(equalTo: primaryBackgroundRenderingView.salg.left, constant: -6.0),
                primaryVisualEffectView.bottom.constraint(equalTo: primaryBackgroundRenderingView.salg.bottom, constant: 6.0),
                primaryVisualEffectView.right.constraint(equalTo: primaryBackgroundRenderingView.salg.right, constant: 6.0),
                
                primaryRenderingView.top.constraint(equalTo: primaryVisualEffectView.contentView.salg.top, constant: 6.0),
                primaryRenderingView.left.constraint(equalTo: primaryVisualEffectView.contentView.salg.left, constant: 6.0),
                primaryRenderingView.bottom.constraint(equalTo: primaryVisualEffectView.contentView.salg.bottom, constant: -6.0),
                primaryRenderingView.right.constraint(equalTo: primaryVisualEffectView.contentView.salg.right, constant: -6.0)
            ])
        }
    }
    
    func configureConstraintsForTomato() {
        guard let primaryVisualEffectView: UIVisualEffectView,
              let primaryRenderingView: UIView, let primaryBackgroundRenderingView: UIView else {
            return
        }
        
        guard let stackView: UIStackView else {
            return
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            constraints.pad.portrait.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 46.0),
                primaryBackgroundRenderingView.left.constraint(equalTo: view.salg.left, constant: 46.0),
                primaryBackgroundRenderingView.right.constraint(equalTo: view.salg.right, constant: -46.0),
                primaryBackgroundRenderingView.height.constraint(equalTo: primaryBackgroundRenderingView.salg.width, multiplier: calculateAspectRatio(for: .mandarine, isPortrait: true)),
                
                primaryVisualEffectView.top.constraint(equalTo: primaryBackgroundRenderingView.salg.top, constant: -6.0),
                primaryVisualEffectView.left.constraint(equalTo: primaryBackgroundRenderingView.salg.left, constant: -6.0),
                primaryVisualEffectView.bottom.constraint(equalTo: primaryBackgroundRenderingView.salg.bottom, constant: 6.0),
                primaryVisualEffectView.right.constraint(equalTo: primaryBackgroundRenderingView.salg.right, constant: 6.0),
                
                primaryRenderingView.top.constraint(equalTo: primaryVisualEffectView.contentView.salg.top, constant: 6.0),
                primaryRenderingView.left.constraint(equalTo: primaryVisualEffectView.contentView.salg.left, constant: 6.0),
                primaryRenderingView.bottom.constraint(equalTo: primaryVisualEffectView.contentView.salg.bottom, constant: -6.0),
                primaryRenderingView.right.constraint(equalTo: primaryVisualEffectView.contentView.salg.right, constant: -6.0)
            ])
            
            constraints.pad.landscape.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 46.0),
                primaryBackgroundRenderingView.bottom.constraint(equalTo: stackView.salg.top, constant: -46.0),
                primaryBackgroundRenderingView.width.constraint(equalTo: primaryBackgroundRenderingView.salg.height, multiplier: calculateAspectRatio(for: .mandarine, isPortrait: false)),
                primaryBackgroundRenderingView.centerX.constraint(equalTo: view.salg.centerX),
                
                primaryVisualEffectView.top.constraint(equalTo: primaryBackgroundRenderingView.salg.top, constant: -6.0),
                primaryVisualEffectView.left.constraint(equalTo: primaryBackgroundRenderingView.salg.left, constant: -6.0),
                primaryVisualEffectView.bottom.constraint(equalTo: primaryBackgroundRenderingView.salg.bottom, constant: 6.0),
                primaryVisualEffectView.right.constraint(equalTo: primaryBackgroundRenderingView.salg.right, constant: 6.0),
                
                primaryRenderingView.top.constraint(equalTo: primaryVisualEffectView.contentView.salg.top, constant: 6.0),
                primaryRenderingView.left.constraint(equalTo: primaryVisualEffectView.contentView.salg.left, constant: 6.0),
                primaryRenderingView.bottom.constraint(equalTo: primaryVisualEffectView.contentView.salg.bottom, constant: -6.0),
                primaryRenderingView.right.constraint(equalTo: primaryVisualEffectView.contentView.salg.right, constant: -6.0)
            ])
        } else {
            constraints.phone.portrait.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 26.0),
                primaryBackgroundRenderingView.left.constraint(equalTo: view.salg.left, constant: 26.0),
                primaryBackgroundRenderingView.right.constraint(equalTo: view.salg.right, constant: -26.0),
                primaryBackgroundRenderingView.height.constraint(equalTo: primaryBackgroundRenderingView.salg.width, multiplier: calculateAspectRatio(for: .mandarine, isPortrait: true)),
                
                primaryVisualEffectView.top.constraint(equalTo: primaryBackgroundRenderingView.salg.top, constant: -6.0),
                primaryVisualEffectView.left.constraint(equalTo: primaryBackgroundRenderingView.salg.left, constant: -6.0),
                primaryVisualEffectView.bottom.constraint(equalTo: primaryBackgroundRenderingView.salg.bottom, constant: 6.0),
                primaryVisualEffectView.right.constraint(equalTo: primaryBackgroundRenderingView.salg.right, constant: 6.0),
                
                primaryRenderingView.top.constraint(equalTo: primaryVisualEffectView.contentView.salg.top, constant: 6.0),
                primaryRenderingView.left.constraint(equalTo: primaryVisualEffectView.contentView.salg.left, constant: 6.0),
                primaryRenderingView.bottom.constraint(equalTo: primaryVisualEffectView.contentView.salg.bottom, constant: -6.0),
                primaryRenderingView.right.constraint(equalTo: primaryVisualEffectView.contentView.salg.right, constant: -6.0)
            ])
            
            constraints.phone.landscape.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 26.0),
                primaryBackgroundRenderingView.bottom.constraint(equalTo: view.salg.bottom, constant: -26.0),
                primaryBackgroundRenderingView.width.constraint(equalTo: primaryBackgroundRenderingView.salg.height, multiplier: calculateAspectRatio(for: .mandarine, isPortrait: false)),
                primaryBackgroundRenderingView.centerX.constraint(equalTo: view.salg.centerX),
                
                primaryVisualEffectView.top.constraint(equalTo: primaryBackgroundRenderingView.salg.top, constant: -6.0),
                primaryVisualEffectView.left.constraint(equalTo: primaryBackgroundRenderingView.salg.left, constant: -6.0),
                primaryVisualEffectView.bottom.constraint(equalTo: primaryBackgroundRenderingView.salg.bottom, constant: 6.0),
                primaryVisualEffectView.right.constraint(equalTo: primaryBackgroundRenderingView.salg.right, constant: 6.0),
                
                primaryRenderingView.top.constraint(equalTo: primaryVisualEffectView.contentView.salg.top, constant: 6.0),
                primaryRenderingView.left.constraint(equalTo: primaryVisualEffectView.contentView.salg.left, constant: 6.0),
                primaryRenderingView.bottom.constraint(equalTo: primaryVisualEffectView.contentView.salg.bottom, constant: -6.0),
                primaryRenderingView.right.constraint(equalTo: primaryVisualEffectView.contentView.salg.right, constant: -6.0)
            ])
        }
    }
}
