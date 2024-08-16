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
    case disconnected = 2
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        FirebaseApp.configure()
        
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        
        window = .init(windowScene: windowScene)
        guard let window else {
            return
        }
        
        do {
            try cleanupForLatestRelease()
        } catch {
            print(#function, "cleanupForLatestRelease()", error)
        }
        
        configureAuthenticationStateListener(with: window)
        
        do {
            try configureMissingDirectories(for: LibraryManager.shared.cores.reduce(into: [String](), { partialResult, element in
                partialResult.append(element.description)
            }))
        } catch {
            print(#function, "configureMissingDirectories(for:)", error)
        }
        
        configureDefaultUserDefaults()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        NotificationCenter.default.post(name: .init("applicationStateDidChange"), object: ApplicationState.disconnected)
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

extension SceneDelegate {
    fileprivate func configureAuthenticationStateListener(with window: UIWindow) {
        _ = Auth.auth().addStateDidChangeListener { auth, user in
            window.rootViewController = if AppStoreCheck.shared.additionalFeaturesAreAllowed() {
                if user == nil {
                    AuthenticationController()
                } else {
                    UINavigationController(rootViewController: LibraryController(collectionViewLayout: LayoutManager.shared.library))
                }
            } else {
                UINavigationController(rootViewController: LibraryController(collectionViewLayout: LayoutManager.shared.library))
            }
            
            window.makeKeyAndVisible()
        }
    }
    
    fileprivate func configureMissingDirectories(for cores: [String]) throws {
        try DirectoryManager.shared.createMissingDirectoriesInDocumentsDirectory(for: cores)
    }
    
    fileprivate func cleanupForLatestRelease() throws {
        let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? NSString
        
        if let version, version.doubleValue >= 1.7, !UserDefaults.standard.bool(forKey: "isCleanedUpForLatestRelease") {
            if let bundleIdentifier = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
            }
            
            let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            try FileManager.default.contentsOfDirectory(atPath: documentsDirectory.path).forEach { content in
                if !content.contains("/roms/") {
                    try FileManager.default.removeItem(atPath: documentsDirectory.appending(path: content).path)
                }
            }
            
            UserDefaults.standard.set(true, forKey: "isCleanedUpForLatestRelease")
        }
    }
    
    fileprivate func configureDefaultUserDefaults() {
        let defaults: [String : [String : Any]] = [
            "Cytrus" : [
                "cpuClockPercentage" : 100,
                "useNew3DS" : true,
                "regionValue" : -1,
                
                "spirvShaderGeneration" : true,
                "useAsyncShaderCompilation" : false,
                "useAsyncPresentation" : true,
                "useHardwareShaders" : true,
                "useDiskShaderCache" : true,
                "useShadersAccurateMul" : false,
                "useNewVSync" : true
            ]
        ]
        
        defaults.forEach { core, values in
            values.forEach { key, value in
                if UserDefaults.standard.value(forKey: "\(core.lowercased()).\(key)") == nil {
                    UserDefaults.standard.set(value, forKey: "\(core.lowercased()).\(key)")
                }
            }
        }
    }
}
