//
//  GrapeController.swift
//  Folium
//
//  Created by Jarrod Norwell on 23/6/2026.
//

import ConstraintKit
import ExtensionsKit
import FontKit
import UIKit

import Grape

class GrapeController : ControlsController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView = UIStackView()
        guard let stackView: UIStackView else {
            return
        }
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 20.0
        view.addSubview(stackView)
        
        var settingsConfiguration: UIButton.Configuration = UIButton.Configuration.glass()
        settingsConfiguration.buttonSize = .medium
        settingsConfiguration.cornerStyle = .capsule
        settingsConfiguration.image = UIImage(systemName: "ellipsis")?
            .applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .medium))
        
        settingsButton = .button(with: settingsConfiguration,
                                 actions: ({ _ in }, { _ in }), UIMenu(preferredElementSize: .medium, children: [
                                    UIDeferredMenuElement.uncached { completion in
                                        guard let grapeGame: GrapeGame = self.game as? GrapeGame else {
                                            completion([])
                                            return
                                        }
                                        
                                        Task {
                                            completion([
                                                UIAction.async(title: await grapeGame.grapeSystem.paused ? "Resume" : "Pause",
                                                               image: UIImage(systemName: await grapeGame.grapeSystem.paused ? "play.fill" : "pause.fill")) { action in
                                                                   if await grapeGame.grapeSystem.paused {
                                                                       await grapeGame.grapeSystem.set(change: true, isPaused: false)
                                                                   } else {
                                                                       await grapeGame.grapeSystem.set(change: true, isPaused: true)
                                                                   }
                                                },
                                                UIAction.async(title: "Stop & Exit", image: UIImage(systemName: "stop.fill"), attributes: .destructive) { action in
                                                    await grapeGame.grapeSystem.stop()
                                                    
                                                    self.game = nil
                                                    
                                                    if let tabController: TabController = self.tabBarController as? TabController {
                                                        tabController.game = nil
                                                        
                                                        tabController.selectedIndex = .gamesController
                                                        tabController.switchEmulationController(with: NoEmulationController())
                                                        tabController.switchSettingsSnapshot(for: .application)
                                                    }
                                                }
                                             ])
                                        }
                                    }
                                 ]))
        guard let settingsButton else {
            return
        }
        
        var selectConfiguration: UIButton.Configuration = UIButton.Configuration.glass()
        selectConfiguration.buttonSize = .medium
        selectConfiguration.cornerStyle = .capsule
        selectConfiguration.image = UIImage(systemName: "minus")?
            .applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .medium))
        
        selectButton = .button(with: selectConfiguration, actions: ({ _ in
            self.press(button: .select)
        }, { _ in
            self.release(button: .select)
        }))
        guard let selectButton else {
            return
        }
        
        var startConfiguration: UIButton.Configuration = UIButton.Configuration.glass()
        startConfiguration.buttonSize = .medium
        startConfiguration.cornerStyle = .capsule
        startConfiguration.image = UIImage(systemName: "plus")?
            .applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .medium))
        
        startButton = .button(with: startConfiguration, actions: ({ _ in
            self.press(button: .start)
        }, { _ in
            self.release(button: .start)
        }))
        guard let startButton else {
            return
        }
        
        let upConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "chevron.up"), nil, .large)
        upButton = .button(with: upConfiguration, actions: ({ _ in
            self.press(button: .up)
        }, { _ in
            self.release(button: .up)
        }))
        guard let upButton else {
            return
        }
        view.addSubview(upButton)
        
        let downConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "chevron.down"), nil, .large)
        downButton = .button(with: downConfiguration, actions: ({ _ in
            self.press(button: .down)
        }, { _ in
            self.release(button: .down)
        }))
        guard let downButton else {
            return
        }
        view.addSubview(downButton)
        
        let leftConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "chevron.left"), nil, .large)
        leftButton = .button(with: leftConfiguration, actions: ({ _ in
            self.press(button: .left)
        }, { _ in
            self.release(button: .left)
        }))
        guard let leftButton else {
            return
        }
        view.addSubview(leftButton)
        
        let rightConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "chevron.right"), nil, .large)
        rightButton = .button(with: rightConfiguration, actions: ({ _ in
            self.press(button: .right)
        }, { _ in
            self.release(button: .right)
        }))
        guard let rightButton else {
            return
        }
        view.addSubview(rightButton)
        
        let southConfiguration: UIButton.Configuration = .configuration(.large, .capsule, nil, "B", .large, .systemYellow)
        southButton = .button(with: southConfiguration, actions: ({ _ in
            self.press(button: .b)
        }, { _ in
            self.release(button: .b)
        }))
        guard let southButton else {
            return
        }
        view.addSubview(southButton)
        
        let eastConfiguration: UIButton.Configuration = .configuration(.large, .capsule, nil, "A", .large, .systemRed)
        eastButton = .button(with: eastConfiguration, actions: ({ _ in
            self.press(button: .a)
        }, { _ in
            self.release(button: .a)
        }))
        guard let eastButton else {
            return
        }
        view.addSubview(eastButton)
        
        let northConfiguration: UIButton.Configuration = .configuration(.large, .capsule, nil, "X", .large, .systemBlue)
        northButton = .button(with: northConfiguration, actions: ({ _ in
            self.press(button: .x)
        }, { _ in
            self.release(button: .x)
        }))
        guard let northButton else {
            return
        }
        view.addSubview(northButton)
        
        let westConfiguration: UIButton.Configuration = .configuration(.large, .capsule, nil, "Y", .large, .systemGreen)
        westButton = .button(with: westConfiguration, actions: ({ _ in
            self.press(button: .y)
        }, { _ in
            self.release(button: .y)
        }))
        guard let westButton else {
            return
        }
        view.addSubview(westButton)
        
        let l1Configuration: UIButton.Configuration = .configuration(.large, .capsule, nil, "L", .large)
        l1Button = .button(with: l1Configuration, actions: ({ _ in
            self.press(button: .l)
        }, { _ in
            self.release(button: .l)
        }))
        guard let l1Button else {
            return
        }
        view.addSubview(l1Button)
        
        let r1Configuration: UIButton.Configuration = .configuration(.large, .capsule, nil, "R", .large)
        r1Button = .button(with: r1Configuration, actions: ({ _ in
            self.press(button: .r)
        }, { _ in
            self.release(button: .r)
        }))
        guard let r1Button else {
            return
        }
        view.addSubview(r1Button)
        
        stackView.addArrangedSubview(selectButton)
        stackView.addArrangedSubview(settingsButton)
        stackView.addArrangedSubview(startButton)
        
        switch system {
        case .grape:
            configureConstraintsForGrape()
            reconfigureConstraintsForGrape()
        default:
            break
        }
        configureCommonConstraints()
        
        let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
