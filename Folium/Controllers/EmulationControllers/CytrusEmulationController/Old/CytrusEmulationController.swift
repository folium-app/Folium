//
//  CytrusEmulationController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 18/4/2024.
//

import Cytrus
import Foundation
import GameController
import MetalKit
import UIKit

class CytrusEmulationController : EmulationScreensController {
    var cytrus: Cytrus = .shared
    
    fileprivate var isRunning: Bool = false
    
    override func loadView() {
        super.loadView()
        cytrus.getVulkanLibrary()
        cytrus.setMTKView(view as! MTKView, view.frame.size)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        var config = UIButton.Configuration.plain()
        config.buttonSize = traitCollection.userInterfaceIdiom == .pad ? .medium : .small
        config.image = .init(systemName: "gearshape.fill")?
            .applyingSymbolConfiguration(.init(paletteColors: [.white]))
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.showsMenuAsPrimaryAction = true
        button.menu = CytrusManager.shared.menu(button, self, true)
        view.addSubview(button)
        
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5).isActive = true
        
        NotificationCenter.default.addObserver(forName: .init("sceneDidChange"), object: nil, queue: .main) { notification in
            guard let userInfo = notification.userInfo, let state = userInfo["state"] as? Int else {
                return
            }
            
            self.cytrus.pausePlay(state == 1)
            button.menu = CytrusManager.shared.menu(button, self, true)
        }
        
