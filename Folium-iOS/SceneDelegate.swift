//
//  SceneDelegate.swift
//  Folium
//
//  Created by Jarrod Norwell on 2/7/2024.
//

import DirectoryManager
import Firebase
import FirebaseAuth
import LayoutManager
import UIKit

enum ApplicationState : Int {
    case backgrounded = 0
    case foregrounded = 1
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        // print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path)
        FirebaseApp.configure()
        
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        
        window = .init(windowScene: windowScene)
        guard let window else {
            return
        }
        
        // for testing skins with the simulator
        // window.rootViewController = ControllerTestEmulationController(skin: SkinManager.shared.cytrusSkin!)
        // window.makeKeyAndVisible()
        
        // this is needed because Auth doesn't initialize right away
        _ = Auth.auth().addStateDidChangeListener { auth, user in
            window.rootViewController = if [.appStore, .other].contains(AppStoreCheck.shared.currentAppEnvironment()) {
                if let _ = user {
                    UINavigationController(rootViewController: LibraryController(collectionViewLayout: LayoutManager.shared.library))
                } else {
                    AuthenticationController()
                }
            } else {
                UINavigationController(rootViewController: LibraryController(collectionViewLayout: LayoutManager.shared.library))
            }
            
            window.makeKeyAndVisible()
        }
        
        let task = Task { try DirectoryManager.shared.createMissingDirectoriesInDocumentsDirectory(for: LibraryManager.shared.cores.reduce(into: [String](), { $0.append($1.rawValue) })) }
        Task {
            switch await task.result {
            case .failure(let error):
                print("\(#function): failed: \(error.localizedDescription)")
            case .success(_):
                print("\(#function): success")
            }
        }
        
        let defaults: [String : Any] = [
            "cytrus.v1.7.cpuClockPercentage" : 100,
            "cytrus.v1.7.useNew3DS" : true,
            "cytrus.v1.7.regionValue" : -1,
            
            "cytrus.v1.7.spirvShaderGeneration" : true,
            "cytrus.v1.7.useAsyncShaderCompilation" : false,
            "cytrus.v1.7.useAsyncPresentation" : true,
            "cytrus.v1.7.useHardwareShaders" : true,
            "cytrus.v1.7.useDiskShaderCache" : true,
            "cytrus.v1.7.useShadersAccurateMul" : false,
            "cytrus.v1.7.useNewVSync" : true
        ]
        
        defaults.forEach { key, value in
            if UserDefaults.standard.value(forKey: key) == nil {
                UserDefaults.standard.set(value, forKey: key)
            }
        }
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
        NotificationCenter.default.post(name: .init("applicationStateDidChange"), object: ApplicationState.foregrounded)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        NotificationCenter.default.post(name: .init("applicationStateDidChange"), object: ApplicationState.backgrounded)
    }
}
