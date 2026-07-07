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
    var constraints: (pad: (portrait: [NSLayoutConstraint], landscape: [NSLayoutConstraint]),
                      phone: (portrait: [NSLayoutConstraint], landscape: [NSLayoutConstraint])) = (([], []), ([], []))
    var commonConstraints: [NSLayoutConstraint] = []
    
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
    
    var usedForMultiplayer: Bool = false
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
        case is KiwiGame:
            primaryRenderingView = UIImageView()
            primaryBackgroundRenderingView = UIImageView()
            
            system = .kiwi
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
        
        let effect: UIVisualEffect = if #available(iOS 26.0, *) {
            UIGlassEffect(style: .regular)
        } else {
            UIBlurEffect(style: .systemMaterial)
        }
        
        guard let primaryBackgroundRenderingView: UIView else {
            return
        }
        primaryBackgroundRenderingView.translatesAutoresizingMaskIntoConstraints = false
        primaryBackgroundRenderingView.backgroundColor = .secondarySystemBackground
        switch type(of: primaryBackgroundRenderingView.self) {
        case is UIImageView.Type:
            if #available(iOS 26.0, *) {
                primaryBackgroundRenderingView.cornerConfiguration = UICornerConfiguration.corners(radius: UICornerRadius.fixed(32.0))
            } else {
                primaryBackgroundRenderingView.layer.cornerRadius = 32.0
                primaryBackgroundRenderingView.layer.cornerCurve = .continuous
                primaryBackgroundRenderingView.clipsToBounds = true
            }
        default:
            break
        }
        view.addSubview(primaryBackgroundRenderingView)
        
        primaryVisualEffectView = UIVisualEffectView(effect: effect)
        guard let primaryVisualEffectView: UIVisualEffectView else {
            return
        }
        primaryVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 26.0, *) {
            primaryVisualEffectView.cornerConfiguration = UICornerConfiguration.corners(radius: UICornerRadius.fixed(38.0))
        } else {
            primaryVisualEffectView.layer.cornerRadius = 38.0
            primaryVisualEffectView.layer.cornerCurve = .continuous
            primaryVisualEffectView.clipsToBounds = true
        }
        view.addSubview(primaryVisualEffectView)
        
        guard let primaryRenderingView: UIView else {
            return
        }
        primaryRenderingView.translatesAutoresizingMaskIntoConstraints = false
        primaryRenderingView.backgroundColor = .secondarySystemBackground
        switch type(of: primaryRenderingView.self) {
        case is UIImageView.Type:
            if #available(iOS 26.0, *) {
                primaryRenderingView.cornerConfiguration = UICornerConfiguration.corners(radius: UICornerRadius.fixed(32.0))
            } else {
                primaryRenderingView.layer.cornerRadius = 32.0
                primaryRenderingView.layer.cornerCurve = .continuous
                primaryRenderingView.clipsToBounds = true
            }
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
        switch type(of: secondaryBackgroundRenderingView.self) {
        case is UIImageView.Type:
            if #available(iOS 26.0, *) {
                secondaryBackgroundRenderingView.cornerConfiguration = UICornerConfiguration.corners(radius: UICornerRadius.fixed(32.0))
            } else {
                secondaryBackgroundRenderingView.layer.cornerRadius = 32.0
                secondaryBackgroundRenderingView.layer.cornerCurve = .continuous
                secondaryBackgroundRenderingView.clipsToBounds = true
            }
        default:
            break
        }
        view.addSubview(secondaryBackgroundRenderingView)
        
        secondaryVisualEffectView = UIVisualEffectView(effect: effect)
        guard let secondaryVisualEffectView: UIVisualEffectView else {
            return
        }
        secondaryVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 26.0, *) {
            secondaryVisualEffectView.cornerConfiguration = UICornerConfiguration.corners(radius: UICornerRadius.fixed(38.0))
        } else {
            secondaryVisualEffectView.layer.cornerRadius = 38.0
            secondaryVisualEffectView.layer.cornerCurve = .continuous
            secondaryVisualEffectView.clipsToBounds = true
        }
        view.addSubview(secondaryVisualEffectView)
        
        guard let secondaryRenderingView: UIView else {
            return
        }
        secondaryRenderingView.translatesAutoresizingMaskIntoConstraints = false
        secondaryRenderingView.backgroundColor = .secondarySystemBackground
        switch type(of: secondaryRenderingView.self) {
        case is UIImageView.Type:
            if #available(iOS 26.0, *) {
                secondaryRenderingView.cornerConfiguration = UICornerConfiguration.corners(radius: UICornerRadius.fixed(32.0))
            } else {
                secondaryRenderingView.layer.cornerRadius = 32.0
                secondaryRenderingView.layer.cornerCurve = .continuous
                secondaryRenderingView.clipsToBounds = true
            }
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
        let aspectRatio: (portrait: CGFloat, landscape: CGFloat) = AspectRatioManager.aspectRatio(for: system)
        return isPortrait ? aspectRatio.portrait : aspectRatio.landscape
    }
}