#if targetEnvironment(simulator)
        view.addConstraints(isPad ? constraints.pad.portrait : constraints.phone.portrait)
#else
        guard let windowScene: UIWindowScene else {
            view.addConstraints(isPad ? constraints.pad.portrait : constraints.phone.portrait)
            return
        }
        
        if windowScene.effectiveGeometry.interfaceOrientation.isPortrait {
            view.addConstraints(isPad ? constraints.pad.portrait : constraints.phone.portrait)
        } else {
            view.addConstraints(isPad ? constraints.pad.landscape : constraints.phone.landscape)
        }
#endif
        view.addConstraints(commonConstraints)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let grapeGame: GrapeGame = game as? GrapeGame else {
            return
        }
        
        Task {
            if await grapeGame.grapeSystem.running {
                return
            }
            
            await grapeGame.grapeSystem.insertDisc(at: grapeGame.details.url)
            
            await grapeGame.grapeSystem.set(change: true, isRunning: true)
            
            await grapeGame.grapeSystem.setContext(context: Unmanaged.passUnretained(self).toOpaque())
            grapeGame.grapeSystem.videoBuffer { context, primaryPointer, secondaryPointer in
                guard let context, let primaryPointer, let secondaryPointer else {
                    return
                }
                
                let viewController: GrapeController = Unmanaged<GrapeController>.fromOpaque(context).takeUnretainedValue()
                
                guard let imageView: UIImageView = viewController.primaryRenderingView as? UIImageView,
                      let secondaryImageView: UIImageView = viewController.primaryBackgroundRenderingView as? UIImageView,
                      let tertiaryImageView: UIImageView = viewController.secondaryRenderingView as? UIImageView,
                      let quaternaryImageView: UIImageView = viewController.secondaryBackgroundRenderingView as? UIImageView,
                      let game: GrapeGame = viewController.game as? GrapeGame else {
                    return
                }
                
                Task { @MainActor in
                    let height: Int32 = await game.grapeSystem.framebufferHeight
                    let width: Int32 = await game.grapeSystem.framebufferWidth
                    
                    let primaryCGImage: CGImage? = CGImage.grape(primaryPointer, Int(width), Int(height))
                    let secondaryCGImage: CGImage? = CGImage.grape(secondaryPointer, Int(width), Int(height))
                    
                    guard let primaryCGImage: CGImage, let secondaryCGImage: CGImage else {
                        return
                    }
                    
                    imageView.image = UIImage(cgImage: primaryCGImage)
                    secondaryImageView.image = imageView.image
                    
                    tertiaryImageView.image = UIImage(cgImage: secondaryCGImage)
                    quaternaryImageView.image = tertiaryImageView.image
                }
            }
            
            await grapeGame.grapeSystem.start()
        }
    }
    
    func press(button: GrapeButton) {
        guard let grapeGame: GrapeGame = game as? GrapeGame else {
            return
        }
        
        press(button: button, using: grapeGame.grapeSystem)
    }
    
    func release(button: GrapeButton) {
        guard let grapeGame: GrapeGame = game as? GrapeGame else {
            return
        }
        
        release(button: button, using: grapeGame.grapeSystem)
    }
}

