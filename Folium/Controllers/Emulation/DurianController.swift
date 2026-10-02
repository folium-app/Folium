//
//  DurianController.swift
//  Folium
//
//  Created by Jarrod Norwell on 23/6/2026.
//

import ConstraintKit
import ExtensionsKit
import FontKit
import UIKit

import Durian

class DurianController : ControlsController {
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
                                 actions: ({ _ in }, { _ in }), UIMenu(children: [
                                    UIDeferredMenuElement.uncached { completion in
                                        guard let durianGame: DurianGame = self.game as? DurianGame else {
                                            completion([])
                                            return
                                        }
                                        
                                        let extraFeaturesPurchased: Bool = UserDefaults.standard.bool(forKey: "extraFeaturesPurchased")
                                        let indexes: ClosedRange<Int> = 0...(extraFeaturesPurchased ? 4 : 2)
                                        
                                        Task {
                                            completion([
                                                UIMenu(options: .displayInline, preferredElementSize: .medium, children: [
                                                    UIMenu(title: "Load", image: UIImage(systemName: "square.and.arrow.up"), children: await indexes.asyncMap  { index in
                                                        UIAction.async(title: "State \(index + 1)", attributes: await durianGame.durianSystem.saveStateExists(for: index) ? [] : .disabled) { action in
                                                            await durianGame.durianSystem.saveStateLoad(for: index)
                                                            self.notifySuccess()
                                                        }
                                                    }.reversed()),
                                                    UIMenu(title: "Save", image: UIImage(systemName: "square.and.arrow.down"), children: await indexes.asyncMap { index in
                                                        UIAction.async(title: "State \(index + 1)") { action in
                                                            if await durianGame.durianSystem.saveStateExists(for: index) {
                                                                let alertController: UIAlertController = UIAlertController(title: "Overwrite Save State?",
                                                                                                                           message: "A save state already exists for this slot. Are you sure you want to overwrite it?",
                                                                                                                           preferredStyle: .alert)
                                                                alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                                                                alertController.addAction(UIAlertAction(title: "Overwrite", style: .destructive) { action in
                                                                    Task {
                                                                        await durianGame.durianSystem.saveStateSave(for: index)
                                                                        self.notifySuccess()
                                                                    }
                                                                })
                                                                self.present(alertController, animated: true)
                                                            } else {
                                                                await durianGame.durianSystem.saveStateSave(for: index)
                                                                self.notifySuccess()
                                                            }
                                                        }
                                                    }.reversed()),
                                                    UIMenu(title: "Delete", image: UIImage(systemName: "trash"), options: .destructive, children: await indexes.asyncMap { index in
                                                        UIAction.async(title: "State \(index + 1)", attributes: await durianGame.durianSystem.saveStateExists(for: index) ? .destructive : .disabled) { action in
                                                            let alertController: UIAlertController = UIAlertController(title: "Delete Save State?",
                                                                                                                       message: "Deleting this save state is destructive and cannot be undone",
                                                                                                                       preferredStyle: .alert)
                                                            alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                                                            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { action in
                                                                _ = Task {
                                                                    try FileManager.default.removeItem(atPath: durianGame.durianSystem.saveStatePath(for: index))
                                                                    self.notifySuccess()
                                                                }
                                                            })
                                                            self.present(alertController, animated: true)
                                                        }
                                                    }.reversed())
                                                ]),
                                                UIMenu(options: .displayInline, preferredElementSize: .medium, children: [
                                                    UIAction.async(title: await durianGame.durianSystem.paused ? "Resume" : "Pause",
                                                                   image: UIImage(systemName: await durianGame.durianSystem.paused ? "play.fill" : "pause.fill")) { action in
                                                                       if await durianGame.durianSystem.paused {
                                                                           await durianGame.durianSystem.set(change: true, isPaused: false)
                                                                       } else {
                                                                           await durianGame.durianSystem.set(change: true, isPaused: true)
                                                                       }
                                                    },
                                                    UIAction.async(title: "Stop & Exit", image: UIImage(systemName: "stop.fill"), attributes: .destructive) { action in
                                                        await durianGame.durianSystem.stop()
                                                        
                                                        self.game = nil
                                                        
                                                        if let tabController: TabController = self.tabBarController as? TabController {
                                                            tabController.game = nil
                                                            
                                                            tabController.selectedIndex = .gamesController
                                                            tabController.switchEmulationController(with: NoEmulationController())
                                                            tabController.switchSettingsSnapshot(for: .application)
                                                        }
                                                    }
                                                ])
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
        
        let selectConfiguration: UIButton.Configuration = .configuration(.medium, .capsule, UIImage(systemName: "speaker.wave.3"), nil, .medium)
        selectButton = .button(with: selectConfiguration, actions: ({ action in
            if let game: DurianGame = self.game as? DurianGame {
                await game.durianSystem.set(soundVolume: game.durianSystem.soundVolume.next)
            }
            
            if let button: UIButton = action.sender as? UIButton {
                button.updateConfiguration()
            }
            
            self.press(button: .sound)
        }, { _ in
            self.release(button: .sound)
        }))
        guard let selectButton else {
            return
        }
        selectButton.configurationUpdateHandler = { button in
            guard let game: DurianGame = self.game as? DurianGame,
                  var configuration: UIButton.Configuration = button.configuration else {
                return
            }
            
            Task {
                configuration.image = await game.durianSystem.soundVolume.image?
                    .applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .medium))
                button.configuration = configuration
            }
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
        
        let southConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "chevron.down"), nil, .large)
        southButton = .button(with: southConfiguration, actions: ({ _ in
            self.press(button: .down2)
        }, { _ in
            self.release(button: .down2)
        }))
        guard let southButton else {
            return
        }
        view.addSubview(southButton)
        
        let eastConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "chevron.right"), nil, .large)
        eastButton = .button(with: eastConfiguration, actions: ({ _ in
            self.press(button: .right2)
        }, { _ in
            self.release(button: .right2)
        }))
        guard let eastButton else {
            return
        }
        view.addSubview(eastButton)
        
