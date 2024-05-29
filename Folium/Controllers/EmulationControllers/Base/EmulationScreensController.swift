//
//  EmulationScreensController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 17/3/2024.
//

import Foundation
import Metal
import MetalKit
import UIKit

struct ScreenConfiguration {
    static let borderColor: CGColor = UIColor.secondarySystemBackground.cgColor
    static let borderWidth: CGFloat = 3
    static let cornerRadius: CGFloat = 15
}

class EmulationScreensController : EmulationVirtualControllerController {
    var primaryScreen, secondaryScreen: UIView!
    var primaryBlurredScreen, secondaryBlurredScreen: UIView!
    fileprivate var visualEffectView: UIVisualEffectView!
    
    fileprivate var portraitConstraints, landscapeConstraints: [NSLayoutConstraint]!
    
    let device = MTLCreateSystemDefaultDevice()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        visualEffectView = .init(effect: UIBlurEffect(style: .systemMaterial))
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(visualEffectView)
        view.addConstraints([
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        switch game {
        case _ as CytrusManager.Library.Game:
            setupCytrusScreen()
        case let grapeGame as GrapeManager.Library.Game:
            grapeGame.gameType == .nds ? setupGrapeScreens() : setupGrapeScreen()
        case _ as KiwiManager.Library.Game:
            setupKiwiScreen()
        default:
            break
        }
        
        if #available(iOS 17, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], action: #selector(traitDidChange))
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown {
            view.removeConstraints(landscapeConstraints)
            view.addConstraints(portraitConstraints)
        } else {
            view.removeConstraints(portraitConstraints)
            view.addConstraints(landscapeConstraints)
        }
        
        coordinator.animate { _ in
            self.virtualControllerView.layout()
            self.view.layoutIfNeeded()
        }
    }
    
    func setupCytrusScreen() {
        primaryScreen = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        primaryScreen.translatesAutoresizingMaskIntoConstraints = false
        primaryScreen.clipsToBounds = true
        primaryScreen.layer.borderColor = ScreenConfiguration.borderColor
        primaryScreen.layer.borderWidth = ScreenConfiguration.borderWidth
        primaryScreen.layer.cornerCurve = .continuous
        primaryScreen.layer.cornerRadius = ScreenConfiguration.cornerRadius
        view.addSubview(primaryScreen)
        
        view.insertSubview(primaryScreen, belowSubview: virtualControllerView)
        view.insertSubview(visualEffectView, belowSubview: primaryScreen)
        
        portraitConstraints = [
            primaryScreen.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            primaryScreen.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            // primaryScreen.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            primaryScreen.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            primaryScreen.heightAnchor.constraint(equalTo: primaryScreen.widthAnchor, multiplier: (3 / 5) + (3 / 4)),
        ]
        
        landscapeConstraints = [
            primaryScreen.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            primaryScreen.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            primaryScreen.widthAnchor.constraint(equalTo: primaryScreen.heightAnchor, multiplier: 4 / 3),
            primaryScreen.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ]
        
        view.addConstraints(UIApplication.shared.statusBarOrientation == .portrait ||
                            UIApplication.shared.statusBarOrientation == .portraitUpsideDown ? portraitConstraints : landscapeConstraints)
    }
    
    func setupGrapeScreen() {
        primaryScreen = MTKView(frame: .zero, device: device)
        primaryScreen.translatesAutoresizingMaskIntoConstraints = false
        primaryScreen.clipsToBounds = true
        (primaryScreen as! MTKView).delegate = self
        primaryScreen.layer.borderColor = ScreenConfiguration.borderColor
        primaryScreen.layer.borderWidth = ScreenConfiguration.borderWidth
        primaryScreen.layer.cornerCurve = .continuous
        primaryScreen.layer.cornerRadius = ScreenConfiguration.cornerRadius
        view.addSubview(primaryScreen)
        
        primaryBlurredScreen = MTKView(frame: .zero, device: device)
        primaryBlurredScreen.translatesAutoresizingMaskIntoConstraints = false
        //(primaryBlurredScreen as! MTKView).delegate = self
        view.addSubview(primaryBlurredScreen)
        
        view.insertSubview(primaryScreen, belowSubview: virtualControllerView)
        view.insertSubview(visualEffectView, belowSubview: primaryScreen)
        view.insertSubview(primaryBlurredScreen, belowSubview: visualEffectView)
        
        portraitConstraints = [
            primaryScreen.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            primaryScreen.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            primaryScreen.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            primaryScreen.heightAnchor.constraint(equalTo: primaryScreen.widthAnchor, multiplier: 2 / 3),
            
            primaryBlurredScreen.topAnchor.constraint(equalTo: view.topAnchor),
            primaryBlurredScreen.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            primaryBlurredScreen.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            primaryBlurredScreen.bottomAnchor.constraint(equalTo: primaryScreen.bottomAnchor, constant: 10)
        ]
        
        landscapeConstraints = [
            primaryScreen.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            primaryScreen.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            primaryScreen.widthAnchor.constraint(equalTo: primaryScreen.heightAnchor, multiplier: 3 / 2),
            primaryScreen.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            primaryBlurredScreen.topAnchor.constraint(equalTo: view.topAnchor),
            primaryBlurredScreen.leadingAnchor.constraint(equalTo: primaryScreen.leadingAnchor, constant: -10),
            primaryBlurredScreen.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            primaryBlurredScreen.trailingAnchor.constraint(equalTo: primaryScreen.trailingAnchor, constant: 10)
        ]
        
        view.addConstraints(UIApplication.shared.statusBarOrientation == .portrait ||
                            UIApplication.shared.statusBarOrientation == .portraitUpsideDown ? portraitConstraints : landscapeConstraints)
    }
    
    func setupGrapeScreens() {
        primaryScreen = MTKView(frame: .zero, device: device)
        primaryScreen.translatesAutoresizingMaskIntoConstraints = false
        primaryScreen.clipsToBounds = true
        (primaryScreen as! MTKView).delegate = self
        primaryScreen.layer.borderColor = ScreenConfiguration.borderColor
        primaryScreen.layer.borderWidth = ScreenConfiguration.borderWidth
        primaryScreen.layer.cornerCurve = .continuous
        primaryScreen.layer.cornerRadius = ScreenConfiguration.cornerRadius
        view.addSubview(primaryScreen)
        
        primaryBlurredScreen = MTKView(frame: .zero, device: device)
        primaryBlurredScreen.translatesAutoresizingMaskIntoConstraints = false
        //(primaryBlurredScreen as! MTKView).delegate = self
        view.addSubview(primaryBlurredScreen)
        
        secondaryScreen = MTKView(frame: .zero, device: device)
        secondaryScreen.translatesAutoresizingMaskIntoConstraints = false
        secondaryScreen.clipsToBounds = true
        //(secondaryScreen as! MTKView).delegate = self
        secondaryScreen.layer.borderColor = ScreenConfiguration.borderColor
        secondaryScreen.layer.borderWidth = ScreenConfiguration.borderWidth
        secondaryScreen.layer.cornerCurve = .continuous
        secondaryScreen.layer.cornerRadius = ScreenConfiguration.cornerRadius
        secondaryScreen.isUserInteractionEnabled = true
        view.addSubview(secondaryScreen)
        
        secondaryBlurredScreen = MTKView(frame: .zero, device: device)
        secondaryBlurredScreen.translatesAutoresizingMaskIntoConstraints = false
        //(secondaryBlurredScreen as! MTKView).delegate = self
        view.addSubview(secondaryBlurredScreen)
        
        view.insertSubview(primaryScreen, belowSubview: virtualControllerView)
        view.insertSubview(secondaryScreen, belowSubview: virtualControllerView)
        view.insertSubview(visualEffectView, belowSubview: primaryScreen)
        view.insertSubview(primaryBlurredScreen, belowSubview: visualEffectView)
        view.insertSubview(secondaryBlurredScreen, belowSubview: visualEffectView)
        
        portraitConstraints = [
            primaryScreen.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            primaryScreen.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            primaryScreen.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            primaryScreen.heightAnchor.constraint(equalTo: primaryScreen.widthAnchor, multiplier: 3 / 4),
            
            primaryBlurredScreen.topAnchor.constraint(equalTo: view.topAnchor),
            primaryBlurredScreen.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            primaryBlurredScreen.bottomAnchor.constraint(equalTo: primaryScreen.bottomAnchor, constant: 5),
            primaryBlurredScreen.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            secondaryScreen.topAnchor.constraint(equalTo: primaryScreen.safeAreaLayoutGuide.bottomAnchor, constant: 10),
            secondaryScreen.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            secondaryScreen.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            secondaryScreen.heightAnchor.constraint(equalTo: secondaryScreen.widthAnchor, multiplier: 3 / 4),
            
            secondaryBlurredScreen.topAnchor.constraint(equalTo: secondaryScreen.topAnchor, constant: -5),
            secondaryBlurredScreen.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            secondaryBlurredScreen.bottomAnchor.constraint(equalTo: secondaryScreen.bottomAnchor, constant: 10),
            secondaryBlurredScreen.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        landscapeConstraints = [
            primaryScreen.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            primaryScreen.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -5),
            primaryScreen.heightAnchor.constraint(equalTo: primaryScreen.widthAnchor, multiplier: 3 / 4),
            primaryScreen.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            
            primaryBlurredScreen.topAnchor.constraint(equalTo: primaryScreen.topAnchor, constant: -10),
            primaryBlurredScreen.leadingAnchor.constraint(equalTo: primaryScreen.leadingAnchor, constant: -10),
            primaryBlurredScreen.bottomAnchor.constraint(equalTo: primaryScreen.bottomAnchor, constant: 10),
            primaryBlurredScreen.trailingAnchor.constraint(equalTo: primaryScreen.trailingAnchor, constant: 5),
            
            secondaryScreen.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 5),
            secondaryScreen.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            secondaryScreen.heightAnchor.constraint(equalTo: primaryScreen.widthAnchor, multiplier: 3 / 4),
            secondaryScreen.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            
            secondaryBlurredScreen.topAnchor.constraint(equalTo: secondaryScreen.topAnchor, constant: -10),
            secondaryBlurredScreen.leadingAnchor.constraint(equalTo: secondaryScreen.leadingAnchor, constant: -5),
            secondaryBlurredScreen.bottomAnchor.constraint(equalTo: secondaryScreen.bottomAnchor, constant: 10),
            secondaryBlurredScreen.trailingAnchor.constraint(equalTo: secondaryScreen.trailingAnchor, constant: 10),
        ]
        
        view.addConstraints(UIApplication.shared.statusBarOrientation == .portrait ||
                            UIApplication.shared.statusBarOrientation == .portraitUpsideDown ? portraitConstraints : landscapeConstraints)
    }
    
