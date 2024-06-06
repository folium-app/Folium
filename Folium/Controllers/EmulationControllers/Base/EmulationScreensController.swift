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
    static var borderColor: CGColor = UIColor.secondarySystemBackground.cgColor
    static var borderWidth: CGFloat = 3
    static var cornerRadius: CGFloat = 13
    
    static func controllerConnected() {
        borderWidth = 0
        cornerRadius = 0
    }
    
    static func controllerDisconnected() {
        borderWidth = 3
        cornerRadius = 13
    }
}

extension UIView {
    func update() {
        layer.borderColor = ScreenConfiguration.borderColor
        layer.borderWidth = ScreenConfiguration.borderWidth
        layer.cornerRadius = ScreenConfiguration.cornerRadius
    }
}

class MetalLayer : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass {
        CAMetalLayer.self
    }
}

class MetalView : UIView {
    var metalLayer: MetalLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        metalLayer = .init()
        metalLayer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(metalLayer)
        addConstraints([
            metalLayer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            metalLayer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            metalLayer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            metalLayer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class EmulationScreensController : EmulationVirtualControllerController {
    var primaryScreen, secondaryScreen: UIView!
    fileprivate var visualEffectView: UIVisualEffectView!
    
    fileprivate var primaryPortraitTopConstraint, primaryPortraitLeadingConstraint,
                    primaryPortraitTrailingConstraint, primaryPortraitAspectRatioConstraint: NSLayoutConstraint!
    fileprivate var primaryLandscapeTopConstraint, primaryLandscapeBottomConstraint, primaryLandscapeCenterXConstraint,
                    primaryLandscapeAspectRatioConstraint: NSLayoutConstraint!
    
    fileprivate var secondaryPortraitTopConstraint, secondaryPortraitLeadingConstraint,
                    secondaryPortraitTrailingConstraint, secondaryPortraitAspectRatioConstraint: NSLayoutConstraint!
    fileprivate var secondaryLandscapeTopConstraint, secondaryLandscapeBottomConstraint, secondaryLandscapeCenterXConstraint,
                    secondaryLandscapeAspectRatioConstraint: NSLayoutConstraint!
    
    fileprivate var controllerConnected: Bool = false
    
    let device = MTLCreateSystemDefaultDevice()
    
    override func loadView() {
        if core == .cytrus {
            primaryScreen = MetalView()
            view = primaryScreen
        } else {
            super.loadView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        if core != .cytrus {
            visualEffectView = .init(effect: UIBlurEffect(style: .systemThickMaterial))
            visualEffectView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(visualEffectView)
            view.addConstraints([
                visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
                visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
        
        switch game {
        case _ as CytrusManager.Library.Game:
            break // setupCytrusScreen()
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
        coordinator.animate { _ in
            if self.core != .cytrus {
                self.toggleConstraints()
            }
            self.virtualControllerView.toggleConstraints()
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
        
        // TODO: add constraints
        primaryPortraitTopConstraint = primaryScreen.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        primaryPortraitLeadingConstraint = primaryScreen.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        primaryPortraitTrailingConstraint = primaryScreen.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        primaryPortraitAspectRatioConstraint = primaryScreen.heightAnchor.constraint(equalTo: primaryScreen.widthAnchor, multiplier: (3 / 5) + (3 / 4))
        
        primaryLandscapeTopConstraint = primaryScreen.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        primaryLandscapeBottomConstraint = primaryScreen.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        primaryLandscapeCenterXConstraint = primaryScreen.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        primaryLandscapeAspectRatioConstraint = primaryScreen.widthAnchor.constraint(equalTo: primaryScreen.heightAnchor, multiplier: 4 / 3)
        
        toggleConstraints()
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
        
        view.insertSubview(primaryScreen, belowSubview: virtualControllerView)
        view.insertSubview(visualEffectView, belowSubview: primaryScreen)
        
        // TODO: add constraints
        primaryPortraitTopConstraint = primaryScreen.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        primaryPortraitLeadingConstraint = primaryScreen.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        primaryPortraitTrailingConstraint = primaryScreen.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        primaryPortraitAspectRatioConstraint = primaryScreen.heightAnchor.constraint(equalTo: primaryScreen.widthAnchor, multiplier: 2 / 3)
        
        primaryLandscapeTopConstraint = primaryScreen.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        primaryLandscapeBottomConstraint = primaryScreen.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        primaryLandscapeCenterXConstraint = primaryScreen.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        primaryLandscapeAspectRatioConstraint = primaryScreen.widthAnchor.constraint(equalTo: primaryScreen.heightAnchor, multiplier: 3 / 2)
        
        toggleConstraints()
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
        
        secondaryScreen = MTKView(frame: .zero, device: device)
        secondaryScreen.translatesAutoresizingMaskIntoConstraints = false
        secondaryScreen.clipsToBounds = true
        // (secondaryScreen as! MTKView).delegate = self
        secondaryScreen.layer.borderColor = ScreenConfiguration.borderColor
        secondaryScreen.layer.borderWidth = ScreenConfiguration.borderWidth
        secondaryScreen.layer.cornerCurve = .continuous
        secondaryScreen.layer.cornerRadius = ScreenConfiguration.cornerRadius
        secondaryScreen.isUserInteractionEnabled = true
        view.addSubview(secondaryScreen)
        
        view.insertSubview(primaryScreen, belowSubview: virtualControllerView)
        view.insertSubview(secondaryScreen, belowSubview: virtualControllerView)
        view.insertSubview(visualEffectView, belowSubview: primaryScreen)
        
        // TODO: add constraints
        primaryPortraitTopConstraint = primaryScreen.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        primaryPortraitLeadingConstraint = primaryScreen.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        primaryPortraitTrailingConstraint = primaryScreen.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        primaryPortraitAspectRatioConstraint = primaryScreen.heightAnchor.constraint(equalTo: primaryScreen.widthAnchor, multiplier: 3 / 4)
        
        primaryLandscapeTopConstraint = primaryScreen.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        primaryLandscapeBottomConstraint = primaryScreen.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        primaryLandscapeCenterXConstraint = primaryScreen.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        primaryLandscapeAspectRatioConstraint = primaryScreen.widthAnchor.constraint(equalTo: primaryScreen.heightAnchor, multiplier: 4 / 3)
        
        secondaryPortraitTopConstraint = secondaryScreen.topAnchor.constraint(equalTo: primaryScreen.bottomAnchor, constant: 10)
        secondaryPortraitLeadingConstraint = secondaryScreen.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        secondaryPortraitTrailingConstraint = secondaryScreen.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        secondaryPortraitAspectRatioConstraint = secondaryScreen.heightAnchor.constraint(equalTo: secondaryScreen.widthAnchor, multiplier: 3 / 4)
        
        secondaryLandscapeTopConstraint = secondaryScreen.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        secondaryLandscapeBottomConstraint = secondaryScreen.leadingAnchor.constraint(equalTo: primaryScreen.trailingAnchor, constant: 10)
        secondaryLandscapeCenterXConstraint = secondaryScreen.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        secondaryLandscapeAspectRatioConstraint = secondaryScreen.heightAnchor.constraint(equalTo: secondaryScreen.widthAnchor, multiplier: 3 / 4)
        
        toggleConstraints()
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
        
        view.insertSubview(primaryScreen, belowSubview: virtualControllerView)
        view.insertSubview(visualEffectView, belowSubview: primaryScreen)
        
        // TODO: add constraints
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
    
    override func controllerDidConnect(_ notification: Notification) {
        super.controllerDidConnect(notification)
        controllerConnected = true
        ScreenConfiguration.controllerConnected()
        
        UIView.animate(withDuration: 0.2) {
            self.primaryScreen.update()
        }
    }
    
    override func controllerDidDisconnect(_ notification: Notification) {
        super.controllerDidDisconnect(notification)
        controllerConnected = false
        ScreenConfiguration.controllerDisconnected()
        
        UIView.animate(withDuration: 0.2) {
            self.primaryScreen.update()
        }
    }
    
    fileprivate func toggleConstraints() {
        switch UIApplication.shared.statusBarOrientation {
        case .unknown:
            break
        case .portrait, .portraitUpsideDown:
            togglePrimaryLandscapeConstraints(false)
            togglePrimaryPortraitConstraints(true)
            
            switch game {
            case let grapeGame as GrapeManager.Library.Game:
                if grapeGame.gameType == .nds {
                    toggleSecondaryLandscapeConstraints(false)
                    toggleSecondaryPortraitConstraints(true)
                }
            default:
                break
            }
        case .landscapeLeft, .landscapeRight:
            togglePrimaryLandscapeConstraints(true)
            togglePrimaryPortraitConstraints(false)
            
            switch game {
            case let grapeGame as GrapeManager.Library.Game:
                if grapeGame.gameType == .nds {
                    toggleSecondaryLandscapeConstraints(true)
                    toggleSecondaryPortraitConstraints(false)
                }
            default:
                break
            }
        }
    }
    
    fileprivate func togglePrimaryLandscapeConstraints(_ isActive: Bool) {
        primaryLandscapeTopConstraint.isActive = isActive
        primaryLandscapeBottomConstraint.isActive = isActive
        primaryLandscapeCenterXConstraint.isActive = isActive
        primaryLandscapeAspectRatioConstraint.isActive = isActive
    }
    
    fileprivate func togglePrimaryPortraitConstraints(_ isActive: Bool) {
        primaryPortraitTopConstraint.isActive = isActive
        primaryPortraitLeadingConstraint.isActive = isActive
        primaryPortraitTrailingConstraint.isActive = isActive
        primaryPortraitAspectRatioConstraint.isActive = isActive
    }
    
    fileprivate func toggleSecondaryLandscapeConstraints(_ isActive: Bool) {
        secondaryLandscapeTopConstraint.isActive = isActive
        secondaryLandscapeBottomConstraint.isActive = isActive
        secondaryLandscapeCenterXConstraint.isActive = isActive
        secondaryLandscapeAspectRatioConstraint.isActive = isActive
    }
    
    fileprivate func toggleSecondaryPortraitConstraints(_ isActive: Bool) {
        secondaryPortraitTopConstraint.isActive = isActive
        secondaryPortraitLeadingConstraint.isActive = isActive
        secondaryPortraitTrailingConstraint.isActive = isActive
        secondaryPortraitAspectRatioConstraint.isActive = isActive
    }
}

extension EmulationScreensController : MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    func draw(in view: MTKView) {}
}
