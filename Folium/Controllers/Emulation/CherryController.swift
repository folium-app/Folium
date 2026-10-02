//
//  CherryController.swift
//  Folium
//
//  Created by Jarrod Norwell on 9/8/2026.
//

import AVFoundation
import AudioToolbox
import ConstraintKit
import CoreAudio
import ExtensionsKit
import FontKit
import UIKit

import Cherry

class CherryController : ControlsController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    
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
                                        guard let cherryGame: CherryGame = self.game as? CherryGame else {
                                            completion([])
                                            return
                                        }
                                        
                                        let extraFeaturesPurchased: Bool = UserDefaults.standard.bool(forKey: "extraFeaturesPurchased")
                                        let indexes: ClosedRange<Int> = 0...(extraFeaturesPurchased ? 4 : 2)
                                        
                                        Task {
                                            completion([
                                                UIMenu(options: .displayInline, preferredElementSize: .medium, children: [
                                                    UIMenu(title: "Load", image: UIImage(systemName: "square.and.arrow.up"), children: await indexes.asyncMap  { index in
                                                        UIAction.async(title: "State \(index + 1)", attributes: await cherryGame.cherrySystem.saveStateExists(for: index) ? [] : .disabled) { action in
                                                            await cherryGame.cherrySystem.saveStateLoad(for: index)
                                                            self.notifySuccess()
                                                        }
                                                    }.reversed()),
                                                    UIMenu(title: "Save", image: UIImage(systemName: "square.and.arrow.down"), children: await indexes.asyncMap { index in
                                                        UIAction.async(title: "State \(index + 1)") { action in
                                                            if await cherryGame.cherrySystem.saveStateExists(for: index) {
                                                                let alertController: UIAlertController = UIAlertController(title: "Overwrite Save State?",
                                                                                                                           message: "A save state already exists for this slot. Are you sure you want to overwrite it?",
                                                                                                                           preferredStyle: .alert)
                                                                alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                                                                alertController.addAction(UIAlertAction(title: "Overwrite", style: .destructive) { action in
                                                                    Task {
                                                                        await cherryGame.cherrySystem.saveStateSave(for: index)
                                                                        self.notifySuccess()
                                                                    }
                                                                })
                                                                self.present(alertController, animated: true)
                                                            } else {
                                                                await cherryGame.cherrySystem.saveStateSave(for: index)
                                                                self.notifySuccess()
                                                            }
                                                        }
                                                    }.reversed()),
                                                    UIMenu(title: "Delete", image: UIImage(systemName: "trash"), options: .destructive, children: await indexes.asyncMap { index in
                                                        UIAction.async(title: "State \(index + 1)", attributes: await cherryGame.cherrySystem.saveStateExists(for: index) ? .destructive : .disabled) { action in
                                                            let alertController: UIAlertController = UIAlertController(title: "Delete Save State?",
                                                                                                                       message: "Deleting this save state is destructive and cannot be undone",
                                                                                                                       preferredStyle: .alert)
                                                            alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                                                            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { action in
                                                                _ = Task {
                                                                    try FileManager.default.removeItem(atPath: cherryGame.cherrySystem.saveStatePath(for: index))
                                                                    self.notifySuccess()
                                                                }
                                                            })
                                                            self.present(alertController, animated: true)
                                                        }
                                                    }.reversed())
                                                ]),
                                                UIMenu(options: .displayInline, preferredElementSize: .medium, children: [
                                                    UIAction.async(title: await cherryGame.cherrySystem.paused ? "Resume" : "Pause",
                                                                   image: UIImage(systemName: await cherryGame.cherrySystem.paused ? "play.fill" : "pause.fill")) { action in
                                                                       if await cherryGame.cherrySystem.paused {
                                                                           await cherryGame.cherrySystem.set(change: true, isPaused: false)
                                                                       } else {
                                                                           await cherryGame.cherrySystem.set(change: true, isPaused: true)
                                                                       }
                                                    },
                                                    UIAction.async(title: "Stop & Exit", image: UIImage(systemName: "stop.fill"), attributes: .destructive) { action in
                                                        await cherryGame.cherrySystem.stop()
                                                        
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
        
        let selectConfiguration: UIButton.Configuration = .configuration(.medium, .capsule, UIImage(systemName: "minus"), nil, .medium)
        selectButton = .button(with: selectConfiguration, actions: ({ _ in
            // self.press(button: .select)
        }, { _ in
            // self.release(button: .select)
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
            // self.press(button: .start)
        }, { _ in
            // self.release(button: .start)
        }))
        guard let startButton else {
            return
        }
        
        
        //----
        let zeroConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "0.circle.fill"), nil, .medium)
        zeroButton = .button(with: zeroConfiguration, actions: ({ _ in
            self.press(button: .num0)
        }, { _ in
            self.release(button: .num0)
        }))
        guard let zeroButton: UIButton else {
            return
        }
        view.addSubview(zeroButton)
        
        let asterixConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "circle"), nil, .medium)
        asterixButton = .button(with: asterixConfiguration, actions: ({ _ in
            self.press(button: .star)
        }, { _ in
            self.release(button: .star)
        }))
        guard let asterixButton: UIButton else {
            return
        }
        view.addSubview(asterixButton)
        
        let hashtagConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "number"), nil, .medium)
        hashtagButton = .button(with: hashtagConfiguration, actions: ({ _ in
            self.press(button: .pound)
        }, { _ in
            self.release(button: .pound)
        }))
        guard let hashtagButton: UIButton else {
            return
        }
        view.addSubview(hashtagButton)
        
        //----
        let eightConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "8.circle.fill"), nil, .medium)
        eightButton = .button(with: eightConfiguration, actions: ({ _ in
            self.press(button: .num8)
        }, { _ in
            self.release(button: .num8)
        }))
        guard let eightButton: UIButton else {
            return
        }
        view.addSubview(eightButton)
        
        let sevenConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "7.circle.fill"), nil, .medium)
        sevenButton = .button(with: sevenConfiguration, actions: ({ _ in
            self.press(button: .num7)
        }, { _ in
            self.release(button: .num7)
        }))
        guard let sevenButton: UIButton else {
            return
        }
        view.addSubview(sevenButton)
        
        let nineConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "9.circle.fill"), nil, .medium)
        nineButton = .button(with: nineConfiguration, actions: ({ _ in
            self.press(button: .num9)
        }, { _ in
            self.release(button: .num9)
        }))
        guard let nineButton: UIButton else {
            return
        }
        view.addSubview(nineButton)
        
        //----
        let fiveConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "5.circle.fill"), nil, .medium)
        fiveButton = .button(with: fiveConfiguration, actions: ({ _ in
            self.press(button: .num5)
        }, { _ in
            self.release(button: .num5)
        }))
        guard let fiveButton: UIButton else {
            return
        }
        view.addSubview(fiveButton)
        
        let fourConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "4.circle.fill"), nil, .medium)
        fourButton = .button(with: fourConfiguration, actions: ({ _ in
            self.press(button: .num4)
        }, { _ in
            self.release(button: .num4)
        }))
        guard let fourButton: UIButton else {
            return
        }
        view.addSubview(fourButton)
        
        let sixConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "6.circle.fill"), nil, .medium)
        sixButton = .button(with: sixConfiguration, actions: ({ _ in
            self.press(button: .num6)
        }, { _ in
            self.release(button: .num6)
        }))
        guard let sixButton: UIButton else {
            return
        }
        view.addSubview(sixButton)
        
        //----
        let twoConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "2.circle.fill"), nil, .medium)
        twoButton = .button(with: twoConfiguration, actions: ({ _ in
            self.press(button: .num2)
        }, { _ in
            self.release(button: .num2)
        }))
        guard let twoButton: UIButton else {
            return
        }
        view.addSubview(twoButton)
        
        let oneConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "1.circle.fill"), nil, .medium)
        oneButton = .button(with: oneConfiguration, actions: ({ _ in
            self.press(button: .num1)
        }, { _ in
            self.release(button: .num1)
        }))
        guard let oneButton: UIButton else {
            return
        }
        view.addSubview(oneButton)
        
        let threeConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "3.circle.fill"), nil, .medium)
        threeButton = .button(with: threeConfiguration, actions: ({ _ in
            self.press(button: .num3)
        }, { _ in
            self.release(button: .num3)
        }))
        guard let threeButton: UIButton else {
            return
        }
        view.addSubview(threeButton)
        
        
        stackView.addArrangedSubview(selectButton)
        stackView.addArrangedSubview(settingsButton)
        stackView.addArrangedSubview(startButton)
        
        leftThumbstickView = ThumbstickView()
        guard let leftThumbstickView else {
            return
        }
        leftThumbstickView.translatesAutoresizingMaskIntoConstraints = false
        leftThumbstickView.didClick = {
            
        }
        leftThumbstickView.didUnclick = {
            
        }
        leftThumbstickView.didDrag = { point in
            if point.x > 0 {
                self.press(button: .right)
                self.release(button: .left)
            }
            
            if point.x < 0 {
                self.press(button: .left)
                self.release(button: .right)
            }
            
            if point.y > 0 {
                self.press(button: .down)
                self.release(button: .up)
            }
            
            if point.y < 0 {
                self.press(button: .up)
                self.release(button: .down)
            }
        }
        leftThumbstickView.didUndrag = {
            self.release(button: .up)
            self.release(button: .down)
            self.release(button: .left)
            self.release(button: .right)
        }
        view.addSubview(leftThumbstickView)
        
        switch system {
        case .cherry:
            configureConstraintsForCherry()
            reconfigureConstraintsForCherry()
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
        guard let cherryGame: CherryGame = game as? CherryGame else {
            return
        }
        
        _ = Task {
            if await cherryGame.cherrySystem.running {
                return
            }
            
            await cherryGame.cherrySystem.insertDisc(at: cherryGame.details.fileURL)
            
            await cherryGame.cherrySystem.set(change: true, isRunning: true)
            
            await cherryGame.cherrySystem.setContext(context: Unmanaged.passUnretained(self).toOpaque())
            
            cherryGame.cherrySystem.videoBuffer { context, pointer, _ in
                guard let context, let pointer else {
                    return
                }
                
                let viewController: CherryController = Unmanaged<CherryController>.fromOpaque(context).takeUnretainedValue()
                
                guard let imageView: UIImageView = viewController.primaryRenderingView as? UIImageView,
                      let secondaryImageView: UIImageView = viewController.primaryBackgroundRenderingView as? UIImageView,
                      let game: CherryGame = viewController.game as? CherryGame else {
                    return
                }
                
                Task { @MainActor in
                    let height: Int32 = await game.cherrySystem.framebufferHeight
                    let width: Int32 = await game.cherrySystem.framebufferWidth
                    
                    let cgImage: CGImage? = CGImage.from(rgba32: pointer, width: width, height: height)
                    
                    guard let cgImage: CGImage else {
                        return
                    }
                    
                    let image: UIImage = UIImage(cgImage: cgImage)
                    
                    // viewController.send(frame: pointer)
                    imageView.image = image
                    secondaryImageView.image = imageView.image
                    
                    viewController.send(frame: image, system: .cherry)
                }
            }
            
            await cherryGame.cherrySystem.start()
        }
    }
    
    func press(button: CherryButton) {
        guard let cherryGame: CherryGame = game as? CherryGame else {
            return
        }
        
        press(button: button, using: cherryGame.cherrySystem)
    }
    
    func release(button: CherryButton) {
        guard let cherryGame: CherryGame = game as? CherryGame else {
            return
        }
        
        release(button: button, using: cherryGame.cherrySystem)
    }
    
    override nonisolated func receive(button: CherryButton, pressed: Bool) {
        guard let cherryGame: CherryGame = game as? CherryGame else {
            return
        }
        
        if pressed {
            press(button: button, index: 1, using: cherryGame.cherrySystem)
        } else {
            release(button: button, index: 1, using: cherryGame.cherrySystem)
        }
    }
    
    override func applicationStateDidChange(_ applicationState: ApplicationState) async {
        guard let cherryGame: CherryGame = game as? CherryGame else {
            return
        }
        
        switch applicationState {
        case .backgrounded,
                .disconnected:
            await cherryGame.cherrySystem.set(change: true, isPaused: true)
        case .foregrounded:
            if UserDefaults.standard.bool(forKey: "folium.autoResumeOnForeground") {
                await cherryGame.cherrySystem.set(change: true, isPaused: false)
            }
        }
    }
}