extension GrapeController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let grapeGame: GrapeGame = game as? GrapeGame else {
            return
        }
        
        guard let secondaryRenderingView: UIView, let touch = touches.first, touch.view == secondaryRenderingView else {
            return
        }
        
        let locationInView = touch.location(in: secondaryRenderingView)
        let viewSize = secondaryRenderingView.frame.size
        
        let mappedX = (locationInView.x / viewSize.width) * 256
        let mappedY = (locationInView.y / viewSize.height) * 192
        
        Task {
            await grapeGame.grapeSystem.touchBegan(x: UInt16(mappedX), y: UInt16(mappedY))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let grapeGame: GrapeGame = game as? GrapeGame else {
            return
        }
        
        Task {
            await grapeGame.grapeSystem.touchEnded()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let grapeGame: GrapeGame = game as? GrapeGame else {
            return
        }
        
        guard let secondaryRenderingView: UIView, let touch = touches.first, touch.view == secondaryRenderingView else {
            return
        }
        
        let locationInView = touch.location(in: secondaryRenderingView)
        let viewSize = secondaryRenderingView.frame.size
        
        let mappedX = (locationInView.x / viewSize.width) * 256
        let mappedY = (locationInView.y / viewSize.height) * 192
        
        Task {
            await grapeGame.grapeSystem.touchMoved(x: UInt16(mappedX), y: UInt16(mappedY))
        }
    }
}

