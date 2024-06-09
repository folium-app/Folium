//
//  SceneDelegate.swift
//  Folium
//
//  Created by Jarrod Norwell on 11/5/2024.
//

import Cytrus
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        // print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path)
        CytrusSettings.Settings.shared.setDefaultSettingsIfNeeded()
        
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        
        window = .init(windowScene: windowScene)
        guard let window else {
            return
        }
        
        print(UIScreen.main.bounds)
        
        //  w     h
        // 430 x 932 - iPhone 15 Pro Max (iPhone16,2)
        /*
        let buttons: [Skin.Button] = [
            .init(useCustom: false, vibrateWhenTapped: true, vibrationStrength: 3, x: 80, y: 839-180, width: 60, height: 60, type: .dpadUp),
            .init(useCustom: false, vibrateWhenTapped: true, vibrationStrength: 3, x: 80, y: 839-60, width: 60, height: 60, type: .dpadDown),
            .init(useCustom: false, vibrateWhenTapped: true, vibrationStrength: 3, x: 20, y: 839-120, width: 60, height: 60, type: .dpadLeft),
            .init(useCustom: false, vibrateWhenTapped: true, vibrationStrength: 3, x: 140, y: 839-120, width: 60, height: 60, type: .dpadRight),
            
            .init(useCustom: false, vibrateWhenTapped: true, vibrationStrength: 3, x: 430-140, y: 839-180, width: 60, height: 60, type: .north),
            .init(useCustom: false, vibrateWhenTapped: true, vibrationStrength: 3, x: 430-80, y: 839-120, width: 60, height: 60, type: .east),
            .init(useCustom: false, vibrateWhenTapped: true, vibrationStrength: 3, x: 430-140, y: 839-60, width: 60, height: 60, type: .south),
            .init(useCustom: false, vibrateWhenTapped: true, vibrationStrength: 3, x: 430-200, y: 839-120, width: 60, height: 60, type: .west)
        ]
        
        let devices: [Skin.Device] = [
            .init(device: "iPhone16,2", orientation: .portrait, buttons: buttons, screens: [
                .init(x: 0, y: 0, width: 430, height: 258 + 322)
            ])
        ]
        
        let skin = Skin(author: "Antique", description: "A basic skin for Game Boy Advance", name: "GBA Skin", core: .cytrus, devices: devices)
         */
        
        window.rootViewController = /*CytrusDefaultViewController(with: skin)*/ ScanningController()
        window.tintColor = .systemGreen
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        NotificationCenter.default.post(name: .init("sceneDidChange"), object: nil, userInfo: [
            "state" : 1
        ])
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        NotificationCenter.default.post(name: .init("sceneDidChange"), object: nil, userInfo: [
            "state" : 0
        ])
    }
}