extension CherryController {
    func reconfigureConstraintsForCherry() {
        guard let primaryVisualEffectView: UIVisualEffectView, let stackView: UIStackView, let leftThumbstickView: ThumbstickView,
              let zeroButton: UIButton, let asterixButton: UIButton, let hashtagButton: UIButton,
              let eightButton: UIButton, let sevenButton: UIButton, let nineButton: UIButton,
              let fourButton: UIButton, let fiveButton: UIButton, let sixButton: UIButton,
              let twoButton: UIButton, let oneButton: UIButton, let threeButton: UIButton else {
            return
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            constraints.pad.portrait.append(contentsOf: [
                stackView.bottom.constraint(equalTo: view.salg.bottom, constant: -20.0),
                stackView.centerX.constraint(equalTo: view.salg.centerX)
            ])
            
            
            guard let primaryRenderingView: UIView else {
                return
            }
            
            constraints.pad.landscape.append(contentsOf: [
                stackView.centerY.constraint(equalTo: primaryRenderingView.salg.bottom),
                stackView.centerX.constraint(equalTo: view.salg.centerX)
            ])
        } else {
            constraints.phone.portrait.append(contentsOf: [
                asterixButton.left.constraint(equalTo: view.salg.left, constant: 20.0),
                asterixButton.bottom.constraint(equalTo: stackView.salg.top, constant: -20.0),
                
                zeroButton.left.constraint(equalTo: asterixButton.salg.right, constant: 20.0),
                zeroButton.bottom.constraint(equalTo: stackView.salg.top, constant: -20.0),
                
                hashtagButton.left.constraint(equalTo: zeroButton.salg.right, constant: 20.0),
                hashtagButton.bottom.constraint(equalTo: stackView.salg.top, constant: -20.0),
                
                sevenButton.left.constraint(equalTo: view.salg.left, constant: 20.0),
                sevenButton.bottom.constraint(equalTo: asterixButton.salg.top, constant: -20.0),
                
                eightButton.left.constraint(equalTo: sevenButton.salg.right, constant: 20.0),
                eightButton.bottom.constraint(equalTo: zeroButton.salg.top, constant: -20.0),
                
                nineButton.left.constraint(equalTo: eightButton.salg.right, constant: 20.0),
                nineButton.bottom.constraint(equalTo: hashtagButton.salg.top, constant: -20.0),
                
                fourButton.left.constraint(equalTo: view.salg.left, constant: 20.0),
                fourButton.bottom.constraint(equalTo: sevenButton.salg.top, constant: -20.0),
                
                fiveButton.left.constraint(equalTo: fourButton.salg.right, constant: 20.0),
                fiveButton.bottom.constraint(equalTo: eightButton.salg.top, constant: -20.0),
                
                sixButton.left.constraint(equalTo: fiveButton.salg.right, constant: 20.0),
                sixButton.bottom.constraint(equalTo: nineButton.salg.top, constant: -20.0),
                
                oneButton.left.constraint(equalTo: view.salg.left, constant: 20.0),
                oneButton.bottom.constraint(equalTo: fourButton.salg.top, constant: -20.0),
                oneButton.width.constraint(equalTo: oneButton.salg.height),
                
                twoButton.left.constraint(equalTo: oneButton.salg.right, constant: 20.0),
                twoButton.bottom.constraint(equalTo: fiveButton.salg.top, constant: -20.0),
                twoButton.width.constraint(equalTo: twoButton.salg.height),
                
                threeButton.left.constraint(equalTo: twoButton.salg.right, constant: 20.0),
                threeButton.bottom.constraint(equalTo: sixButton.salg.top, constant: -20.0),
                threeButton.width.constraint(equalTo: threeButton.salg.height),
                
                stackView.bottom.constraint(equalTo: view.salg.bottom, constant: -20.0),
                stackView.centerX.constraint(equalTo: view.salg.centerX),
                
                leftThumbstickView.top.constraint(equalTo: threeButton.salg.top, constant: 20.0),
                leftThumbstickView.left.constraint(equalTo: threeButton.salg.right, constant: 20.0),
                leftThumbstickView.right.constraint(equalTo: view.salg.right, constant: -2.0),
                leftThumbstickView.height.constraint(equalTo: leftThumbstickView.salg.width)
            ])
            
            guard let primaryRenderingView: UIView else {
                return
            }
            
            constraints.phone.landscape.append(contentsOf: [
                stackView.centerY.constraint(equalTo: primaryRenderingView.salg.bottom),
                stackView.centerX.constraint(equalTo: view.salg.centerX)
            ])
        }
    }
}
