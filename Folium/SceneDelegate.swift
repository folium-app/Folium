//
//  SceneDelegate.swift
//  Folium
//
//  Created by Jarrod Norwell on 11/5/2024.
//

import AVKit
#if canImport(Cytrus)
import Cytrus
#endif
import ZIPFoundation
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    enum ApplicationState : Int {
        case background = 0
        case foreground = 1
    }
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        // print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path)
        do {
            try DirectoryManager.shared.createMissingDirectoriesInDocumentsDirectory()
        } catch { }
        Core.cores.forEach { core in
            DirectoryManager.shared.scanDirectoriesForRequiredFiles(core)
        }
#if canImport(Cytrus)
        CytrusSettings.Settings.shared.setDefaultSettingsIfNeeded()
#endif
        
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        
        window = .init(windowScene: windowScene)
        guard let window else {
            return
        }
        
        extractDefaultSkinsIfAllowed()
        prepareAudioForInputAndOutput()
        
        window.rootViewController = UINavigationController(rootViewController: LibraryController(collectionViewLayout: LayoutManager.shared.library))
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
        NotificationCenter.default.post(name: .init("sceneDidChange"), object: ApplicationState.foreground)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        NotificationCenter.default.post(name: .init("sceneDidChange"), object: ApplicationState.background)
    }
}

extension SceneDelegate {
    func extractDefaultSkinsIfAllowed() {
        if AppStoreCheck.shared.currentAppEnvironment() == .appStore || AppStoreCheck.shared.currentAppEnvironment() == .testFlight || AppStoreCheck.shared.currentAppEnvironment() == .other {
            let defaultSkins = [("Grape", "mtcbxDeltaSkinDS")]
            do {
                try defaultSkins.forEach { defaultSkin in
                    let destinationURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                        .appendingPathComponent(defaultSkin.0, conformingTo: .folder)
                        .appendingPathComponent("skins", conformingTo: .folder)
                    
                    if FileManager.default.fileExists(atPath: destinationURL.appendingPathComponent(defaultSkin.1, conformingTo: .folder).path) {
                        try FileManager.default.removeItem(atPath: destinationURL.appendingPathComponent("__MACOSX", conformingTo: .folder).path)
                        try FileManager.default.removeItem(atPath: destinationURL.appendingPathComponent(defaultSkin.1, conformingTo: .folder).path)
                    }
                    
                    if let url = Bundle.main.url(forResource: defaultSkin.1, withExtension: "zip") {
                        do {
                            try FileManager.default.unzipItem(at: url, to: destinationURL)
                        } catch { print(error, error.localizedDescription) }
                    }
                }
            } catch { print(error, error.localizedDescription) }
        }
    }
    
    func prepareAudioForInputAndOutput() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP, .mixWithOthers])
            
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { print(error, error.localizedDescription) }
    }
}