extension GrapeController {
    func reconfigureConstraintsForGrape() {
        guard let stackView: UIStackView,
              let selectButton: UIButton, let startButton: UIButton,
              let upButton: UIButton, let downButton: UIButton, let leftButton: UIButton, let rightButton: UIButton,
              let southButton: UIButton, let eastButton: UIButton, let northButton: UIButton, let westButton: UIButton,
              let l1Button: UIButton, let r1Button: UIButton else {
            return
        }
        
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            constraints.pad.portrait.append(contentsOf: [
                southButton.bottom.constraint(equalTo: startButton.salg.top),
                southButton.right.constraint(equalTo: eastButton.salg.left),
                
                eastButton.bottom.constraint(equalTo: southButton.salg.top),
                eastButton.right.constraint(equalTo: view.salg.right, constant: -20.0),
                
                northButton.bottom.constraint(equalTo: eastButton.salg.top),
                northButton.right.constraint(equalTo: eastButton.salg.left),
                
                westButton.bottom.constraint(equalTo: southButton.salg.top),
                westButton.right.constraint(equalTo: southButton.salg.left),
                
                upButton.left.constraint(equalTo: leftButton.salg.right),
                upButton.bottom.constraint(equalTo: leftButton.salg.top),
                
                leftButton.left.constraint(equalTo: view.salg.left, constant: 20.0),
                leftButton.bottom.constraint(equalTo: downButton.salg.top),
                
                downButton.left.constraint(equalTo: leftButton.salg.right),
                downButton.bottom.constraint(equalTo: selectButton.salg.top),
                
                rightButton.left.constraint(equalTo: downButton.salg.right),
                rightButton.bottom.constraint(equalTo: downButton.salg.top),
                
                l1Button.left.constraint(equalTo: view.salg.left, constant: 20.0),
                l1Button.bottom.constraint(equalTo: upButton.salg.top, constant: -20.0),
                l1Button.width.constraint(equalTo: l1Button.salg.height, multiplier: 3.0 / 2.0),
                
                r1Button.right.constraint(equalTo: view.salg.right, constant: -20.0),
                r1Button.bottom.constraint(equalTo: upButton.salg.top, constant: -20.0),
                r1Button.width.constraint(equalTo: r1Button.salg.height, multiplier: 3.0 / 2.0),
                
                stackView.bottom.constraint(equalTo: view.salg.bottom, constant: -20.0),
                stackView.centerX.constraint(equalTo: view.salg.centerX)
            ])
            
            constraints.pad.landscape.append(contentsOf: [
                southButton.bottom.constraint(equalTo: stackView.salg.bottom),
                southButton.right.constraint(equalTo: eastButton.salg.left),
                
                eastButton.bottom.constraint(equalTo: southButton.salg.top),
                eastButton.right.constraint(equalTo: view.salg.right, constant: -20.0),
                
                northButton.bottom.constraint(equalTo: eastButton.salg.top),
                northButton.right.constraint(equalTo: eastButton.salg.left),
                
                westButton.bottom.constraint(equalTo: southButton.salg.top),
                westButton.right.constraint(equalTo: southButton.salg.left),
                
                upButton.left.constraint(equalTo: leftButton.salg.right),
                upButton.bottom.constraint(equalTo: leftButton.salg.top),
                
                leftButton.left.constraint(equalTo: view.salg.left, constant: 20.0),
                leftButton.bottom.constraint(equalTo: downButton.salg.top),
                
                downButton.left.constraint(equalTo: leftButton.salg.right),
                downButton.bottom.constraint(equalTo: stackView.salg.bottom),
                
                rightButton.left.constraint(equalTo: downButton.salg.right),
                rightButton.bottom.constraint(equalTo: downButton.salg.top),
                
                l1Button.bottom.constraint(equalTo: upButton.salg.top, constant: -20.0),
                l1Button.left.constraint(equalTo: view.salg.left, constant: 20.0),
                l1Button.width.constraint(equalTo: l1Button.salg.height, multiplier: 3.0 / 2.0),
                
                r1Button.bottom.constraint(equalTo: northButton.salg.top, constant: -20.0),
                r1Button.right.constraint(equalTo: view.salg.right, constant: -20.0),
                r1Button.width.constraint(equalTo: r1Button.salg.height, multiplier: 3.0 / 2.0),
                
                stackView.bottom.constraint(equalTo: view.salg.bottom, constant: -20.0),
                stackView.centerX.constraint(equalTo: view.salg.centerX)
            ])
        } else {
            constraints.phone.portrait.append(contentsOf: [
                southButton.bottom.constraint(equalTo: startButton.salg.top),
                southButton.right.constraint(equalTo: eastButton.salg.left),
                
                eastButton.bottom.constraint(equalTo: southButton.salg.top),
                eastButton.right.constraint(equalTo: view.salg.right, constant: -20.0),
                
                northButton.bottom.constraint(equalTo: eastButton.salg.top),
                northButton.right.constraint(equalTo: eastButton.salg.left),
                
                westButton.bottom.constraint(equalTo: southButton.salg.top),
                westButton.right.constraint(equalTo: southButton.salg.left),
                
                upButton.left.constraint(equalTo: leftButton.salg.right),
                upButton.bottom.constraint(equalTo: leftButton.salg.top),
                
                leftButton.left.constraint(equalTo: view.salg.left, constant: 20.0),
                leftButton.bottom.constraint(equalTo: downButton.salg.top),
                
                downButton.left.constraint(equalTo: leftButton.salg.right),
                downButton.bottom.constraint(equalTo: selectButton.salg.top),
                
                rightButton.left.constraint(equalTo: downButton.salg.right),
                rightButton.bottom.constraint(equalTo: downButton.salg.top),
                
                l1Button.left.constraint(equalTo: view.salg.left, constant: 20.0),
                l1Button.bottom.constraint(equalTo: upButton.salg.top, constant: -20.0),
                l1Button.width.constraint(equalTo: l1Button.salg.height, multiplier: 3.0 / 2.0),
                
                r1Button.right.constraint(equalTo: view.salg.right, constant: -20.0),
                r1Button.bottom.constraint(equalTo: upButton.salg.top, constant: -20.0),
                r1Button.width.constraint(equalTo: r1Button.salg.height, multiplier: 3.0 / 2.0),
                
                stackView.bottom.constraint(equalTo: view.salg.bottom, constant: -20.0),
                stackView.centerX.constraint(equalTo: view.salg.centerX)
            ])
            
            constraints.phone.landscape.append(contentsOf: [
                southButton.bottom.constraint(equalTo: stackView.salg.bottom),
                southButton.right.constraint(equalTo: eastButton.salg.left),
                
                eastButton.bottom.constraint(equalTo: southButton.salg.top),
                eastButton.right.constraint(equalTo: view.salg.right, constant: -20.0),
                
                northButton.bottom.constraint(equalTo: eastButton.salg.top),
                northButton.right.constraint(equalTo: eastButton.salg.left),
                
                westButton.bottom.constraint(equalTo: southButton.salg.top),
                westButton.right.constraint(equalTo: southButton.salg.left),
                
                upButton.left.constraint(equalTo: leftButton.salg.right),
                upButton.bottom.constraint(equalTo: leftButton.salg.top),
                
                leftButton.left.constraint(equalTo: view.salg.left, constant: 20.0),
                leftButton.bottom.constraint(equalTo: downButton.salg.top),
                
                downButton.left.constraint(equalTo: leftButton.salg.right),
                downButton.bottom.constraint(equalTo: stackView.salg.bottom),
                
                rightButton.left.constraint(equalTo: downButton.salg.right),
                rightButton.bottom.constraint(equalTo: downButton.salg.top),
                
                l1Button.top.constraint(equalTo: view.top, constant: 30.0),
                l1Button.left.constraint(equalTo: view.left, constant: 30.0),
                l1Button.width.constraint(equalTo: l1Button.salg.height, multiplier: 3.0 / 2.0),
                
                r1Button.top.constraint(equalTo: view.top, constant: 30.0),
                r1Button.right.constraint(equalTo: view.right, constant: -30.0),
                r1Button.width.constraint(equalTo: r1Button.salg.height, multiplier: 3.0 / 2.0),
                
                stackView.bottom.constraint(equalTo: view.salg.bottom,constant: -20.0),
                stackView.centerX.constraint(equalTo: view.salg.centerX)
            ])
        }
    }
}
