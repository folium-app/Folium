//
//  PlumMPController.swift
//  Folium
//
//  Created by Jarrod Norwell on 9/8/2026.
//

import ConstraintKit
import ExtensionsKit
import FontKit
import UIKit

import Plum

class PlumMPController : ControlsController {
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
                                 actions: ({ _ in }, { _ in }), UIMenu(preferredElementSize: .medium, children: []))
        guard let settingsButton else {
            return
        }
        
        let selectConfiguration: UIButton.Configuration = .configuration(.medium, .capsule, UIImage(systemName: "repeat"), nil, .medium)
        selectButton = .button(with: selectConfiguration, actions: ({ _ in
            self.press(button: .mode)
        }, { _ in
            self.release(button: .mode)
        }))
        guard let selectButton else {
            return
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
        
        let upConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "chevron.up"))
        upButton = .button(with: upConfiguration,
                           actions: ({ _ in
            self.press(button: .up)
        }, { _ in
            self.release(button: .up)
        }))
        guard let upButton else {
            return
        }
        view.addSubview(upButton)
        
        let downConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "chevron.down"))
        downButton = .button(with: downConfiguration,
                             actions: ({ _ in
            self.press(button: .down)
        }, { _ in
            self.release(button: .down)
        }))
        guard let downButton else {
            return
        }
        view.addSubview(downButton)
        
        let leftConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "chevron.left"))
        leftButton = .button(with: leftConfiguration,
                             actions: ({ _ in
            self.press(button: .left)
        }, { _ in
            self.release(button: .left)
        }))
        guard let leftButton else {
            return
        }
        view.addSubview(leftButton)
        
        let rightConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "chevron.right"))
        rightButton = .button(with: rightConfiguration,
                              actions: ({ _ in
            self.press(button: .right)
        }, { _ in
            self.release(button: .right)
        }))
        guard let rightButton else {
            return
        }
        view.addSubview(rightButton)
        
        let aConfiguration: UIButton.Configuration = .configuration(.large, .capsule, nil, "A")
        aButton = .button(with: aConfiguration,
                          actions: ({ _ in
            self.press(button: .a)
        }, { _ in
            self.release(button: .a)
        }))
        guard let aButton else {
            return
        }
        view.addSubview(aButton)
        
        let bConfiguration: UIButton.Configuration = .configuration(.large, .capsule, nil, "B")
        bButton = .button(with: bConfiguration,
                          actions: ({ _ in
            self.press(button: .b)
        }, { _ in
            self.release(button: .b)
        }))
        guard let bButton else {
            return
        }
        view.addSubview(bButton)
        
        let cConfiguration: UIButton.Configuration = .configuration(.large, .capsule, nil, "C")
        cButton = .button(with: cConfiguration,
                          actions: ({ _ in
            self.press(button: .c)
        }, { _ in
            self.release(button: .c)
        }))
        guard let cButton else {
            return
        }
        view.addSubview(cButton)
        
        let xConfiguration: UIButton.Configuration = .configuration(.large, .capsule, nil, "X")
        xButton = .button(with: xConfiguration,
                          actions: ({ _ in
            self.press(button: .x)
        }, { _ in
            self.release(button: .x)
        }))
        guard let xButton else {
            return
        }
        view.addSubview(xButton)
        
        let yConfiguration: UIButton.Configuration = .configuration(.large, .capsule, nil, "Y")
        yButton = .button(with: yConfiguration,
                          actions: ({ _ in
            self.press(button: .y)
        }, { _ in
            self.release(button: .y)
        }))
        guard let yButton else {
            return
        }
        view.addSubview(yButton)
        
        let zConfiguration: UIButton.Configuration = .configuration(.large, .capsule, nil, "Z")
        zButton = .button(with: zConfiguration,
                          actions: ({ _ in
            self.press(button: .z)
        }, { _ in
            self.release(button: .z)
        }))
        guard let zButton else {
            return
        }
        view.addSubview(zButton)
        
        stackView.addArrangedSubview(selectButton)
        stackView.addArrangedSubview(settingsButton)
        stackView.addArrangedSubview(startButton)
        
        switch system {
        case .plum:
            configureConstraintsForPlum()
            reconfigureConstraintsForPlum()
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
    
    func press(button: PlumButton) {
        send(button: button, pressed: true, system: system)
    }
    
    func release(button: PlumButton) {
        send(button: button, pressed: false, system: system)
    }
    
    override nonisolated func receive(frame: UIImage) {
        Task { @MainActor in
            guard let primaryRenderingView: UIImageView = primaryRenderingView as? UIImageView,
                  let primaryBackgroundRenderingView: UIImageView = primaryBackgroundRenderingView as? UIImageView else {
                return
            }
            
            primaryRenderingView.image = frame
            primaryBackgroundRenderingView.image = primaryRenderingView.image
        }
    }
}

extension PlumMPController {
    func reconfigureConstraintsForPlum() {
        guard let primaryVisualEffectView: UIVisualEffectView, let stackView: UIStackView else {
            return
        }
        
        guard let aButton, let bButton, let cButton, let xButton, let yButton, let zButton else {
            return
        }
        
        guard let leftButton, let rightButton, let upButton, let downButton else {
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
                stackView.bottom.constraint(equalTo: view.salg.bottom, constant: -20.0),
                stackView.centerX.constraint(equalTo: view.salg.centerX),
                
                aButton.bottomAnchor.constraint(equalTo: stackView.safeAreaLayoutGuide.topAnchor,
                                                constant: -20.0),
                aButton.trailingAnchor.constraint(equalTo: bButton.safeAreaLayoutGuide.leadingAnchor),
                
                bButton.bottomAnchor.constraint(equalTo: aButton.safeAreaLayoutGuide.topAnchor),
                bButton.trailingAnchor.constraint(equalTo: cButton.safeAreaLayoutGuide.leadingAnchor),
                
                cButton.bottomAnchor.constraint(equalTo: bButton.safeAreaLayoutGuide.topAnchor),
                cButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                  constant: -20.0),
                
                xButton.bottomAnchor.constraint(equalTo: bButton.safeAreaLayoutGuide.topAnchor),
                xButton.leadingAnchor.constraint(equalTo: aButton.safeAreaLayoutGuide.leadingAnchor),
                
                yButton.bottomAnchor.constraint(equalTo: cButton.safeAreaLayoutGuide.topAnchor),
                yButton.leadingAnchor.constraint(equalTo: bButton.safeAreaLayoutGuide.leadingAnchor),
                
                zButton.bottomAnchor.constraint(equalTo: yButton.safeAreaLayoutGuide.topAnchor),
                zButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                  constant: -20.0),
                
                upButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                upButton.bottomAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.topAnchor),
                
                leftButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                    constant: 20.0),
                leftButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor),
                
                downButton.leadingAnchor.constraint(equalTo: leftButton.safeAreaLayoutGuide.trailingAnchor),
                downButton.bottomAnchor.constraint(equalTo: stackView.safeAreaLayoutGuide.topAnchor,
                                                   constant: -20.0),
                
                rightButton.leadingAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.trailingAnchor),
                rightButton.bottomAnchor.constraint(equalTo: downButton.safeAreaLayoutGuide.topAnchor)
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