extension ScreensController {
    func configureConstraintsForGrape() {
        guard let primaryBackgroundRenderingView: UIView,
              let secondaryBackgroundRenderingView: UIView else {
            return
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            constraints.pad.portrait.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 46.0),
                primaryBackgroundRenderingView.bottom.constraint(equalTo: view.salg.centerY, constant: -26.0),
                primaryBackgroundRenderingView.width.constraint(equalTo: primaryBackgroundRenderingView.salg.height,
                                                                multiplier: calculateAspectRatio(for: .grape, isPortrait: false)),
                primaryBackgroundRenderingView.centerX.constraint(equalTo: view.salg.centerX),
                
                secondaryBackgroundRenderingView.top.constraint(equalTo: view.salg.centerY, constant: 26.0),
                secondaryBackgroundRenderingView.bottom.constraint(equalTo: view.salg.bottom, constant: -46.0),
                secondaryBackgroundRenderingView.width.constraint(equalTo: secondaryBackgroundRenderingView.salg.height,
                                                                  multiplier: calculateAspectRatio(for: .grape, isPortrait: false)),
                secondaryBackgroundRenderingView.centerX.constraint(equalTo: view.salg.centerX)
            ])
            
            constraints.pad.landscape.append(contentsOf: constraints.pad.portrait)
        } else {
            constraints.phone.portrait.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 26.0),
                primaryBackgroundRenderingView.left.constraint(equalTo: view.salg.left, constant: 26.0),
                primaryBackgroundRenderingView.right.constraint(equalTo: view.salg.right, constant: -26.0),
                primaryBackgroundRenderingView.height.constraint(equalTo: primaryBackgroundRenderingView.salg.width,
                                                                 multiplier: calculateAspectRatio(for: .grape, isPortrait: true)),
                
                secondaryBackgroundRenderingView.top.constraint(equalTo: primaryBackgroundRenderingView.salg.bottom, constant: 26.0),
                secondaryBackgroundRenderingView.left.constraint(equalTo: view.salg.left, constant: 26.0),
                secondaryBackgroundRenderingView.right.constraint(equalTo: view.salg.right, constant: -26.0),
                secondaryBackgroundRenderingView.height.constraint(equalTo: secondaryBackgroundRenderingView.salg.width,
                                                                   multiplier: calculateAspectRatio(for: .grape, isPortrait: true)),
            ])
            
            constraints.phone.landscape.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 26.0),
                primaryBackgroundRenderingView.right.constraint(equalTo: view.salg.centerX, constant: -12.0),
                primaryBackgroundRenderingView.height.constraint(equalTo: view.salg.height, multiplier: 2.0 / 3.0),
                primaryBackgroundRenderingView.width.constraint(equalTo: primaryBackgroundRenderingView.salg.height,
                                                                multiplier: calculateAspectRatio(for: .grape, isPortrait: false)),
                
                secondaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 26.0),
                secondaryBackgroundRenderingView.left.constraint(equalTo: view.salg.centerX, constant: 12.0),
                secondaryBackgroundRenderingView.height.constraint(equalTo: view.salg.height, multiplier: 2.0 / 3.0),
                secondaryBackgroundRenderingView.width.constraint(equalTo: secondaryBackgroundRenderingView.salg.height,
                                                                  multiplier: calculateAspectRatio(for: .grape, isPortrait: false))
            ])
        }
    }
    
    func configureConstraintsForKiwi() {
        guard let primaryBackgroundRenderingView: UIView else {
            return
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            constraints.pad.portrait.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 46.0),
                primaryBackgroundRenderingView.left.constraint(equalTo: view.salg.left, constant: 46.0),
                primaryBackgroundRenderingView.right.constraint(equalTo: view.salg.right, constant: -46.0),
                primaryBackgroundRenderingView.height.constraint(equalTo: primaryBackgroundRenderingView.salg.width,
                                                                 multiplier: calculateAspectRatio(for: .kiwi, isPortrait: true))
            ])
            
            constraints.pad.landscape.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 26.0),
                primaryBackgroundRenderingView.bottom.constraint(equalTo: view.salg.bottom, constant: -26.0),
                primaryBackgroundRenderingView.width.constraint(equalTo: primaryBackgroundRenderingView.salg.height,
                                                                multiplier: calculateAspectRatio(for: .kiwi, isPortrait: false)),
                primaryBackgroundRenderingView.centerX.constraint(equalTo: view.salg.centerX),
            ])
        } else {
            constraints.phone.portrait.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 26.0),
                primaryBackgroundRenderingView.left.constraint(equalTo: view.salg.left, constant: 26.0),
                primaryBackgroundRenderingView.right.constraint(equalTo: view.salg.right, constant: -26.0),
                primaryBackgroundRenderingView.height.constraint(equalTo: primaryBackgroundRenderingView.salg.width,
                                                                 multiplier: calculateAspectRatio(for: .kiwi, isPortrait: true))
            ])
            
            constraints.phone.landscape.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 26.0),
                primaryBackgroundRenderingView.bottom.constraint(equalTo: view.salg.bottom, constant: -26.0),
                primaryBackgroundRenderingView.width.constraint(equalTo: primaryBackgroundRenderingView.salg.height,
                                                                multiplier: calculateAspectRatio(for: .kiwi, isPortrait: false)),
                primaryBackgroundRenderingView.centerX.constraint(equalTo: view.salg.centerX),
            ])
        }
    }
    
    func configureConstraintsForMandarine() {
        guard let primaryBackgroundRenderingView: UIView else {
            return
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            constraints.pad.portrait.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 46.0),
                primaryBackgroundRenderingView.left.constraint(equalTo: view.salg.left, constant: 46.0),
                primaryBackgroundRenderingView.right.constraint(equalTo: view.salg.right, constant: -46.0),
                primaryBackgroundRenderingView.height.constraint(equalTo: primaryBackgroundRenderingView.salg.width,
                                                                 multiplier: calculateAspectRatio(for: .mandarine, isPortrait: true))
            ])
            
            constraints.pad.landscape.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 26.0),
                primaryBackgroundRenderingView.bottom.constraint(equalTo: view.salg.bottom, constant: -26.0),
                primaryBackgroundRenderingView.width.constraint(equalTo: primaryBackgroundRenderingView.salg.height,
                                                                multiplier: calculateAspectRatio(for: .mandarine, isPortrait: false)),
                primaryBackgroundRenderingView.centerX.constraint(equalTo: view.salg.centerX),
            ])
        } else {
            constraints.phone.portrait.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 26.0),
                primaryBackgroundRenderingView.left.constraint(equalTo: view.salg.left, constant: 26.0),
                primaryBackgroundRenderingView.right.constraint(equalTo: view.salg.right, constant: -26.0),
                primaryBackgroundRenderingView.height.constraint(equalTo: primaryBackgroundRenderingView.salg.width,
                                                                 multiplier: calculateAspectRatio(for: .mandarine, isPortrait: true))
            ])
            
            constraints.phone.landscape.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 26.0),
                primaryBackgroundRenderingView.bottom.constraint(equalTo: view.salg.bottom, constant: -26.0),
                primaryBackgroundRenderingView.width.constraint(equalTo: primaryBackgroundRenderingView.salg.height,
                                                                multiplier: calculateAspectRatio(for: .mandarine, isPortrait: false)),
                primaryBackgroundRenderingView.centerX.constraint(equalTo: view.salg.centerX),
            ])
        }
    }
    
    func configureConstraintsForTomato() {
        guard let primaryBackgroundRenderingView: UIView else {
            return
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            constraints.pad.portrait.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 46.0),
                primaryBackgroundRenderingView.left.constraint(equalTo: view.salg.left, constant: 46.0),
                primaryBackgroundRenderingView.right.constraint(equalTo: view.salg.right, constant: -46.0),
                primaryBackgroundRenderingView.height.constraint(equalTo: primaryBackgroundRenderingView.salg.width,
                                                                 multiplier: calculateAspectRatio(for: .tomato, isPortrait: true))
            ])
            
            constraints.pad.landscape.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 26.0),
                primaryBackgroundRenderingView.bottom.constraint(equalTo: view.salg.bottom, constant: -26.0),
                primaryBackgroundRenderingView.width.constraint(equalTo: primaryBackgroundRenderingView.salg.height,
                                                                multiplier: calculateAspectRatio(for: .tomato, isPortrait: false)),
                primaryBackgroundRenderingView.centerX.constraint(equalTo: view.salg.centerX),
            ])
        } else {
            constraints.phone.portrait.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 26.0),
                primaryBackgroundRenderingView.left.constraint(equalTo: view.salg.left, constant: 26.0),
                primaryBackgroundRenderingView.right.constraint(equalTo: view.salg.right, constant: -26.0),
                primaryBackgroundRenderingView.height.constraint(equalTo: primaryBackgroundRenderingView.salg.width,
                                                                 multiplier: calculateAspectRatio(for: .tomato, isPortrait: true))
            ])
            
            constraints.phone.landscape.append(contentsOf: [
                primaryBackgroundRenderingView.top.constraint(equalTo: view.salg.top, constant: 26.0),
                primaryBackgroundRenderingView.bottom.constraint(equalTo: view.salg.bottom, constant: -26.0),
                primaryBackgroundRenderingView.width.constraint(equalTo: primaryBackgroundRenderingView.salg.height,
                                                                multiplier: calculateAspectRatio(for: .tomato, isPortrait: false)),
                primaryBackgroundRenderingView.centerX.constraint(equalTo: view.salg.centerX),
            ])
        }
    }
    
    func configureCommonConstraints() {
        guard let primaryVisualEffectView: UIVisualEffectView,
              let primaryRenderingView: UIView, let primaryBackgroundRenderingView: UIView else {
            return
        }
        
        commonConstraints.append(contentsOf: [
            primaryVisualEffectView.top.constraint(equalTo: primaryBackgroundRenderingView.salg.top, constant: -6.0),
            primaryVisualEffectView.left.constraint(equalTo: primaryBackgroundRenderingView.salg.left, constant: -6.0),
            primaryVisualEffectView.bottom.constraint(equalTo: primaryBackgroundRenderingView.salg.bottom, constant: 6.0),
            primaryVisualEffectView.right.constraint(equalTo: primaryBackgroundRenderingView.salg.right, constant: 6.0),
            
            primaryRenderingView.top.constraint(equalTo: primaryVisualEffectView.contentView.salg.top, constant: 6.0),
            primaryRenderingView.left.constraint(equalTo: primaryVisualEffectView.contentView.salg.left, constant: 6.0),
            primaryRenderingView.bottom.constraint(equalTo: primaryVisualEffectView.contentView.salg.bottom, constant: -6.0),
            primaryRenderingView.right.constraint(equalTo: primaryVisualEffectView.contentView.salg.right, constant: -6.0)
        ])
        
        guard let secondaryVisualEffectView: UIVisualEffectView,
              let secondaryRenderingView: UIView, let secondaryBackgroundRenderingView: UIView else {
            return
        }
        
        commonConstraints.append(contentsOf: [
            secondaryVisualEffectView.top.constraint(equalTo: secondaryBackgroundRenderingView.salg.top, constant: -6.0),
            secondaryVisualEffectView.left.constraint(equalTo: secondaryBackgroundRenderingView.salg.left, constant: -6.0),
            secondaryVisualEffectView.bottom.constraint(equalTo: secondaryBackgroundRenderingView.salg.bottom, constant: 6.0),
            secondaryVisualEffectView.right.constraint(equalTo: secondaryBackgroundRenderingView.salg.right, constant: 6.0),
            
            secondaryRenderingView.top.constraint(equalTo: secondaryVisualEffectView.contentView.salg.top, constant: 6.0),
            secondaryRenderingView.left.constraint(equalTo: secondaryVisualEffectView.contentView.salg.left, constant: 6.0),
            secondaryRenderingView.bottom.constraint(equalTo: secondaryVisualEffectView.contentView.salg.bottom, constant: -6.0),
            secondaryRenderingView.right.constraint(equalTo: secondaryVisualEffectView.contentView.salg.right, constant: -6.0)
        ])
    }
}