        NotificationCenter.default.addObserver(forName: .init("openKeyboard"), object: nil, queue: .main) { notification in
            guard let config = notification.object as? KeyboardConfig else {
                return
            }
            
            let selector = NSSelectorFromString("_setHeaderContentViewController:")
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertController.perform(selector, with: KeyboardController(keyboardConfig: config))
            alertController.addAction(.init(title: "Cancel", style: .cancel))
            self.present(alertController, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isRunning {
            isRunning = true
            
            Thread.setThreadPriority(1.0)
            Thread.detachNewThread(run)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let view = view as? MTKView, let window = view.window, let windowScene = window.windowScene else {
            return
        }
        
        coordinator.animate { _ in } completion: { _ in
            self.cytrus.orientationChanged(windowScene.interfaceOrientation, view)
        }
    }
    
    @objc fileprivate func run() {
        guard let game = game as? CytrusManager.Library.Game else {
            return
        }
        
        cytrus.run(game.fileDetails.url)
    }
    
    fileprivate func position(in view: UIView, with location: CGPoint) -> (x: Float, y: Float) {
        let radius = view.frame.width / 2
        return (Float((location.x - radius) / radius), Float(-(location.y - radius) / radius))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first, let view = touch.view else {
            return
        }
        
        cytrus.touchBegan(touch.location(in: view))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let _ = touches.first else {
            return
        }
        
        cytrus.touchEnded()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first, let view = touch.view else {
            return
        }
        
        cytrus.touchMoved(touch.location(in: view))
    }
    
    override func controllerDidConnect(_ notification: Notification) {
        super.controllerDidConnect(notification)
        guard let controller = notification.object as? GCController, let extendedGamepad = controller.extendedGamepad else {
            return
        }
        
        extendedGamepad.dpad.up.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.dpadUp) : self.touchUpInside(.dpadUp)
        }
        
        extendedGamepad.dpad.down.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.dpadDown) : self.touchUpInside(.dpadDown)
        }
        
        extendedGamepad.dpad.left.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.dpadLeft) : self.touchUpInside(.dpadLeft)
        }
        
        extendedGamepad.dpad.right.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.dpadRight) : self.touchUpInside(.dpadRight)
        }
        
        extendedGamepad.buttonOptions?.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.minus) : self.touchUpInside(.minus)
        }
        
        extendedGamepad.buttonMenu.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.plus) : self.touchUpInside(.plus)
        }
        
        extendedGamepad.buttonA.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.a) : self.touchUpInside(.a)
        }
        
        extendedGamepad.buttonB.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.b) : self.touchUpInside(.b)
        }
        
        extendedGamepad.buttonX.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.x) : self.touchUpInside(.x)
        }
        
        extendedGamepad.buttonY.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.y) : self.touchUpInside(.y)
        }
        
        extendedGamepad.leftShoulder.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.l) : self.touchUpInside(.l)
        }
        
        extendedGamepad.leftTrigger.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.zl) : self.touchUpInside(.zl)
        }
        
        extendedGamepad.rightShoulder.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.r) : self.touchUpInside(.r)
        }
        
        extendedGamepad.rightTrigger.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.zr) : self.touchUpInside(.zr)
        }
        
        extendedGamepad.leftThumbstick.valueChangedHandler = { dpad, x, y in
            self.cytrus.thumbstickMoved(.circlePad, x, y)
        }
        
        extendedGamepad.rightThumbstick.valueChangedHandler = { dpad, x, y in
            self.cytrus.thumbstickMoved(.cStick, x, y)
        }
    }
    
    override func touchDown(_ buttonType: VirtualControllerButton.ButtonType) {
        super.touchDown(buttonType)
        switch buttonType {
        case .dpadUp:
            cytrus.virtualControllerButtonDown(.directionalPadUp)
        case .dpadDown:
            cytrus.virtualControllerButtonDown(.directionalPadDown)
        case .dpadLeft:
            cytrus.virtualControllerButtonDown(.directionalPadLeft)
        case .dpadRight:
            cytrus.virtualControllerButtonDown(.directionalPadRight)
        case .minus:
            cytrus.virtualControllerButtonDown(.select)
        case .plus:
            cytrus.virtualControllerButtonDown(.start)
        case .a:
            cytrus.virtualControllerButtonDown(.A)
        case .b:
            cytrus.virtualControllerButtonDown(.B)
        case .x:
            cytrus.virtualControllerButtonDown(.X)
        case .y:
            cytrus.virtualControllerButtonDown(.Y)
        case .l:
            cytrus.virtualControllerButtonDown(.triggerL)
        case .zl:
            cytrus.virtualControllerButtonDown(.triggerZL)
        case .r:
            cytrus.virtualControllerButtonDown(.triggerR)
        case .zr:
            cytrus.virtualControllerButtonDown(.triggerZR)
        }
    }
    
    override func touchUpInside(_ buttonType: VirtualControllerButton.ButtonType) {
        super.touchUpInside(buttonType)
        switch buttonType {
        case .dpadUp:
            cytrus.virtualControllerButtonUp(.directionalPadUp)
        case .dpadDown:
            cytrus.virtualControllerButtonUp(.directionalPadDown)
        case .dpadLeft:
            cytrus.virtualControllerButtonUp(.directionalPadLeft)
        case .dpadRight:
            cytrus.virtualControllerButtonUp(.directionalPadRight)
        case .minus:
            cytrus.virtualControllerButtonUp(.select)
        case .plus:
            cytrus.virtualControllerButtonUp(.start)
        case .a:
            cytrus.virtualControllerButtonUp(.A)
        case .b:
            cytrus.virtualControllerButtonUp(.B)
        case .x:
            cytrus.virtualControllerButtonUp(.X)
        case .y:
            cytrus.virtualControllerButtonUp(.Y)
        case .l:
            cytrus.virtualControllerButtonUp(.triggerL)
        case .zl:
            cytrus.virtualControllerButtonUp(.triggerZL)
        case .r:
            cytrus.virtualControllerButtonUp(.triggerR)
        case .zr:
            cytrus.virtualControllerButtonUp(.triggerZR)
        }
    }
    
    override func touchDown(_ thumbstickType: VirtualControllerThumbstick.ThumbstickType, _ location: (x: Float, y: Float)) {
        super.touchDown(thumbstickType, location)
        cytrus.thumbstickMoved(thumbstickType == .thumbstickLeft ? .circlePad : .cStick, location.x, location.y)
    }
    
    override func touchDragInside(_ thumbstickType: VirtualControllerThumbstick.ThumbstickType, _ location: (x: Float, y: Float)) {
        super.touchDragInside(thumbstickType, location)
        cytrus.thumbstickMoved(thumbstickType == .thumbstickLeft ? .circlePad : .cStick, location.x, location.y)
    }
    
    override func touchUpInside(_ thumbstickType: VirtualControllerThumbstick.ThumbstickType, _ location: (x: Float, y: Float)) {
        super.touchUpInside(thumbstickType, location)
        cytrus.thumbstickMoved(thumbstickType == .thumbstickLeft ? .circlePad : .cStick, location.x, location.y)
    }
}

