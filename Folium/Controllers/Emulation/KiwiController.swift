//
//  KiwiController.swift
//  Folium
//
//  Created by Jarrod Norwell on 23/6/2026.
//

import ConstraintKit
import ExtensionsKit
import FontKit
import GameController
import UIKit

import Kiwi

class KiwiController : ControlsController {
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
        view.addSubview(stackView)
        
        // var settingsConfiguration: UIButton.Configuration = UIButton.Configuration.glass()
        // settingsConfiguration.buttonSize = .medium
        // settingsConfiguration.cornerStyle = .capsule
        // settingsConfiguration.image = UIImage(systemName: "ellipsis")?
        //     .applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .medium))
        
        let settingsConfiguration: UIButton.Configuration = .configuration(.medium, .capsule, UIImage(systemName: "ellipsis"), nil, .medium)
        settingsButton = .button(with: settingsConfiguration,
                                 actions: ({ _ in }, { _ in }), UIMenu(preferredElementSize: .medium, children: [
                                    UIDeferredMenuElement.uncached { completion in
                                        guard let kiwiGame: KiwiGame = self.game as? KiwiGame else {
                                            completion([])
                                            return
                                        }
                                        
                                        Task {
                                            completion([
                                                UIAction.async(title: await kiwiGame.kiwiSystem.paused ? "Resume" : "Pause",
                                                               image: UIImage(systemName: await kiwiGame.kiwiSystem.paused ? "play.fill" : "pause.fill")) { action in
                                                                   if await kiwiGame.kiwiSystem.paused {
                                                                       await kiwiGame.kiwiSystem.set(change: true, isPaused: false)
                                                                   } else {
                                                                       await kiwiGame.kiwiSystem.set(change: true, isPaused: true)
                                                                   }
                                                },
                                                UIAction.async(title: "Stop & Exit", image: UIImage(systemName: "stop.fill"), attributes: .destructive) { action in
                                                    await kiwiGame.kiwiSystem.stop()
                                                    
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
        
        // var selectConfiguration: UIButton.Configuration = UIButton.Configuration.glass()
        // selectConfiguration.buttonSize = .medium
        // selectConfiguration.cornerStyle = .capsule
        // selectConfiguration.image = UIImage(systemName: "minus")?
        //     .applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .medium))
        
        let selectConfiguration: UIButton.Configuration = .configuration(.medium, .capsule, UIImage(systemName: "minus"), nil, .medium)
        selectButton = .button(with: selectConfiguration, actions: ({ _ in
            self.press(button: .select)
        }, { _ in
            self.release(button: .select)
        }))
        guard let selectButton else {
            return
        }
        
        // var startConfiguration: UIButton.Configuration = UIButton.Configuration.glass()
        // startConfiguration.buttonSize = .medium
        // startConfiguration.cornerStyle = .capsule
        // startConfiguration.image = UIImage(systemName: "plus")?
        //     .applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .medium))
        
        let startConfiguration: UIButton.Configuration = .configuration(.medium, .capsule, UIImage(systemName: "plus"), nil, .medium)
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
        
        let southConfiguration: UIButton.Configuration = .configuration(.large, .capsule, nil, "B", .large)
        southButton = .button(with: southConfiguration, actions: ({ _ in
            self.press(button: .b)
        }, { _ in
            self.release(button: .b)
        }))
        guard let southButton else {
            return
        }
        view.addSubview(southButton)
        
        let eastConfiguration: UIButton.Configuration = .configuration(.large, .capsule, nil, "A", .large)
        eastButton = .button(with: eastConfiguration, actions: ({ _ in
            self.press(button: .a)
        }, { _ in
            self.release(button: .a)
        }))
        guard let eastButton else {
            return
        }
        view.addSubview(eastButton)
        
        stackView.addArrangedSubview(selectButton)
        stackView.addArrangedSubview(settingsButton)
        stackView.addArrangedSubview(startButton)
        
        switch system {
        case .kiwi:
            configureConstraintsForKiwi()
            reconfigureConstraintsForKiwi()
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
        guard let kiwiGame: KiwiGame = game as? KiwiGame else {
            return
        }
        
        _ = Task {
            if await kiwiGame.kiwiSystem.running {
                return
            }
            
            await kiwiGame.kiwiSystem.insertDisc(at: kiwiGame.details.url)
            
            await kiwiGame.kiwiSystem.set(change: true, isRunning: true)
            
            await kiwiGame.kiwiSystem.setContext(context: Unmanaged.passUnretained(self).toOpaque())
            
            kiwiGame.kiwiSystem.audioBuffer { context, pointer, samples in
                guard let context: UnsafeMutableRawPointer, let pointer: UnsafeMutablePointer<UInt32> else {
                    return
                }
                
                let viewController: KiwiController = Unmanaged<KiwiController>.fromOpaque(context).takeUnretainedValue()
            }
            
            kiwiGame.kiwiSystem.videoBuffer { context, pointer, _ in
                guard let context, let pointer else {
                    return
                }
                
                let viewController: KiwiController = Unmanaged<KiwiController>.fromOpaque(context).takeUnretainedValue()
                
                guard let imageView: UIImageView = viewController.primaryRenderingView as? UIImageView,
                      let secondaryImageView: UIImageView = viewController.primaryBackgroundRenderingView as? UIImageView,
                      let game: KiwiGame = viewController.game as? KiwiGame else {
                    return
                }
                
                Task { @MainActor in
                    let height: Int32 = await game.kiwiSystem.framebufferHeight
                    let width: Int32 = await game.kiwiSystem.framebufferWidth
                    
                    let cgImage: CGImage? = CGImage.from(rgba32: pointer, width: width, height: height)
                    
                    guard let cgImage: CGImage else {
                        return
                    }
                    
                    // viewController.send(frame: pointer)
                    imageView.image = UIImage(cgImage: cgImage)
                    secondaryImageView.image = imageView.image
                }
            }
            
            await kiwiGame.kiwiSystem.start()
        }
    }
    
    func press(button: KiwiButton) {
        guard let kiwiGame: KiwiGame = game as? KiwiGame else {
            return
        }
        
        press(button: button, using: kiwiGame.kiwiSystem)
    }
    
    func release(button: KiwiButton) {
        guard let kiwiGame: KiwiGame = game as? KiwiGame else {
            return
        }
        
        release(button: button, using: kiwiGame.kiwiSystem)
    }
    
    override func applicationStateDidChange(_ applicationState: ApplicationState) async {
        guard let kiwiGame: KiwiGame = game as? KiwiGame else {
            return
        }
        
        switch applicationState {
        case .backgrounded,
                .disconnected:
            await kiwiGame.kiwiSystem.set(change: true, isPaused: true)
        case .foregrounded:
            if UserDefaults.standard.bool(forKey: "folium.autoResumeOnForeground") {
                await kiwiGame.kiwiSystem.set(change: true, isPaused: false)
            }
        }
    }
    
    override nonisolated func controllerDidConnect(controller: GCController) {
        guard let extendedGamepad: GCExtendedGamepad = controller.extendedGamepad else {
            return
        }
        
        extendedGamepad.dpad.up.valueChangedHandler = { input, value, pressed in
            let action: @MainActor @Sendable (KiwiButton) -> Void = pressed ? self.press : self.release
            Task {
                await action(.up)
            }
        }
        
        extendedGamepad.dpad.down.valueChangedHandler = { input, value, pressed in
            let action: @MainActor @Sendable (KiwiButton) -> Void = pressed ? self.press : self.release
            Task {
                await action(.down)
            }
        }
        
        extendedGamepad.dpad.left.valueChangedHandler = { input, value, pressed in
            let action: @MainActor @Sendable (KiwiButton) -> Void = pressed ? self.press : self.release
            Task {
                await action(.left)
            }
        }
        
        extendedGamepad.dpad.right.valueChangedHandler = { input, value, pressed in
            let action: @MainActor @Sendable (KiwiButton) -> Void = pressed ? self.press : self.release
            Task {
                await action(.right)
            }
        }
        
        
        extendedGamepad.buttonA.valueChangedHandler = { input, value, pressed in
            let action: @MainActor @Sendable (KiwiButton) -> Void = pressed ? self.press : self.release
            Task {
                await action(.a)
            }
        }
        
        extendedGamepad.buttonB.valueChangedHandler = { input, value, pressed in
            let action: @MainActor @Sendable (KiwiButton) -> Void = pressed ? self.press : self.release
            Task {
                await action(.b)
            }
        }
        
        
        extendedGamepad.buttonMenu.valueChangedHandler = { input, value, pressed in
            let action: @MainActor @Sendable (KiwiButton) -> Void = pressed ? self.press : self.release
            Task {
                await action(.start)
            }
        }
        
        extendedGamepad.buttonOptions?.valueChangedHandler = { input, value, pressed in
            let action: @MainActor @Sendable (KiwiButton) -> Void = pressed ? self.press : self.release
            Task {
                await action(.select)
            }
        }
    }
}

extension KiwiController {
    func reconfigureConstraintsForKiwi() {
        guard let stackView: UIStackView,
              let selectButton: UIButton, let startButton: UIButton,
              let upButton: UIButton, let downButton: UIButton, let leftButton: UIButton, let rightButton: UIButton,
              let southButton: UIButton, let eastButton: UIButton else {
            return
        }
        
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            constraints.pad.portrait.append(contentsOf: [
                southButton.bottom.constraint(equalTo: startButton.salg.top),
                southButton.right.constraint(equalTo: eastButton.salg.left),
                
                eastButton.bottom.constraint(equalTo: southButton.salg.top),
                eastButton.right.constraint(equalTo: view.salg.right, constant: -20.0),
                
                upButton.left.constraint(equalTo: leftButton.salg.right),
                upButton.bottom.constraint(equalTo: leftButton.salg.top),
                
                leftButton.left.constraint(equalTo: view.salg.left, constant: 20.0),
                leftButton.bottom.constraint(equalTo: downButton.salg.top),
                
                downButton.left.constraint(equalTo: leftButton.salg.right),
                downButton.bottom.constraint(equalTo: selectButton.salg.top),
                
                rightButton.left.constraint(equalTo: downButton.salg.right),
                rightButton.bottom.constraint(equalTo: downButton.salg.top),
                
                stackView.bottom.constraint(equalTo: view.salg.bottom, constant: -20.0),
                stackView.centerX.constraint(equalTo: view.salg.centerX)
            ])
            
            
            guard let primaryRenderingView: UIView else {
                return
            }
            
            constraints.pad.landscape.append(contentsOf: [
                southButton.bottom.constraint(equalTo: stackView.salg.bottom),
                southButton.right.constraint(equalTo: eastButton.salg.left),
                
                eastButton.bottom.constraint(equalTo: southButton.salg.top),
                eastButton.right.constraint(equalTo: view.salg.right, constant: -20.0),
                
                upButton.left.constraint(equalTo: leftButton.salg.right),
                upButton.bottom.constraint(equalTo: leftButton.salg.top),
                
                leftButton.left.constraint(equalTo: view.salg.left, constant: 20.0),
                leftButton.bottom.constraint(equalTo: downButton.salg.top),
                
                downButton.left.constraint(equalTo: leftButton.salg.right),
                downButton.bottom.constraint(equalTo: stackView.salg.bottom),
                
                rightButton.left.constraint(equalTo: downButton.salg.right),
                rightButton.bottom.constraint(equalTo: downButton.salg.top),
                
                stackView.centerY.constraint(equalTo: primaryRenderingView.salg.bottom),
                stackView.centerX.constraint(equalTo: view.salg.centerX)
            ])
        } else {
            constraints.phone.portrait.append(contentsOf: [
                southButton.bottom.constraint(equalTo: startButton.salg.top),
                southButton.right.constraint(equalTo: eastButton.salg.left),
                
                eastButton.bottom.constraint(equalTo: southButton.salg.top),
                eastButton.right.constraint(equalTo: view.salg.right, constant: -20.0),
                
                upButton.left.constraint(equalTo: leftButton.salg.right),
                upButton.bottom.constraint(equalTo: leftButton.salg.top),
                
                leftButton.left.constraint(equalTo: view.salg.left, constant: 20.0),
                leftButton.bottom.constraint(equalTo: downButton.salg.top),
                
                downButton.left.constraint(equalTo: leftButton.salg.right),
                downButton.bottom.constraint(equalTo: selectButton.salg.top),
                
                rightButton.left.constraint(equalTo: downButton.salg.right),
                rightButton.bottom.constraint(equalTo: downButton.salg.top),
                
                stackView.bottom.constraint(equalTo: view.salg.bottom, constant: -20.0),
                stackView.centerX.constraint(equalTo: view.salg.centerX)
            ])
            
            guard let primaryRenderingView: UIView else {
                return
            }
            
            constraints.phone.landscape.append(contentsOf: [
                southButton.bottom.constraint(equalTo: stackView.salg.bottom),
                southButton.right.constraint(equalTo: eastButton.salg.left),
                
                eastButton.bottom.constraint(equalTo: southButton.salg.top),
                eastButton.right.constraint(equalTo: view.salg.right, constant: -20.0),
                
                upButton.left.constraint(equalTo: leftButton.salg.right),
                upButton.bottom.constraint(equalTo: leftButton.salg.top),
                
                leftButton.left.constraint(equalTo: view.salg.left, constant: 20.0),
                leftButton.bottom.constraint(equalTo: downButton.salg.top),
                
                downButton.left.constraint(equalTo: leftButton.salg.right),
                downButton.bottom.constraint(equalTo: stackView.salg.bottom),
                
                rightButton.left.constraint(equalTo: downButton.salg.right),
                rightButton.bottom.constraint(equalTo: downButton.salg.top),
                
                stackView.centerY.constraint(equalTo: primaryRenderingView.salg.bottom),
                stackView.centerX.constraint(equalTo: view.salg.centerX)
            ])
        }
    }
}
