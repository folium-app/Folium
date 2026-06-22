//
//  MandarineController.swift
//  Folium
//
//  Created by Jarrod Norwell on 23/6/2026.
//

import ConstraintKit
import ExtensionsKit
import FontKit
import UIKit

import Mandarine

class MandarineController : ControlsController {
    var visualEffectView: UIVisualEffectView? = nil
    
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
    
    var crossButton: UIButton? = nil,
        circleButton: UIButton? = nil,
        triangleButton: UIButton? = nil,
        squareButton: UIButton? = nil
    
    var l1Button: UIButton? = nil,
        r1Button: UIButton? = nil,
        l2Button: UIButton? = nil,
        r2Button: UIButton? = nil
    
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
        
        var crossConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "xmark"), nil, .large, .systemBlue)
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
        
        var circleConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "circle"), nil, .large, .systemOrange)
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
        
        var triangleConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "triangle"), nil, .large, .systemGreen)
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
        
        var squareConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "square"), nil, .large, .systemPink)
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
        
        let l1Configuration: UIButton.Configuration = .configuration(.large, .capsule, nil, "L1", .large)
        l1Button = .button(with: l1Configuration, actions: ({ _ in
            self.press(button: .l1)
        }, { _ in
            self.release(button: .l1)
        }))
        guard let l1Button else {
            return
        }
        view.addSubview(l1Button)
        
        let l2Configuration: UIButton.Configuration = .configuration(.large, .capsule, nil, "L2", .large)
        l2Button = .button(with: l2Configuration, actions: ({ _ in
            self.press(button: .l2)
        }, { _ in
            self.release(button: .l2)
        }))
        guard let l2Button else {
            return
        }
        view.addSubview(l2Button)
        
        let r1Configuration: UIButton.Configuration = .configuration(.large, .capsule, nil, "R1", .large)
        r1Button = .button(with: r1Configuration, actions: ({ _ in
            self.press(button: .r1)
        }, { _ in
            self.release(button: .r1)
        }))
        guard let r1Button else {
            return
        }
        view.addSubview(r1Button)
        
        let r2Configuration: UIButton.Configuration = .configuration(.large, .capsule, nil, "R2", .large)
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
        
        switch system {
        case .mandarine:
            configureConstraintsForMandarine()
            reconfigureConstraintsForMandarine()
        case .tomato:
            configureConstraintsForTomato()
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
        guard let mandarineGame: MandarineGame = game as? MandarineGame else {
            return
        }
        
        Task {
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
                
                let viewController: MandarineController = Unmanaged<MandarineController>.fromOpaque(context).takeUnretainedValue()
                
                guard let imageView: UIImageView = viewController.primaryRenderingView as? UIImageView,
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
                
                let viewController: MandarineController = Unmanaged<MandarineController>.fromOpaque(context).takeUnretainedValue()
                
                guard let imageView: UIImageView = viewController.primaryRenderingView as? UIImageView,
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
        }
    }
    
    func press(button: MandarineButton) {
        guard let mandarineGame: MandarineGame = game as? MandarineGame else {
            return
        }
        
        press(button: button, using: mandarineGame.mandarineSystem)
    }
    
    func release(button: MandarineButton) {
        guard let mandarineGame: MandarineGame = game as? MandarineGame else {
            return
        }
        
        release(button: button, using: mandarineGame.mandarineSystem)
    }
    
    func drag(thumbstick: ThumbstickPlacement, value: (x: UInt8, y: UInt8)) {
        /*
        guard let mandarineGame: MandarineGame = game as? MandarineGame else {
            return
        }
        
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
         */
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

extension MandarineController {
    func reconfigureConstraintsForMandarine() {
        guard let stackView: UIStackView,
              let settingsButton: UIButton, let selectButton: UIButton, let startButton: UIButton,
              let leftThumbstickView: ThumbstickView, let rightThumbstickView: ThumbstickView,
              let upButton: UIButton, let downButton: UIButton, let leftButton: UIButton, let rightButton: UIButton,
              let crossButton: UIButton, let circleButton: UIButton, let triangleButton: UIButton, let squareButton: UIButton,
              let l1Button: UIButton, let r1Button: UIButton, let l2Button: UIButton, let r2Button: UIButton else {
            return
        }
        
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            constraints.pad.portrait.append(contentsOf: [
                
            ])
            
            constraints.pad.landscape.append(contentsOf: [
                
            ])
        } else {
            constraints.phone.portrait.append(contentsOf: [
                crossButton.bottom.constraint(equalTo: startButton.salg.top),
                crossButton.right.constraint(equalTo: circleButton.salg.left),
                
                circleButton.bottom.constraint(equalTo: crossButton.salg.top),
                circleButton.right.constraint(equalTo: view.salg.right, constant: -20.0),
                
                triangleButton.bottom.constraint(equalTo: circleButton.salg.top),
                triangleButton.right.constraint(equalTo: circleButton.salg.left),
                
                squareButton.bottom.constraint(equalTo: crossButton.salg.top),
                squareButton.right.constraint(equalTo: crossButton.salg.left),
                
                rightThumbstickView.top.constraint(equalTo: triangleButton.salg.top),
                rightThumbstickView.left.constraint(equalTo: squareButton.salg.left),
                rightThumbstickView.bottom.constraint(equalTo: crossButton.salg.bottom),
                rightThumbstickView.right.constraint(equalTo: circleButton.salg.right),
                
                upButton.left.constraint(equalTo: leftButton.salg.right),
                upButton.bottom.constraint(equalTo: leftButton.salg.top),
                
                leftButton.left.constraint(equalTo: view.salg.left, constant: 20.0),
                leftButton.bottom.constraint(equalTo: downButton.salg.top),
                
                downButton.left.constraint(equalTo: leftButton.salg.right),
                downButton.bottom.constraint(equalTo: selectButton.salg.top),
                
                rightButton.left.constraint(equalTo: downButton.salg.right),
                rightButton.bottom.constraint(equalTo: downButton.salg.top),
                
                leftThumbstickView.top.constraint(equalTo: upButton.salg.top),
                leftThumbstickView.left.constraint(equalTo: leftButton.salg.left),
                leftThumbstickView.bottom.constraint(equalTo: downButton.salg.bottom),
                leftThumbstickView.right.constraint(equalTo: rightButton.salg.right),
                
                l1Button.left.constraint(equalTo: view.salg.left, constant: 20.0),
                l1Button.bottom.constraint(equalTo: upButton.salg.top, constant: -20.0),
                l1Button.width.constraint(equalTo: l1Button.salg.height, multiplier: 3.0 / 2.0),
                
                l2Button.left.constraint(equalTo: l1Button.salg.right, constant: 20.0),
                l2Button.centerY.constraint(equalTo: l1Button.salg.centerY),
                l2Button.width.constraint(equalTo: l2Button.salg.height, multiplier: 3.0 / 2.0),
                
                r1Button.right.constraint(equalTo: view.salg.right, constant: -20.0),
                r1Button.bottom.constraint(equalTo: upButton.salg.top, constant: -20.0),
                r1Button.width.constraint(equalTo: r1Button.salg.height, multiplier: 3.0 / 2.0),
                
                r2Button.right.constraint(equalTo: r1Button.salg.left, constant: -20.0),
                r2Button.centerY.constraint(equalTo: r1Button.salg.centerY),
                r2Button.width.constraint(equalTo: r2Button.salg.height, multiplier: 3.0 / 2.0)
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
                crossButton.bottom.constraint(equalTo: landscapeBottomConstraint, constant: visualEffectView == nil ? -30.0 : 0.0),
                crossButton.right.constraint(equalTo: circleButton.salg.left),
                
                circleButton.bottom.constraint(equalTo: crossButton.salg.top),
                circleButton.right.constraint(equalTo: view.salg.right, constant: -20.0),
                
                triangleButton.bottom.constraint(equalTo: circleButton.salg.top),
                triangleButton.right.constraint(equalTo: circleButton.salg.left),
                
                squareButton.bottom.constraint(equalTo: crossButton.salg.top),
                squareButton.right.constraint(equalTo: crossButton.salg.left),
                
                rightThumbstickView.top.constraint(equalTo: triangleButton.salg.top),
                rightThumbstickView.left.constraint(equalTo: squareButton.salg.left),
                rightThumbstickView.bottom.constraint(equalTo: crossButton.salg.bottom),
                rightThumbstickView.right.constraint(equalTo: circleButton.salg.right),
                
                upButton.left.constraint(equalTo: leftButton.salg.right),
                upButton.bottom.constraint(equalTo: leftButton.salg.top),
                
                leftButton.left.constraint(equalTo: view.salg.left, constant: 20.0),
                leftButton.bottom.constraint(equalTo: downButton.salg.top),
                
                downButton.left.constraint(equalTo: leftButton.salg.right),
                downButton.bottom.constraint(equalTo: landscapeBottomConstraint, constant: visualEffectView == nil ? -30.0 : 0.0),
                
                rightButton.left.constraint(equalTo: downButton.salg.right),
                rightButton.bottom.constraint(equalTo: downButton.salg.top),
                
                leftThumbstickView.top.constraint(equalTo: upButton.salg.top),
                leftThumbstickView.left.constraint(equalTo: leftButton.salg.left),
                leftThumbstickView.bottom.constraint(equalTo: downButton.salg.bottom),
                leftThumbstickView.right.constraint(equalTo: rightButton.salg.right),
                
                l1Button.top.constraint(equalTo: view.top, constant: 30.0),
                l1Button.left.constraint(equalTo: view.left, constant: 30.0),
                l1Button.width.constraint(equalTo: l1Button.salg.height, multiplier: 3.0 / 2.0),
                
                l2Button.left.constraint(equalTo: l1Button.salg.right, constant: 20.0),
                l2Button.centerY.constraint(equalTo: l1Button.salg.centerY),
                l2Button.width.constraint(equalTo: l2Button.salg.height, multiplier: 3.0 / 2.0),
                
                r1Button.top.constraint(equalTo: view.top, constant: 30.0),
                r1Button.right.constraint(equalTo: view.right, constant: -30.0),
                r1Button.width.constraint(equalTo: r1Button.salg.height, multiplier: 3.0 / 2.0),
                
                r2Button.right.constraint(equalTo: r1Button.salg.left, constant: -20.0),
                r2Button.centerY.constraint(equalTo: r1Button.salg.centerY),
                r2Button.width.constraint(equalTo: r2Button.salg.height, multiplier: 3.0 / 2.0)
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