// MARK: OLD
/*
class KeyboardController : UIViewController, UITextFieldDelegate {
    var keyboardConfig: KeyboardConfig
    init(keyboardConfig: KeyboardConfig) {
        self.keyboardConfig = keyboardConfig
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textField = MinimalRoundedTextField("Enter text", .all)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .tertiarySystemBackground
        textField.delegate = self
        view.addSubview(textField)
        view.addConstraints([
            textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        
        var buttons: [UIButton] = []
        switch keyboardConfig.buttonConfig {
        case .single:
            var configuration = UIButton.Configuration.filled()
            configuration.attributedTitle = .init("Okay", attributes: .init([
                .font : UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
            ]))
            configuration.buttonSize = .large
            configuration.cornerStyle = .large
            
            buttons.append(.init(configuration: configuration, primaryAction: .init(handler: { _ in
                NotificationCenter.default.post(name: .init("closeKeyboard"), object: nil, userInfo: [
                    "buttonPressed" : 0,
                    "keyboardText" : textField.text ?? ""
                ])
                textField.text = nil
                self.dismiss(animated: true)
            })))
        case .dual:
            var cancelConfiguration = UIButton.Configuration.filled()
            cancelConfiguration.attributedTitle = .init("Cancel", attributes: .init([
                .font : UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
            ]))
            cancelConfiguration.buttonSize = .large
            cancelConfiguration.cornerStyle = .large
            
            var okayConfiguration = UIButton.Configuration.filled()
            okayConfiguration.attributedTitle = .init("Okay", attributes: .init([
                .font : UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
            ]))
            okayConfiguration.buttonSize = .large
            okayConfiguration.cornerStyle = .large
            
            let cancelButton = UIButton(configuration: cancelConfiguration, primaryAction: .init(handler: { _ in
                NotificationCenter.default.post(name: .init("closeKeyboard"), object: nil, userInfo: [
                    "buttonPressed" : 0,
                    "keyboardText" : textField.text ?? ""
                ])
                textField.text = nil
                self.dismiss(animated: true)
            }))
            cancelButton.tintColor = .systemRed
            
            buttons.append(cancelButton)
            buttons.append(.init(configuration: okayConfiguration, primaryAction: .init(handler: { _ in
                NotificationCenter.default.post(name: .init("closeKeyboard"), object: nil, userInfo: [
                    "buttonPressed" : 0,
                    "keyboardText" : textField.text ?? ""
                ])
                textField.text = nil
                self.dismiss(animated: true)
            })))
        case .triple:
            break
        case .none:
            break
        @unknown default:
            fatalError()
        }
        
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 20
        view.addSubview(stackView)
        view.addConstraints([
            stackView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
}


class MainThread : Thread {
    var game: CytrusManager.Library.Game
    
    init(game: CytrusManager.Library.Game) {
        self.game = game
    }
    
    override func main() {
        super.main()
        
        Cytrus.shared.run(game.fileDetails.url)
    }
}

class CytrusEmulationController : EmulationScreensController {
    fileprivate let cytrus = Cytrus.shared
    
    fileprivate var isRunning: Bool = false
    fileprivate var thread: MainThread!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        var gearButtonConfiguration = UIButton.Configuration.borderless()
        gearButtonConfiguration.buttonSize = .small
        gearButtonConfiguration.image = .init(systemName: "gearshape.fill")?
            .applyingSymbolConfiguration(.init(paletteColors: [.white]))
        
        let button = UIButton(configuration: gearButtonConfiguration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.menu = menu(button)
        button.showsMenuAsPrimaryAction = true
        view.addSubview(button)
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5).isActive = true
        
        NotificationCenter.default.addObserver(forName: .init("sceneDidChange"), object: nil, queue: .main) { notification in
            guard let userInfo = notification.userInfo, let state = userInfo["state"] as? Int else {
                return
            }
            
            self.cytrus.pausePlay(state == 1)
            button.menu = self.menu(button)
        }
        
        NotificationCenter.default.addObserver(forName: .init("openKeyboard"), object: nil, queue: .main) { notification in
            guard let config = notification.object as? KeyboardConfig else {
                return
            }
            
            let selector = NSSelectorFromString("_setHeaderContentViewController:")
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertController.perform(selector, with: KeyboardController(keyboardConfig: config))
            alertController.addAction(.init(title: "Cancel", style: .cancel))
            self.present(alertController, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isRunning {
            isRunning = true
            guard let game = game as? CytrusManager.Library.Game, let view = view as? MTKView/*, let secondaryScreen = secondaryScreen as? MTKView*/ else {
                return
            }
            
            thread = .init(game: game)
            thread.threadPriority = 1.0
            
            cytrus.getVulkanLibrary()
            cytrus.setMTKView(view)
            
            // cytrus.configure(primaryScreen.metalLayer.layer as! CAMetalLayer, primaryScreen.metalLayer.frame.size/*,
            //                  secondaryLayer: secondaryScreen.layer as! CAMetalLayer, secondarySize: secondaryScreen.frame.size*/)
            // cytrus.insert(game: game.fileDetails.url)
            
            thread.main()
        }
    }
    
    @objc func run() {
        guard let game = game as? CytrusManager.Library.Game else {
            return
        }
        
        cytrus.run(game.fileDetails.url)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // coordinator.animate { _ in
            // self.cytrus.orientationChanged(UIApplication.shared.statusBarOrientation, (self.view as! MetalView).metalLayer.frame.size)
            // self.cytrus.orientationChanged(orientation: UIApplication.shared.statusBarOrientation, with: self.secondaryScreen.frame.size)
        // }
        
        coordinator.animate { _ in } completion: { _ in
            self.cytrus.orientationChanged(UIApplication.shared.statusBarOrientation, self.view as! MTKView)
        }
    }
    
    fileprivate func menu(_ button: UIButton) -> UIMenu {
        if #available(iOS 16, *) {
            .init(preferredElementSize: .medium, children: [
                UIAction(title: Cytrus.shared.isPaused() ? "Play" : "Pause", image: .init(systemName: Cytrus.shared.isPaused() ? "play.fill" : "pause.fill"), handler: { action in
                    Cytrus.shared.pausePlay(Cytrus.shared.isPaused())
                    button.menu = self.menu(button)
                }),
                UIAction(title: "Stop & Exit", image: .init(systemName: "stop.fill"), attributes: [.destructive, .disabled], handler: { action in })
            ])
        } else {
            .init(children: [
                UIAction(title: Cytrus.shared.isPaused() ? "Play" : "Pause", image: .init(systemName: Cytrus.shared.isPaused() ? "play.fill" : "pause.fill"), handler: { action in
                    Cytrus.shared.pausePlay(Cytrus.shared.isPaused())
                    button.menu = self.menu(button)
                }),
                UIAction(title: "Stop & Exit", image: .init(systemName: "stop.fill"), attributes: [.destructive, .disabled], handler: { action in })
            ])
        }
    }
    
    // MARK: Touch Delegates
    fileprivate func position(in view: UIView, with location: CGPoint) -> (x: Float, y: Float) {
        let radius = view.frame.width / 2
        return (Float((location.x - radius) / radius), Float(-(location.y - radius) / radius))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first, let metalView = touch.view as? MetalLayer else {
            return
        }
        
        cytrus.touchBegan(touch.location(in: metalView))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        
        cytrus.touchEnded()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first, let metalView = touch.view as? MetalLayer else {
            return
        }
        
        cytrus.touchMoved(touch.location(in: metalView))
    }
    
    // MARK: Physical Controller Delegates
    override func controllerDidConnect(_ notification: Notification) {
        super.controllerDidConnect(notification)
        guard let controller = notification.object as? GCController, let extendedGamepad = controller.extendedGamepad else {
            return
        }
        
        extendedGamepad.dpad.up.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.dpadUp) : self.touchUpInside(.dpadUp)
        }
        
        extendedGamepad.dpad.down.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.dpadDown) : self.touchUpInside(.dpadDown)
        }
        
        extendedGamepad.dpad.left.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.dpadLeft) : self.touchUpInside(.dpadLeft)
        }
        
        extendedGamepad.dpad.right.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.dpadRight) : self.touchUpInside(.dpadRight)
        }
        
        extendedGamepad.buttonOptions?.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.minus) : self.touchUpInside(.minus)
        }
        
        extendedGamepad.buttonMenu.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.plus) : self.touchUpInside(.plus)
        }
        
        extendedGamepad.buttonA.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.a) : self.touchUpInside(.a)
        }
        
        extendedGamepad.buttonB.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.b) : self.touchUpInside(.b)
        }
        
        extendedGamepad.buttonX.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.x) : self.touchUpInside(.x)
        }
        
        extendedGamepad.buttonY.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.y) : self.touchUpInside(.y)
        }
        
        extendedGamepad.leftShoulder.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.l) : self.touchUpInside(.l)
        }
        
        extendedGamepad.leftTrigger.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.zl) : self.touchUpInside(.zl)
        }
        
        extendedGamepad.rightShoulder.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.r) : self.touchUpInside(.r)
        }
        
        extendedGamepad.rightTrigger.pressedChangedHandler = { button, value, pressed in
            pressed ? self.touchDown(.zr) : self.touchUpInside(.zr)
        }
        
        extendedGamepad.leftThumbstick.valueChangedHandler = { dpad, x, y in
            self.cytrus.thumbstickMoved(.circlePad, x, y)
        }
        
        extendedGamepad.rightThumbstick.valueChangedHandler = { dpad, x, y in
            self.cytrus.thumbstickMoved(.cStick, x, y)
        }
    }
    
    override func touchDown(_ buttonType: VirtualControllerButton.ButtonType) {
        super.touchDown(buttonType)
        switch buttonType {
        case .dpadUp:
            cytrus.virtualControllerButtonDown(.directionalPadUp)
        case .dpadDown:
            cytrus.virtualControllerButtonDown(.directionalPadDown)
        case .dpadLeft:
            cytrus.virtualControllerButtonDown(.directionalPadLeft)
        case .dpadRight:
            cytrus.virtualControllerButtonDown(.directionalPadRight)
        case .minus:
            cytrus.virtualControllerButtonDown(.select)
        case .plus:
            cytrus.virtualControllerButtonDown(.start)
        case .a:
            cytrus.virtualControllerButtonDown(.A)
        case .b:
            cytrus.virtualControllerButtonDown(.B)
        case .x:
            cytrus.virtualControllerButtonDown(.X)
        case .y:
            cytrus.virtualControllerButtonDown(.Y)
        case .l:
            cytrus.virtualControllerButtonDown(.triggerL)
        case .zl:
            cytrus.virtualControllerButtonDown(.triggerZL)
        case .r:
            cytrus.virtualControllerButtonDown(.triggerR)
        case .zr:
            cytrus.virtualControllerButtonDown(.triggerZR)
        }
    }
    
    override func touchUpInside(_ buttonType: VirtualControllerButton.ButtonType) {
        super.touchUpInside(buttonType)
        switch buttonType {
        case .dpadUp:
            cytrus.virtualControllerButtonUp(.directionalPadUp)
        case .dpadDown:
            cytrus.virtualControllerButtonUp(.directionalPadDown)
        case .dpadLeft:
            cytrus.virtualControllerButtonUp(.directionalPadLeft)
        case .dpadRight:
            cytrus.virtualControllerButtonUp(.directionalPadRight)
        case .minus:
            cytrus.virtualControllerButtonUp(.select)
        case .plus:
            cytrus.virtualControllerButtonUp(.start)
        case .a:
            cytrus.virtualControllerButtonUp(.A)
        case .b:
            cytrus.virtualControllerButtonUp(.B)
        case .x:
            cytrus.virtualControllerButtonUp(.X)
        case .y:
            cytrus.virtualControllerButtonUp(.Y)
        case .l:
            cytrus.virtualControllerButtonUp(.triggerL)
        case .zl:
            cytrus.virtualControllerButtonUp(.triggerZL)
        case .r:
            cytrus.virtualControllerButtonUp(.triggerR)
        case .zr:
            cytrus.virtualControllerButtonUp(.triggerZR)
        }
    }
    
    override func touchDown(_ thumbstickType: VirtualControllerThumbstick.ThumbstickType, _ location: (x: Float, y: Float)) {
        super.touchDown(thumbstickType, location)
        cytrus.thumbstickMoved(thumbstickType == .thumbstickLeft ? .circlePad : .cStick, location.x, location.y)
    }
    
    override func touchDragInside(_ thumbstickType: VirtualControllerThumbstick.ThumbstickType, _ location: (x: Float, y: Float)) {
        super.touchDragInside(thumbstickType, location)
        cytrus.thumbstickMoved(thumbstickType == .thumbstickLeft ? .circlePad : .cStick, location.x, location.y)
    }
    
    override func touchUpInside(_ thumbstickType: VirtualControllerThumbstick.ThumbstickType, _ location: (x: Float, y: Float)) {
        super.touchUpInside(thumbstickType, location)
        cytrus.thumbstickMoved(thumbstickType == .thumbstickLeft ? .circlePad : .cStick, location.x, location.y)
    }
}
*/
