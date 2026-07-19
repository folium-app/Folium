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

class MandarineMPController : ControlsController {
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
            //self.drag(thumbstick: .left, value: point)
        }
        leftThumbstickView.didUndrag = {
            //self.drag(thumbstick: .left, value: (0, 0))
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
            //self.drag(thumbstick: .right, value: point)
        }
        rightThumbstickView.didUndrag = {
            //self.drag(thumbstick: .left, value: (0, 0))
        }
        view.addSubview(rightThumbstickView)
        
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
        
        let southConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "xmark"), nil, .large, .systemBlue)
        southButton = .button(with: southConfiguration, actions: ({ _ in
            self.press(button: .cross)
        }, { _ in
            self.release(button: .cross)
        }))
        guard let southButton else {
            return
        }
        view.addSubview(southButton)
        
        let eastConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "circle"), nil, .large, .systemOrange)
        eastButton = .button(with: eastConfiguration, actions: ({ _ in
            self.press(button: .circle)
        }, { _ in
            self.release(button: .circle)
        }))
        guard let eastButton else {
            return
        }
        view.addSubview(eastButton)
        
        let northConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "triangle"), nil, .large, .systemGreen)
        northButton = .button(with: northConfiguration, actions: ({ _ in
            self.press(button: .triangle)
        }, { _ in
            self.release(button: .triangle)
        }))
        guard let northButton else {
            return
        }
        view.addSubview(northButton)
        
        let westConfiguration: UIButton.Configuration = .configuration(.large, .capsule, UIImage(systemName: "square"), nil, .large, .systemPink)
        westButton = .button(with: westConfiguration, actions: ({ _ in
            self.press(button: .square)
        }, { _ in
            self.release(button: .square)
        }))
        guard let westButton else {
            return
        }
        view.addSubview(westButton)
        
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
        
        stackView.addArrangedSubview(selectButton)
        stackView.addArrangedSubview(settingsButton)
        stackView.addArrangedSubview(startButton)
        
        system = .mandarine
        switch system {
        case .mandarine:
            configureConstraintsForMandarine()
            reconfigureConstraintsForMandarine()
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
    
    func press(button: MandarineButton) {
        send(button: button, pressed: true, system: system)
    }
    
    func release(button: MandarineButton) {
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

extension MandarineMPController {
    func reconfigureConstraintsForMandarine() {
        guard let stackView: UIStackView,
              let selectButton: UIButton, let startButton: UIButton,
              let leftThumbstickView: ThumbstickView, let rightThumbstickView: ThumbstickView,
              let upButton: UIButton, let downButton: UIButton, let leftButton: UIButton, let rightButton: UIButton,
              let southButton: UIButton, let eastButton: UIButton, let northButton: UIButton, let westButton: UIButton,
              let l1Button: UIButton, let r1Button: UIButton, let l2Button: UIButton, let r2Button: UIButton else {
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
                
                rightThumbstickView.top.constraint(equalTo: northButton.salg.top),
                rightThumbstickView.left.constraint(equalTo: westButton.salg.left),
                rightThumbstickView.bottom.constraint(equalTo: southButton.salg.bottom),
                rightThumbstickView.right.constraint(equalTo: eastButton.salg.right),
                
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
                r2Button.width.constraint(equalTo: r2Button.salg.height, multiplier: 3.0 / 2.0),
                
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
                
                rightThumbstickView.top.constraint(equalTo: northButton.salg.top),
                rightThumbstickView.left.constraint(equalTo: westButton.salg.left),
                rightThumbstickView.bottom.constraint(equalTo: southButton.salg.bottom),
                rightThumbstickView.right.constraint(equalTo: eastButton.salg.right),
                
                upButton.left.constraint(equalTo: leftButton.salg.right),
                upButton.bottom.constraint(equalTo: leftButton.salg.top),
                
                leftButton.left.constraint(equalTo: view.salg.left, constant: 20.0),
                leftButton.bottom.constraint(equalTo: downButton.salg.top),
                
                downButton.left.constraint(equalTo: leftButton.salg.right),
                downButton.bottom.constraint(equalTo: stackView.salg.bottom),
                
                rightButton.left.constraint(equalTo: downButton.salg.right),
                rightButton.bottom.constraint(equalTo: downButton.salg.top),
                
                leftThumbstickView.top.constraint(equalTo: upButton.salg.top),
                leftThumbstickView.left.constraint(equalTo: leftButton.salg.left),
                leftThumbstickView.bottom.constraint(equalTo: downButton.salg.bottom),
                leftThumbstickView.right.constraint(equalTo: rightButton.salg.right),
                
                l1Button.bottom.constraint(equalTo: upButton.salg.top, constant: -20.0),
                l1Button.left.constraint(equalTo: view.salg.left, constant: 20.0),
                l1Button.width.constraint(equalTo: l1Button.salg.height, multiplier: 3.0 / 2.0),
                
                l2Button.left.constraint(equalTo: l1Button.salg.right, constant: 20.0),
                l2Button.centerY.constraint(equalTo: l1Button.salg.centerY),
                l2Button.width.constraint(equalTo: l2Button.salg.height, multiplier: 3.0 / 2.0),
                
                r1Button.bottom.constraint(equalTo: northButton.salg.top, constant: -20.0),
                r1Button.right.constraint(equalTo: view.salg.right, constant: -20.0),
                r1Button.width.constraint(equalTo: r1Button.salg.height, multiplier: 3.0 / 2.0),
                
                r2Button.right.constraint(equalTo: r1Button.salg.left, constant: -20.0),
                r2Button.centerY.constraint(equalTo: r1Button.salg.centerY),
                r2Button.width.constraint(equalTo: r2Button.salg.height, multiplier: 3.0 / 2.0),
                
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
                
                rightThumbstickView.top.constraint(equalTo: northButton.salg.top),
                rightThumbstickView.left.constraint(equalTo: westButton.salg.left),
                rightThumbstickView.bottom.constraint(equalTo: southButton.salg.bottom),
                rightThumbstickView.right.constraint(equalTo: eastButton.salg.right),
                
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
                r2Button.width.constraint(equalTo: r2Button.salg.height, multiplier: 3.0 / 2.0),
                
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
                
                northButton.bottom.constraint(equalTo: eastButton.salg.top),
                northButton.right.constraint(equalTo: eastButton.salg.left),
                
                westButton.bottom.constraint(equalTo: southButton.salg.top),
                westButton.right.constraint(equalTo: southButton.salg.left),
                
                rightThumbstickView.top.constraint(equalTo: northButton.salg.top),
                rightThumbstickView.left.constraint(equalTo: westButton.salg.left),
                rightThumbstickView.bottom.constraint(equalTo: southButton.salg.bottom),
                rightThumbstickView.right.constraint(equalTo: eastButton.salg.right),
                
                upButton.left.constraint(equalTo: leftButton.salg.right),
                upButton.bottom.constraint(equalTo: leftButton.salg.top),
                
                leftButton.left.constraint(equalTo: view.salg.left, constant: 20.0),
                leftButton.bottom.constraint(equalTo: downButton.salg.top),
                
                downButton.left.constraint(equalTo: leftButton.salg.right),
                downButton.bottom.constraint(equalTo: stackView.salg.bottom),
                
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
                r2Button.width.constraint(equalTo: r2Button.salg.height, multiplier: 3.0 / 2.0),
                
                stackView.centerY.constraint(equalTo: primaryRenderingView.salg.bottom),
                stackView.centerX.constraint(equalTo: view.salg.centerX)
            ])
        }
    }
}
