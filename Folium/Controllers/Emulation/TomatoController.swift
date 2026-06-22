//
//  TomatoController.swift
//  Folium
//
//  Created by Jarrod Norwell on 23/6/2026.
//

import ConstraintKit
import ExtensionsKit
import FontKit
import UIKit

import Tomato

class TomatoController : ControlsController {
    var visualEffectView: UIVisualEffectView? = nil
    
    var settingsButton: UIButton? = nil,
        selectButton: UIButton? = nil,
        startButton: UIButton? = nil
    
    var stackView: UIStackView? = nil
    
    var upButton: UIButton? = nil,
        downButton: UIButton? = nil,
        leftButton: UIButton? = nil,
        rightButton: UIButton? = nil
    
    var bButton: UIButton? = nil,
        aButton: UIButton? = nil
    
    var l1Button: UIButton? = nil,
        r1Button: UIButton? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView = UIStackView()
        guard let stackView: UIStackView else {
            return
        }
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.clipsToBounds = false
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        
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
                                                        case let tomatoGame as TomatoGame:
                                                            await tomatoGame.tomatoSystem.stop()
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
        
        let upConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "arrowtriangle.up"), nil, .large)
        upButton = .button(with: upConfiguration, actions: ({ _ in
            self.press(button: .up)
        }, { _ in
            self.release(button: .up)
        }))
        guard let upButton else {
            return
        }
        view.addSubview(upButton)
        
        let downConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "arrowtriangle.down"), nil, .large)
        downButton = .button(with: downConfiguration, actions: ({ _ in
            self.press(button: .down)
        }, { _ in
            self.release(button: .down)
        }))
        guard let downButton else {
            return
        }
        view.addSubview(downButton)
        
        let leftConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "arrowtriangle.left"), nil, .large)
        leftButton = .button(with: leftConfiguration, actions: ({ _ in
            self.press(button: .left)
        }, { _ in
            self.release(button: .left)
        }))
        guard let leftButton else {
            return
        }
        view.addSubview(leftButton)
        
        let rightConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "arrowtriangle.right"), nil, .large)
        rightButton = .button(with: rightConfiguration, actions: ({ _ in
            self.press(button: .right)
        }, { _ in
            self.release(button: .right)
        }))
        guard let rightButton else {
            return
        }
        view.addSubview(rightButton)
        
        let bConfiguration: UIButton.Configuration = .configuration(.large, .capsule, nil, "B", .large)
        bButton = .button(with: bConfiguration, actions: ({ _ in
            self.press(button: .b)
        }, { _ in
            self.release(button: .b)
        }))
        guard let bButton else {
            return
        }
        view.addSubview(bButton)
        
        let aConfiguration: UIButton.Configuration = .configuration(.large, .capsule, nil, "A", .large)
        aButton = .button(with: aConfiguration, actions: ({ _ in
            self.press(button: .a)
        }, { _ in
            self.release(button: .a)
        }))
        guard let aButton else {
            return
        }
        view.addSubview(aButton)
        
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
        
        if visualEffectView != nil {
            stackView.addArrangedSubview(selectButton)
            stackView.addArrangedSubview(settingsButton)
            stackView.addArrangedSubview(startButton)
        }
        
        switch system {
        case .mandarine:
            configureConstraintsForMandarine()
            // reconfigureConstraintsForMandarine()
        case .tomato:
            configureConstraintsForTomato()
            reconfigureConstraintsForTomato()
        }
        
        let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
#if targetEnvironment(simulator)
        view.addConstraints(constraints.phone.portrait)
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
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let tomatoGame: TomatoGame = game as? TomatoGame else {
            return
        }
        
        Task {
            if await tomatoGame.tomatoSystem.running {
                return
            }
            
            await tomatoGame.tomatoSystem.insertDisc(at: tomatoGame.details.url)
            
            await tomatoGame.tomatoSystem.set(change: true, isRunning: true)
            
            await tomatoGame.tomatoSystem.setContext(context: Unmanaged.passUnretained(self).toOpaque())
            tomatoGame.tomatoSystem.videoBuffer { context, pointer in
                guard let context, let pointer else {
                    return
                }
                
                let viewController: TomatoController = Unmanaged<TomatoController>.fromOpaque(context).takeUnretainedValue()
                
                guard let imageView: UIImageView = viewController.primaryRenderingView as? UIImageView,
                      let game: TomatoGame = viewController.game as? TomatoGame else {
                    return
                }
                
                Task { @MainActor in
                    let height: Int32 = await game.tomatoSystem.framebufferHeight
                    let width: Int32 = await game.tomatoSystem.framebufferWidth
                    
                    let cgImage: CGImage? = CGImage.gba(pointer, Int(width), Int(height))
                    
                    guard let cgImage: CGImage else {
                        return
                    }
                    
                    imageView.image = UIImage(cgImage: cgImage)
                }
            }
            
            await tomatoGame.tomatoSystem.start()
        }
    }
    
    func press(button: TomatoButton) {
        guard let tomatoGame: TomatoGame = game as? TomatoGame else {
            return
        }
        
        press(button: button, using: tomatoGame.tomatoSystem)
    }
    
    func release(button: TomatoButton) {
        guard let tomatoGame: TomatoGame = game as? TomatoGame else {
            return
        }
        
        release(button: button, using: tomatoGame.tomatoSystem)
    }
}

