//
//  EmulationController.swift
//  Folium
//
//  Created by Jarrod Norwell on 3/6/2026.
//

/*
import ColourKit
import ConstraintKit
import ExtensionsKit
import FontKit
import MetalKit
import OnboardingKit
import UIKit

import Mandarine

class EmulationController : UIViewController {
    var containerView: UIView? = nil
    var imageView: UIImageView? = nil
    
    var aspectRatio: (lhs: CGFloat, rhs: CGFloat) = (3.0, 4.0)
    
    var settingsButton: UIButton? = nil,
        selectButton: UIButton? = nil,
        startButton: UIButton? = nil
    
    var leftThumbstickView: ThumbstickView? = nil,
        rightThumbstickView: ThumbstickView? = nil
    
    var upButton: UIButton? = nil,
        downButton: UIButton? = nil,
        leftButton: UIButton? = nil,
        rightButton: UIButton? = nil
    
    var crossButton: UIButton? = nil,
        circleButton: UIButton? = nil,
        triangleButton: UIButton? = nil,
        squareButton: UIButton? = nil
    
    var l1Button: UIButton? = nil,
        r1Button: UIButton? = nil,
        l2Button: UIButton? = nil,
        r2Button: UIButton? = nil
    
    var constraints: (portrait: [NSLayoutConstraint], landscape: [NSLayoutConstraint]) = ([], [])
    
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var prefersStatusBarHidden: Bool { true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let isSmallScreen = UIScreen.main.bounds.height < 700
        
        containerView = UIView()
        guard let containerView else {
            return
        }
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        imageView = UIImageView()
        guard let imageView else {
            return
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 26, *) {
            imageView.clipsToBounds = true
            imageView.cornerConfiguration = .corners(radius: .fixed(16.0))
        } else {
            imageView.clipsToBounds = true
            imageView.layer.cornerCurve = .continuous
            imageView.layer.cornerRadius = 16.0
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            containerView.addSubview(imageView)
        } else {
            view.addSubview(imageView)
        }
        
        let stackView: UIStackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.clipsToBounds = false
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        
        var visualEffectView: UIVisualEffectView? = nil
        
        if #available(iOS 26.0, *) {
            let effect: UIGlassContainerEffect = UIGlassContainerEffect()
            effect.spacing = 20
            
            visualEffectView = UIVisualEffectView(effect: effect)
            guard let visualEffectView else {
                return
            }
            visualEffectView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(visualEffectView)
            
            visualEffectView.contentView.addSubview(stackView)
        } else {
            view.addSubview(stackView)
        }
        
        let settingsConfiguration: UIButton.Configuration = .configuration(.medium, .capsule, UIImage(systemName: "ellipsis"), nil, .medium)
        settingsButton = .button(with: settingsConfiguration,
                                 actions: ({ _ in }, { _ in }), UIMenu(preferredElementSize: .medium, children: [
                                    UIDeferredMenuElement.uncached { completion in
                                        completion([
                                            UIAction(title: "Pause",
                                                     image: UIImage(systemName: "pause.fill")) { action in
                                                
                                            },
                                            UIAction(title: "Stop & Exit", image: UIImage(systemName: "stop.fill"), attributes: .destructive) { action in
                                                if let game: Game = self.game {
                                                    Task {
                                                        switch game {
                                                        case let mandarineGame as MandarineGame:
                                                            await mandarineGame.mandarineSystem.stop()
                                                        default:
                                                            break
                                                        }
                                                    }
                                                }
                                                
                                                self.game = nil
                                                
                                                if let tabController: TabController = self.tabBarController as? TabController {
                                                    tabController.game = nil
                                                    
                                                    tabController.selectedIndex = 0
                                                    tabController.switchEmulationController(with: NoEmulationController())
                                                    tabController.switchSettingsSnapshot(for: .application)
                                                }
                                            }
                                         ])
                                    }
                                 ]))
        guard let settingsButton else {
            return
        }
        if visualEffectView == nil {
            view.addSubview(settingsButton)
        }
        
        let selectConfiguration: UIButton.Configuration = .configuration(.medium, .capsule, UIImage(systemName: "minus"), nil, .medium)
        selectButton = .button(with: selectConfiguration, actions: ({ _ in
            self.press(button: .select)
        }, { _ in
            self.release(button: .select)
        }))
        guard let selectButton else {
            return
        }
        if visualEffectView == nil {
            view.addSubview(selectButton)
        }
        
        let startConfiguration: UIButton.Configuration = .configuration(.medium, .capsule, UIImage(systemName: "plus"), nil, .medium)
        startButton = .button(with: startConfiguration, actions: ({ _ in
            self.press(button: .start)
        }, { _ in
            self.release(button: .start)
        }))
        guard let startButton else {
            return
        }
        if visualEffectView == nil {
            view.addSubview(startButton)
        }
        
        leftThumbstickView = ThumbstickView()
        guard let leftThumbstickView else {
            return
        }
        leftThumbstickView.translatesAutoresizingMaskIntoConstraints = false
        leftThumbstickView.label?.text = "L3"
        leftThumbstickView.didClick = {
            self.press(button: .l3)
        }
        leftThumbstickView.didUnclick = {
            self.release(button: .l3)
        }
        leftThumbstickView.didDrag = { point in
            self.drag(thumbstick: .left, value: point)
        }
        leftThumbstickView.didUndrag = {
            self.drag(thumbstick: .left, value: (0, 0))
        }
        view.addSubview(leftThumbstickView)
        
        rightThumbstickView = ThumbstickView()
        guard let rightThumbstickView else {
            return
        }
        rightThumbstickView.translatesAutoresizingMaskIntoConstraints = false
        rightThumbstickView.label?.text = "R3"
        rightThumbstickView.didClick = {
            self.press(button: .r3)
        }
        rightThumbstickView.didUnclick = {
            self.release(button: .r3)
        }
        rightThumbstickView.didDrag = { point in
            self.drag(thumbstick: .right, value: point)
        }
        rightThumbstickView.didUndrag = {
            self.drag(thumbstick: .left, value: (0, 0))
        }
        view.addSubview(rightThumbstickView)
        
        let upConfiguration: UIButton.Configuration = .configuration(isSmallScreen ? .medium : .large, .capsule, UIImage(systemName: "arrowtriangle.up"), nil, isSmallScreen ? .small : .large)
        upButton = .button(with: upConfiguration, actions: ({ _ in
            self.press(button: .up)
        }, { _ in
            self.release(button: .up)
        }))
        guard let upButton else {
            return
        }
        view.addSubview(upButton)
        
        let downConfiguration: UIButton.Configuration = .configuration(isSmallScreen ? .medium : .large, .capsule, UIImage(systemName: "arrowtriangle.down"), nil, isSmallScreen ? .small : .large)
        downButton = .button(with: downConfiguration, actions: ({ _ in
            self.press(button: .down)
        }, { _ in
            self.release(button: .down)
        }))
        guard let downButton else {
            return
        }
        view.addSubview(downButton)
        
        let leftConfiguration: UIButton.Configuration = .configuration(isSmallScreen ? .medium : .large, .capsule, UIImage(systemName: "arrowtriangle.left"), nil, isSmallScreen ? .small : .large)
        leftButton = .button(with: leftConfiguration, actions: ({ _ in
            self.press(button: .left)
        }, { _ in
            self.release(button: .left)
        }))
        guard let leftButton else {
            return
        }
        view.addSubview(leftButton)
        
        let rightConfiguration: UIButton.Configuration = .configuration(isSmallScreen ? .medium : .large, .capsule, UIImage(systemName: "arrowtriangle.right"), nil, isSmallScreen ? .small : .large)
        rightButton = .button(with: rightConfiguration, actions: ({ _ in
            self.press(button: .right)
        }, { _ in
            self.release(button: .right)
        }))
        guard let rightButton else {
            return
        }
        view.addSubview(rightButton)
        
        var crossConfiguration: UIButton.Configuration = .configuration(isSmallScreen ? .medium : .large, .capsule, UIImage(systemName: "xmark"), nil, isSmallScreen ? .small : .large, .systemBlue)
        crossConfiguration.baseForegroundColor = .systemBlue
        crossButton = .button(with: crossConfiguration, actions: ({ _ in
            self.press(button: .cross)
        }, { _ in
            self.release(button: .cross)
        }))
        guard let crossButton else {
            return
        }
        view.addSubview(crossButton)
        
        var circleConfiguration: UIButton.Configuration = .configuration(isSmallScreen ? .medium : .large, .capsule, UIImage(systemName: "circle"), nil, isSmallScreen ? .small : .large, .systemOrange)
        circleConfiguration.baseForegroundColor = .systemOrange
        circleButton = .button(with: circleConfiguration, actions: ({ _ in
            self.press(button: .circle)
        }, { _ in
            self.release(button: .circle)
        }))
        guard let circleButton else {
            return
        }
        view.addSubview(circleButton)
        
        var triangleConfiguration: UIButton.Configuration = .configuration(isSmallScreen ? .medium : .large, .capsule, UIImage(systemName: "triangle"), nil, isSmallScreen ? .small : .large, .systemGreen)
        triangleConfiguration.baseForegroundColor = .systemGreen
        triangleButton = .button(with: triangleConfiguration, actions: ({ _ in
            self.press(button: .triangle)
        }, { _ in
            self.release(button: .triangle)
        }))
        guard let triangleButton else {
            return
        }
        view.addSubview(triangleButton)
        
        var squareConfiguration: UIButton.Configuration = .configuration(isSmallScreen ? .medium : .large, .capsule, UIImage(systemName: "square"), nil, isSmallScreen ? .small : .large, .systemPink)
        squareConfiguration.baseForegroundColor = .systemPink
        squareButton = .button(with: squareConfiguration, actions: ({ _ in
            self.press(button: .square)
        }, { _ in
            self.release(button: .square)
        }))
        guard let squareButton else {
            return
        }
        view.addSubview(squareButton)
        
        let l1Configuration: UIButton.Configuration = .configuration(isSmallScreen ? .medium : .large, .capsule, nil, "L1", isSmallScreen ? .small : .large)
        l1Button = .button(with: l1Configuration, actions: ({ _ in
            self.press(button: .l1)
        }, { _ in
            self.release(button: .l1)
        }))
        guard let l1Button else {
            return
        }
        view.addSubview(l1Button)
        
        let l2Configuration: UIButton.Configuration = .configuration(isSmallScreen ? .medium : .large, .capsule, nil, "L2", isSmallScreen ? .small : .large)
        l2Button = .button(with: l2Configuration, actions: ({ _ in
            self.press(button: .l2)
        }, { _ in
            self.release(button: .l2)
        }))
        guard let l2Button else {
            return
        }
        view.addSubview(l2Button)
        
        let r1Configuration: UIButton.Configuration = .configuration(isSmallScreen ? .medium : .large, .capsule, nil, "R1", isSmallScreen ? .small : .large)
        r1Button = .button(with: r1Configuration, actions: ({ _ in
            self.press(button: .r1)
        }, { _ in
            self.release(button: .r1)
        }))
        guard let r1Button else {
            return
        }
        view.addSubview(r1Button)
        
        let r2Configuration: UIButton.Configuration = .configuration(isSmallScreen ? .medium : .large, .capsule, nil, "R2", isSmallScreen ? .small : .large)
        r2Button = .button(with: r2Configuration, actions: ({ _ in
            self.press(button: .r2)
        }, { _ in
            self.release(button: .r2)
        }))
        guard let r2Button else {
            return
        }
        view.addSubview(r2Button)
        
        if visualEffectView != nil {
            stackView.addArrangedSubview(selectButton)
            stackView.addArrangedSubview(settingsButton)
            stackView.addArrangedSubview(startButton)
        }
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            constraints.portrait.append(contentsOf: [
                imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                               constant: 20.0),
                imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                   constant: 20.0),
                imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                    constant: -20.0),
                imageView.heightAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.widthAnchor,
                                                  multiplier: aspectRatio.lhs / aspectRatio.rhs),
                
                crossButton.bottomAnchor.constraint(equalTo: (visualEffectView ?? startButton).safeAreaLayoutGuide.topAnchor),
                crossButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                circleButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                circleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                       constant: -20),
                
                triangleButton.bottomAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.topAnchor),
                triangleButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                squareButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                squareButton.trailingAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.leadingAnchor),
                
                rightThumbstickView.topAnchor.constraint(equalTo: triangleButton.safeAreaLayoutGuide.topAnchor),
                rightThumbstickView.leadingAnchor.constraint(equalTo: squareButton.safeAreaLayoutGuide.leadingAnchor),
                rightThumbstickView.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.bottomAnchor),
                rightThumbstickView.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.trailingAnchor),
                
                upButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                upButton.bottomAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.topAnchor),
                
                leftButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                    constant: 20),
                leftButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                downButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                downButton.bottomAnchor.constraint(equalTo: selectButton.safeAreaLayoutGuide.topAnchor),
                
                rightButton.leadingAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.trailingAnchor),
                rightButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                leftThumbstickView.topAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor),
                leftThumbstickView.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.leadingAnchor),
                leftThumbstickView.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.bottomAnchor),
                leftThumbstickView.trailingAnchor.constraint(equalTo: rightButton.safeAreaLayoutGuide.trailingAnchor),
                
                l1Button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                  constant: 20),
                l1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //l1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l1Button.widthAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                l2Button.leadingAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.trailingAnchor,
                                                  constant: 20),
                l2Button.centerYAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.centerYAnchor),
                //l2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l2Button.widthAnchor.constraint(equalTo: l2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r1Button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                   constant: -20),
                r1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //r1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r1Button.widthAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r2Button.trailingAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.leadingAnchor,
                                                   constant: -20),
                r2Button.centerYAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.centerYAnchor),
                //r2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r2Button.widthAnchor.constraint(equalTo: r2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2)
            ])
            
            if let visualEffectView {
                constraints.portrait.append(contentsOf: [
                    stackView.centerX.constraint(equalTo: view.safeAreaLayoutGuide.centerX),
                    stackView.bottom.constraint(equalTo: view.safeAreaLayoutGuide.bottom, constant: -20.0),
                    
                    visualEffectView.top.constraint(equalTo: stackView.safeAreaLayoutGuide.top),
                    visualEffectView.left.constraint(equalTo: stackView.safeAreaLayoutGuide.left),
                    visualEffectView.bottom.constraint(equalTo: stackView.safeAreaLayoutGuide.bottom),
                    visualEffectView.right.constraint(equalTo: stackView.safeAreaLayoutGuide.right)
                ])
            } else {
                constraints.portrait.append(contentsOf: [
                    settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                           constant: -20.0),
                    settingsButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                    
                    selectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                         constant: -20.0),
                    selectButton.trailingAnchor.constraint(equalTo: settingsButton.safeAreaLayoutGuide.leadingAnchor,
                                                           constant: -20.0),
                    
                    startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                        constant: -20.0),
                    startButton.leadingAnchor.constraint(equalTo: settingsButton.safeAreaLayoutGuide.trailingAnchor,
                                                         constant: 20.0)
                ])
            }
            
            let landscapeBottomConstraint: NSLayoutAnchor = if let visualEffectView {
                visualEffectView.safeAreaLayoutGuide.bottom
            } else {
                startButton.safeAreaLayoutGuide.top
            }
            
            constraints.landscape.append(contentsOf: [
                imageView.topAnchor.constraint(equalTo: view.topAnchor,
                                               constant: 20.0),
                imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                  constant: -20.0),
                imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                imageView.widthAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.heightAnchor,
                                                 multiplier: aspectRatio.rhs / aspectRatio.lhs),
                
                crossButton.bottomAnchor.constraint(equalTo: landscapeBottomConstraint,
                                                    constant: visualEffectView == nil ? -20.0 : 0.0),
                crossButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                circleButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                circleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                       constant: -20),
                
                triangleButton.bottomAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.topAnchor),
                triangleButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                squareButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                squareButton.trailingAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.leadingAnchor),
                
                rightThumbstickView.topAnchor.constraint(equalTo: triangleButton.safeAreaLayoutGuide.topAnchor),
                rightThumbstickView.leadingAnchor.constraint(equalTo: squareButton.safeAreaLayoutGuide.leadingAnchor),
                rightThumbstickView.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.bottomAnchor),
                rightThumbstickView.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.trailingAnchor),
                
                upButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                upButton.bottomAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.topAnchor),
                
                leftButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                    constant: 20),
                leftButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                downButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                downButton.bottomAnchor.constraint(equalTo: landscapeBottomConstraint,
                                                   constant: visualEffectView == nil ? -20.0 : 0.0),
                
                rightButton.leadingAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.trailingAnchor),
                rightButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                leftThumbstickView.topAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor),
                leftThumbstickView.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.leadingAnchor),
                leftThumbstickView.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.bottomAnchor),
                leftThumbstickView.trailingAnchor.constraint(equalTo: rightButton.safeAreaLayoutGuide.trailingAnchor),
                
                l1Button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30.0),
                l1Button.topAnchor.constraint(equalTo: view.topAnchor, constant: 30.0),
                //l1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l1Button.widthAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                l2Button.leadingAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.trailingAnchor,
                                                  constant: 20),
                l2Button.centerYAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.centerYAnchor),
                //l2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l2Button.widthAnchor.constraint(equalTo: l2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r1Button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30.0),
                r1Button.topAnchor.constraint(equalTo: view.topAnchor, constant: 30.0),
                //r1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r1Button.widthAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r2Button.trailingAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.leadingAnchor,
                                                   constant: -20),
                r2Button.centerYAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.centerYAnchor),
                //r2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r2Button.widthAnchor.constraint(equalTo: r2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2)
            ])
            
            if let visualEffectView {
                constraints.landscape.append(contentsOf: [
                    stackView.centerX.constraint(equalTo: view.safeAreaLayoutGuide.centerX),
                    stackView.bottom.constraint(equalTo: view.safeAreaLayoutGuide.bottom, constant: -20.0),
                    
                    visualEffectView.top.constraint(equalTo: stackView.safeAreaLayoutGuide.top),
                    visualEffectView.left.constraint(equalTo: stackView.safeAreaLayoutGuide.left),
                    visualEffectView.bottom.constraint(equalTo: stackView.safeAreaLayoutGuide.bottom),
                    visualEffectView.right.constraint(equalTo: stackView.safeAreaLayoutGuide.right)
                ])
            } else {
                constraints.landscape.append(contentsOf: [
                    settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                           constant: -20.0),
                    settingsButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                    
                    startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                        constant: -20.0),
                    startButton.leadingAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.trailingAnchor,
                                                         constant: 20),
                    
                    selectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                         constant: -20.0),
                    selectButton.trailingAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.leadingAnchor,
                                                           constant: -20.0)
                ])
            }
        } else {
            constraints.portrait.append(contentsOf: [
                containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                containerView.bottomAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.topAnchor, constant: -20),
                containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                
                imageView.centerXAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerYAnchor),
                imageView.widthAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.widthAnchor, constant: -40.0),
                imageView.heightAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.widthAnchor,
                                                  multiplier: aspectRatio.lhs / aspectRatio.rhs),
                
                settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                       constant: -20.0),
                settingsButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                
                selectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                     constant: -20.0),
                selectButton.trailingAnchor.constraint(equalTo: settingsButton.safeAreaLayoutGuide.leadingAnchor,
                                                       constant: -20.0),
                
                startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                    constant: -20.0),
                startButton.leadingAnchor.constraint(equalTo: settingsButton.safeAreaLayoutGuide.trailingAnchor,
                                                     constant: 20.0),
                
                crossButton.bottomAnchor.constraint(equalTo: startButton.safeAreaLayoutGuide.topAnchor),
                crossButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                circleButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                circleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                       constant: -20),
                
                triangleButton.bottomAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.topAnchor),
                triangleButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                squareButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                squareButton.trailingAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.leadingAnchor),
                
                rightThumbstickView.topAnchor.constraint(equalTo: triangleButton.safeAreaLayoutGuide.topAnchor),
                rightThumbstickView.leadingAnchor.constraint(equalTo: squareButton.safeAreaLayoutGuide.leadingAnchor),
                rightThumbstickView.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.bottomAnchor),
                rightThumbstickView.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.trailingAnchor),
                
                upButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                upButton.bottomAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.topAnchor),
                
                leftButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                    constant: 20),
                leftButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                downButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                downButton.bottomAnchor.constraint(equalTo: selectButton.safeAreaLayoutGuide.topAnchor),
                
                rightButton.leadingAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.trailingAnchor),
                rightButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                leftThumbstickView.topAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor),
                leftThumbstickView.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.leadingAnchor),
                leftThumbstickView.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.bottomAnchor),
                leftThumbstickView.trailingAnchor.constraint(equalTo: rightButton.safeAreaLayoutGuide.trailingAnchor),
                
                l1Button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                  constant: 20),
                l1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //l1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l1Button.widthAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                l2Button.leadingAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.trailingAnchor,
                                                  constant: 20),
                l2Button.centerYAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.centerYAnchor),
                //l2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l2Button.widthAnchor.constraint(equalTo: l2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r1Button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                   constant: -20),
                r1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //r1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r1Button.widthAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r2Button.trailingAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.leadingAnchor,
                                                   constant: -20),
                r2Button.centerYAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.centerYAnchor),
                //r2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r2Button.widthAnchor.constraint(equalTo: r2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2)
            ])
            
            constraints.landscape.append(contentsOf: [
                containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                containerView.bottomAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.topAnchor, constant: -20),
                containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                
                imageView.centerXAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerXAnchor),
                imageView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor,
                                               constant: 20),
                imageView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor,
                                                  constant: -20),
                imageView.widthAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.heightAnchor,
                                                 multiplier: aspectRatio.rhs / aspectRatio.lhs),
                
                crossButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                    constant: -20),
                crossButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                circleButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                circleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                       constant: -20),
                
                triangleButton.bottomAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.topAnchor),
                triangleButton.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.leadingAnchor),
                
                squareButton.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.topAnchor),
                squareButton.trailingAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.leadingAnchor),
                
                rightThumbstickView.topAnchor.constraint(equalTo: triangleButton.safeAreaLayoutGuide.topAnchor),
                rightThumbstickView.leadingAnchor.constraint(equalTo: squareButton.safeAreaLayoutGuide.leadingAnchor),
                rightThumbstickView.bottomAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.bottomAnchor),
                rightThumbstickView.trailingAnchor.constraint(equalTo: circleButton.safeAreaLayoutGuide.trailingAnchor),
                
                upButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                upButton.bottomAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.topAnchor),
                
                leftButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                    constant: 20),
                leftButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                downButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                downButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                   constant: -20),
                
                rightButton.leadingAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.trailingAnchor),
                rightButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                leftThumbstickView.topAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor),
                leftThumbstickView.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.leadingAnchor),
                leftThumbstickView.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.bottomAnchor),
                leftThumbstickView.trailingAnchor.constraint(equalTo: rightButton.safeAreaLayoutGuide.trailingAnchor),
                
                l1Button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                  constant: 20),
                l1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //l1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l1Button.widthAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                l2Button.leadingAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.trailingAnchor,
                                                  constant: 20),
                l2Button.centerYAnchor.constraint(equalTo: l1Button.safeAreaLayoutGuide.centerYAnchor),
                //l2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                l2Button.widthAnchor.constraint(equalTo: l2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r1Button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                   constant: -20),
                r1Button.bottomAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor,
                                                 constant: -20),
                //r1Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r1Button.widthAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                r2Button.trailingAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.leadingAnchor,
                                                   constant: -20),
                r2Button.centerYAnchor.constraint(equalTo: r1Button.safeAreaLayoutGuide.centerYAnchor),
                //r2Button.heightAnchor.constraint(equalTo: crossButton.safeAreaLayoutGuide.heightAnchor),
                r2Button.widthAnchor.constraint(equalTo: r2Button.safeAreaLayoutGuide.heightAnchor,
                                                multiplier: 3 / 2),
                
                settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                       constant: -20.0),
                settingsButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                
                startButton.topAnchor.constraint(equalTo: triangleButton.safeAreaLayoutGuide.topAnchor),
                startButton.trailingAnchor.constraint(equalTo: squareButton.safeAreaLayoutGuide.leadingAnchor),
                
                selectButton.topAnchor.constraint(equalTo: upButton.safeAreaLayoutGuide.topAnchor),
                selectButton.leadingAnchor.constraint(equalTo: rightButton.safeAreaLayoutGuide.trailingAnchor)
            ])
        }
        
#if targetEnvironment(simulator)
        view.addConstraints(constraints.portrait)
#else
        var windowScene: UIWindowScene? = nil
        if let window: UIWindow = view.window, let currentWindowScene: UIWindowScene = window.windowScene {
            windowScene = currentWindowScene
        } else if let currentWindowScene: UIWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene = currentWindowScene
        } else {
            windowScene = nil
        }
        
        guard let windowScene: UIWindowScene else {
            view.addConstraints(constraints.portrait)
            return
        }
        
        if windowScene.effectiveGeometry.interfaceOrientation.isPortrait {
            view.addConstraints(constraints.portrait)
        } else {
            view.addConstraints(constraints.landscape)
        }
#endif
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        var windowScene: UIWindowScene? = nil
        if let window: UIWindow = view.window, let currentWindowScene: UIWindowScene = window.windowScene {
            windowScene = currentWindowScene
        } else if let currentWindowScene: UIWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene = currentWindowScene
        } else {
            windowScene = nil
        }
        
        guard let windowScene: UIWindowScene else {
            return
        }
        
        guard let tabController: TabController = tabBarController as? TabController else {
            return
        }
        
        coordinator.animate { context in } completion: { context in
            switch windowScene.effectiveGeometry.interfaceOrientation {
            case .portrait:
                tabController.setTabBarHidden(false, animated: true)
                
                self.view.removeConstraints(self.constraints.landscape)
                self.view.addConstraints(self.constraints.portrait)
            case .landscapeLeft, .landscapeRight:
                tabController.setTabBarHidden(true, animated: true)
                
                self.view.removeConstraints(self.constraints.portrait)
                self.view.addConstraints(self.constraints.landscape)
            default:
                break
            }
            
            self.view.setNeedsUpdateConstraints()
        }
    }
    
    var game: Game? = nil
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarItem.badgeValue = nil
        if let tabController: TabController = tabBarController as? TabController {
            game = tabController.game
        }
        
        var windowScene: UIWindowScene? = nil
        if let window: UIWindow = view.window, let currentWindowScene: UIWindowScene = window.windowScene {
            windowScene = currentWindowScene
        } else if let currentWindowScene: UIWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene = currentWindowScene
        } else {
            windowScene = nil
        }
        
        guard let windowScene: UIWindowScene else {
            return
        }
        
        guard let tabController: TabController = tabBarController as? TabController else {
            return
        }
        
        tabController.setTabBarHidden(windowScene.effectiveGeometry.interfaceOrientation.isLandscape, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let game: Game else {
            return
        }
        
        Task {
            switch game {
            case let mandarineGame as MandarineGame:
                if await mandarineGame.mandarineSystem.running {
                    return
                }
                
                await mandarineGame.mandarineSystem.insertDisc(at: mandarineGame.details.url)
                
                await mandarineGame.mandarineSystem.set(change: true, isRunning: true)
                
                await mandarineGame.mandarineSystem.setContext(context: Unmanaged.passUnretained(self).toOpaque())
                mandarineGame.mandarineSystem.videoBuffer15Bit { context, pointer in
                    guard let context, let pointer else {
                        return
                    }
                    
                    let viewController: EmulationController = Unmanaged<EmulationController>.fromOpaque(context).takeUnretainedValue()
                    
                    guard let imageView: UIImageView = viewController.imageView,
                          let game: MandarineGame = viewController.game as? MandarineGame else {
                        return
                    }
                    
                    let cgImage: CGImage? = CGImage.mandarine15Bit(pointer, 1024, 512)
                    
                    Task { @MainActor in
                        let height: Int32 = await game.mandarineSystem.framebufferHeight
                        let width: Int32 = await game.mandarineSystem.framebufferWidth
                        
                        guard let cgImage,
                              let cropped: CGImage = cgImage.cropping(to: CGRectMake(CGFloat(await game.mandarineSystem.framebufferStartX),
                                                                                     CGFloat(await game.mandarineSystem.framebufferStartY),
                                                                                     CGFloat(width),
                                                                                     CGFloat(height))) else {
                            return
                        }
                        
                        imageView.image = UIImage(cgImage: cropped)
                    }
                }
                
                mandarineGame.mandarineSystem.videoBuffer24Bit { context, pointer in
                    guard let context, let pointer else {
                        return
                    }
                    
                    let viewController: EmulationController = Unmanaged<EmulationController>.fromOpaque(context).takeUnretainedValue()
                    
                    guard let imageView: UIImageView = viewController.imageView,
                          let game: MandarineGame = viewController.game as? MandarineGame else {
                        return
                    }
                    
                    let cgImage: CGImage? = CGImage.mandarine24Bit(pointer, 1024, 512)
                    
                    Task { @MainActor in
                        let height: Int32 = await game.mandarineSystem.framebufferHeight
                        let width: Int32 = await game.mandarineSystem.framebufferWidth
                        
                        guard let cgImage,
                              let cropped: CGImage = cgImage.cropping(to: CGRectMake(CGFloat(await game.mandarineSystem.framebufferStartX),
                                                                                     CGFloat(await game.mandarineSystem.framebufferStartY),
                                                                                     CGFloat(width),
                                                                                     CGFloat(height))) else {
                            return
                        }
                        
                        imageView.image = UIImage(cgImage: cropped)
                    }
                }
                
                await mandarineGame.mandarineSystem.start()
            default:
                break
            }
        }
    }
    
    func press(button: MandarineButton) {
        guard let game: Game else {
            return
        }
        
        switch game {
        case let mandarineGame as MandarineGame:
            mandarineGame.mandarineSystem.press(button: button)
        default:
            break
        }
    }
    
    func release(button: MandarineButton) {
        guard let game: Game else {
            return
        }
        
        switch game {
        case let mandarineGame as MandarineGame:
            mandarineGame.mandarineSystem.release(button: button)
        default:
            break
        }
    }
    
    func drag(thumbstick: ThumbstickPlacement, value: (x: UInt8, y: UInt8)) {
        guard let game: Game else {
            return
        }
        
        switch game {
        case let mandarineGame as MandarineGame:
            let prefix = thumbstick == .left ? "l" : "r"

            let x = Int(value.x) - 127
            let y = Int(value.y) - 127

            if x < 0 {
                mandarineGame.mandarineSystem.drag(thumbstick: "\(prefix)_left", value: UInt8(abs(x)))
            } else if x > 0 {
                mandarineGame.mandarineSystem.drag(thumbstick: "\(prefix)_right", value: UInt8(x))
            } else {
                mandarineGame.mandarineSystem.drag(thumbstick: "\(prefix)_left", value: 0)
                mandarineGame.mandarineSystem.drag(thumbstick: "\(prefix)_right", value: 0)
            }

            if y < 0 {
                mandarineGame.mandarineSystem.drag(thumbstick: "\(prefix)_up", value: UInt8(abs(y)))
            } else if y > 0 {
                mandarineGame.mandarineSystem.drag(thumbstick: "\(prefix)_down", value: UInt8(y))
            } else {
                mandarineGame.mandarineSystem.drag(thumbstick: "\(prefix)_up", value: 0)
                mandarineGame.mandarineSystem.drag(thumbstick: "\(prefix)_down", value: 0)
            }
        default:
            break
        }
    }
    
    enum Direction {
        case up
        case down
        case left
        case right
        case upLeft
        case upRight
        case downLeft
        case downRight
        case center
    }

    func direction(x: UInt8, y: UInt8) -> Direction {
        let threshold = 0

        let x = Int(x) - 127
        let y = Int(y) - 127

        switch (x, y) {
        case let (x, y) where abs(x) < threshold && abs(y) < threshold:
            return .center

        case let (x, y) where abs(x) < threshold && y < -threshold:
            return .up

        case let (x, y) where abs(x) < threshold && y > threshold:
            return .down

        case let (x, y) where x > threshold && abs(y) < threshold:
            return .right

        case let (x, y) where x < -threshold && abs(y) < threshold:
            return .left

        case let (x, y) where x < -threshold && y < -threshold:
            return .upLeft

        case let (x, y) where x > threshold && y < -threshold:
            return .upRight

        case let (x, y) where x < -threshold && y > threshold:
            return .downLeft

        case let (x, y) where x > threshold && y > threshold:
            return .downRight

        default:
            return .center
        }
    }
}
*/