        let northConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "chevron.up"), nil, .large)
        northButton = .button(with: northConfiguration, actions: ({ _ in
            self.press(button: .up2)
        }, { _ in
            self.release(button: .up2)
        }))
        guard let northButton else {
            return
        }
        view.addSubview(northButton)
        
        let westConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "chevron.left"), nil, .large)
        westButton = .button(with: westConfiguration, actions: ({ _ in
            self.press(button: .left2)
        }, { _ in
            self.release(button: .left2)
        }))
        guard let westButton else {
            return
        }
        view.addSubview(westButton)
        
        let l1Configuration: UIButton.Configuration = .configuration(.large, .capsule, nil, "A", .large)
        l1Button = .button(with: l1Configuration, actions: ({ _ in
            self.press(button: .a)
        }, { _ in
            self.release(button: .a)
        }))
        guard let l1Button else {
            return
        }
        view.addSubview(l1Button)
        
        let r1Configuration: UIButton.Configuration = .configuration(.large, .capsule, nil, "B", .large)
        r1Button = .button(with: r1Configuration, actions: ({ _ in
            self.press(button: .b)
        }, { _ in
            self.release(button: .b)
        }))
        guard let r1Button else {
            return
        }
        view.addSubview(r1Button)
        
        stackView.addArrangedSubview(selectButton)
        stackView.addArrangedSubview(settingsButton)
        stackView.addArrangedSubview(startButton)
        
        switch system {
        case .durian:
            configureConstraintsForDurian()
            reconfigureConstraintsForDurian()
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
        guard let durianGame: DurianGame = game as? DurianGame else {
            return
        }
        
        _ = Task {
            if await durianGame.durianSystem.running {
                return
            }
            
            await durianGame.durianSystem.insertDisc(at: durianGame.details.fileURL)
            
            await durianGame.durianSystem.set(change: true, isRunning: true)
            
            await durianGame.durianSystem.setContext(context: Unmanaged.passUnretained(self).toOpaque())
            
            durianGame.durianSystem.audioBuffer { context, pointer, samples in
                guard let context: UnsafeMutableRawPointer, let pointer: UnsafeMutablePointer<UInt32> else {
                    return
                }
                
                let viewController: DurianController = Unmanaged<DurianController>.fromOpaque(context).takeUnretainedValue()
            }
            
            durianGame.durianSystem.videoBuffer { context, pointer, _ in
                guard let context, let pointer else {
                    return
                }
                
                let viewController: DurianController = Unmanaged<DurianController>.fromOpaque(context).takeUnretainedValue()
                
                guard let imageView: UIImageView = viewController.primaryRenderingView as? UIImageView,
                      let secondaryImageView: UIImageView = viewController.primaryBackgroundRenderingView as? UIImageView,
                      let game: DurianGame = viewController.game as? DurianGame else {
                    return
                }
                
                Task { @MainActor in
                    let height: Int32 = await game.durianSystem.framebufferHeight
                    let width: Int32 = await game.durianSystem.framebufferWidth
                    
                    let cgImage: CGImage? = CGImage.from(rgba32: pointer, width: width, height: height)
                    
                    guard let cgImage: CGImage else {
                        return
                    }
                    
                    // viewController.send(frame: pointer)
                    imageView.image = UIImage(cgImage: cgImage)
                    secondaryImageView.image = imageView.image
                }
            }
            
            await durianGame.durianSystem.start()
        }
    }
    
    func press(button: DurianButton) {
        guard let durianGame: DurianGame = game as? DurianGame else {
            return
        }
        
        press(button: button, using: durianGame.durianSystem)
    }
    
    func release(button: DurianButton) {
        guard let durianGame: DurianGame = game as? DurianGame else {
            return
        }
        
        release(button: button, using: durianGame.durianSystem)
    }
    
    override func applicationStateDidChange(_ applicationState: ApplicationState) async {
        guard let durianGame: DurianGame = game as? DurianGame else {
            return
        }
        
        switch applicationState {
        case .backgrounded,
                .disconnected:
            await durianGame.durianSystem.set(change: true, isPaused: true)
        case .foregrounded:
            if UserDefaults.standard.bool(forKey: "folium.autoResumeOnForeground") {
                await durianGame.durianSystem.set(change: true, isPaused: false)
            }
        }
    }
}

extension DurianController {
    func reconfigureConstraintsForDurian() {
        guard let stackView: UIStackView,
              let selectButton: UIButton, let startButton: UIButton,
              let upButton: UIButton, let downButton: UIButton, let leftButton: UIButton, let rightButton: UIButton,
              let southButton: UIButton, let eastButton: UIButton, let northButton: UIButton, let westButton: UIButton,
              let l1Button: UIButton, let r1Button: UIButton else {
            return
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            constraints.pad.portrait.append(contentsOf: [
                selectButton.width.constraint(equalTo: selectButton.salg.height, multiplier: 3.0 / 2.0),
                
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
                selectButton.width.constraint(equalTo: selectButton.salg.height, multiplier: 3.0 / 2.0),
                
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
                selectButton.width.constraint(equalTo: selectButton.salg.height, multiplier: 3.0 / 2.0),
                
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
                selectButton.width.constraint(equalTo: selectButton.salg.height, multiplier: 3.0 / 2.0),
                
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