    func setupKiwiScreen() {
        primaryScreen = MTKView(frame: .zero, device: device)
        primaryScreen.translatesAutoresizingMaskIntoConstraints = false
        primaryScreen.clipsToBounds = true
        (primaryScreen as! MTKView).delegate = self
        primaryScreen.layer.borderColor = ScreenConfiguration.borderColor
        primaryScreen.layer.borderWidth = ScreenConfiguration.borderWidth
        primaryScreen.layer.cornerCurve = .continuous
        primaryScreen.layer.cornerRadius = ScreenConfiguration.cornerRadius
        view.addSubview(primaryScreen)
        
        primaryBlurredScreen = MTKView(frame: .zero, device: device)
        primaryBlurredScreen.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(primaryBlurredScreen)
        
        view.insertSubview(primaryScreen, belowSubview: virtualControllerView)
        view.insertSubview(visualEffectView, belowSubview: primaryScreen)
        view.insertSubview(primaryBlurredScreen, belowSubview: visualEffectView)
        
        portraitConstraints = [
            primaryScreen.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            primaryScreen.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            primaryScreen.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            primaryScreen.heightAnchor.constraint(equalTo: primaryScreen.widthAnchor, multiplier: 3 / 4),
            
            primaryBlurredScreen.topAnchor.constraint(equalTo: view.topAnchor),
            primaryBlurredScreen.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            primaryBlurredScreen.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            primaryBlurredScreen.bottomAnchor.constraint(equalTo: primaryScreen.bottomAnchor, constant: 10)
        ]
        
        landscapeConstraints = [
            primaryScreen.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            primaryScreen.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            primaryScreen.widthAnchor.constraint(equalTo: primaryScreen.heightAnchor, multiplier: 4 / 3),
            primaryScreen.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            primaryBlurredScreen.topAnchor.constraint(equalTo: view.topAnchor),
            primaryBlurredScreen.leadingAnchor.constraint(equalTo: primaryScreen.leadingAnchor, constant: -10),
            primaryBlurredScreen.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            primaryBlurredScreen.trailingAnchor.constraint(equalTo: primaryScreen.trailingAnchor, constant: 10)
        ]
        
        view.addConstraints(UIApplication.shared.statusBarOrientation == .portrait ||
                            UIApplication.shared.statusBarOrientation == .portraitUpsideDown ? portraitConstraints : landscapeConstraints)
    }
    
    @objc fileprivate func traitDidChange() {
        primaryScreen.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        switch game {
        case let grapeGame as GrapeManager.Library.Game:
            if grapeGame.gameType == .nds {
                secondaryScreen.layer.borderColor = UIColor.secondarySystemBackground.cgColor
            }
        default:
            break
        }
    }
}

extension EmulationScreensController : MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    func draw(in view: MTKView) {}
}