extension TomatoController {
    func reconfigureConstraintsForTomato() {
        guard let stackView: UIStackView,
              let settingsButton: UIButton, let selectButton: UIButton, let startButton: UIButton,
              let upButton: UIButton, let downButton: UIButton, let leftButton: UIButton, let rightButton: UIButton,
              let bButton: UIButton, let aButton: UIButton,
              let l1Button: UIButton, let r1Button: UIButton else {
            return
        }
        
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            constraints.pad.portrait.append(contentsOf: [
                
            ])
            
            constraints.pad.landscape.append(contentsOf: [
                
            ])
        } else {
            constraints.phone.portrait.append(contentsOf: [
                bButton.bottom.constraint(equalTo: startButton.salg.top),
                bButton.right.constraint(equalTo: aButton.salg.left),
                
                aButton.bottom.constraint(equalTo: bButton.salg.top),
                aButton.right.constraint(equalTo: view.salg.right, constant: -20.0),
                
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
            ])
            
            if let visualEffectView {
                constraints.phone.portrait.append(contentsOf: [
                    stackView.centerX.constraint(equalTo: view.salg.centerX),
                    stackView.bottom.constraint(equalTo: view.salg.bottom, constant: -20.0),
                    
                    visualEffectView.top.constraint(equalTo: stackView.salg.top),
                    visualEffectView.left.constraint(equalTo: stackView.salg.left),
                    visualEffectView.bottom.constraint(equalTo: stackView.salg.bottom),
                    visualEffectView.right.constraint(equalTo: stackView.salg.right)
                ])
            } else {
                constraints.phone.portrait.append(contentsOf: [
                    settingsButton.bottom.constraint(equalTo: view.salg.bottom, constant: -20.0),
                    settingsButton.centerX.constraint(equalTo: view.salg.centerX),
                    
                    selectButton.bottom.constraint(equalTo: view.salg.bottom, constant: -20.0),
                    selectButton.right.constraint(equalTo: settingsButton.salg.left, constant: -20.0),
                    
                    startButton.bottom.constraint(equalTo: view.salg.bottom, constant: -20.0),
                    startButton.left.constraint(equalTo: settingsButton.salg.right, constant: 20.0)
                ])
            }
            
            let landscapeBottomConstraint: NSLayoutAnchor = if let visualEffectView {
                visualEffectView.salg.bottom
            } else {
                startButton.salg.top
            }
            
            constraints.phone.landscape.append(contentsOf: [
                bButton.bottom.constraint(equalTo: landscapeBottomConstraint, constant: visualEffectView == nil ? -30.0 : 0.0),
                bButton.right.constraint(equalTo: aButton.salg.left),
                
                aButton.bottom.constraint(equalTo: bButton.salg.top),
                aButton.right.constraint(equalTo: view.salg.right, constant: -20.0),
                
                upButton.left.constraint(equalTo: leftButton.salg.right),
                upButton.bottom.constraint(equalTo: leftButton.salg.top),
                
                leftButton.left.constraint(equalTo: view.salg.left, constant: 20.0),
                leftButton.bottom.constraint(equalTo: downButton.salg.top),
                
                downButton.left.constraint(equalTo: leftButton.salg.right),
                downButton.bottom.constraint(equalTo: landscapeBottomConstraint, constant: visualEffectView == nil ? -30.0 : 0.0),
                
                rightButton.left.constraint(equalTo: downButton.salg.right),
                rightButton.bottom.constraint(equalTo: downButton.salg.top),
                
                l1Button.top.constraint(equalTo: view.top, constant: 30.0),
                l1Button.left.constraint(equalTo: view.left, constant: 30.0),
                l1Button.width.constraint(equalTo: l1Button.salg.height, multiplier: 3.0 / 2.0),
                
                r1Button.top.constraint(equalTo: view.top, constant: 30.0),
                r1Button.right.constraint(equalTo: view.right, constant: -30.0),
                r1Button.width.constraint(equalTo: r1Button.salg.height, multiplier: 3.0 / 2.0),
            ])
            
            if let visualEffectView {
                constraints.phone.landscape.append(contentsOf: [
                    stackView.centerX.constraint(equalTo: view.salg.centerX),
                    stackView.bottom.constraint(equalTo: view.salg.bottom, constant: -20.0),
                    
                    visualEffectView.top.constraint(equalTo: stackView.salg.top),
                    visualEffectView.left.constraint(equalTo: stackView.salg.left),
                    visualEffectView.bottom.constraint(equalTo: stackView.salg.bottom),
                    visualEffectView.right.constraint(equalTo: stackView.salg.right)
                ])
            } else {
                guard let primaryRenderingView: UIView else {
                    return
                }
                
                constraints.phone.landscape.append(contentsOf: [
                    settingsButton.bottom.constraint(equalTo: view.salg.bottom, constant: -20.0),
                    settingsButton.centerX.constraint(equalTo: view.salg.centerX),
                    
                    startButton.bottom.constraint(equalTo: view.salg.bottom, constant: -20.0),
                    startButton.left.constraint(equalTo: primaryRenderingView.salg.trailingAnchor, constant: 20.0),
                    
                    selectButton.bottom.constraint(equalTo: view.salg.bottom, constant: -20.0),
                    selectButton.right.constraint(equalTo: primaryRenderingView.salg.left, constant: -20.0)
                ])
            }
        }
    }
}
