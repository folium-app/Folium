//
//  SceneDelegate.swift
//  Folium
//
//  Created by Jarrod Norwell on 3/6/2026.
//

import ColourKit
import ExtensionsKit
import FontKit
import OnboardingKit
import UIKit

import Mandarine
import Tomato

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow? = nil
    
    var directoryManager: DirectoryManager = DirectoryManager()
    
    var mandarineSystem: MandarineSystem = MandarineSystem()
    var tomatoSystem: TomatoSystem = TomatoSystem()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        
        let gamesManager: GamesManager = GamesManager(mandarineSystem: mandarineSystem,
                                                      tomatoSystem: tomatoSystem)
        let onboardingModel: OnboardingModel = OnboardingModel(gamesManager: gamesManager)
        
        window = UIWindow(windowScene: windowScene)
        guard let window else {
            return
        }
        
        let onboardingComplete: Bool = UserDefaults.standard.bool(forKey: "folium.onboardingComplete")
        
        var onboardingController: OBController {
            let textFont: UIFont =  UIFont.regular(from: .extraLargeTitle)
            
            let image: UIImage? = UIImage(systemName: "leaf.fill")
            
            let textConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                           color: .label,
                                                                           font: textFont,
                                                                           text: "Folium")
            
            let secondaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                    color: .secondaryLabel,
                                                                                    font: UIFont.regular(from: .body),
                                                                                    text: "Multi-system emulation in the palm of your hands")
            
            let tertiaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                   color: .tertiaryLabel,
                                                                                   font: UIFont.regular(from: .callout),
                                                                                   text: "Developed by Jarrod Norwell\nLicensed under GPLv3")
            
            let buttons: [(UIButton.Configuration, @MainActor (UIViewController) async -> Void)] = [
                (UIButton.Configuration.configuration(.large, .capsule, nil, "Continue"), { controller in
                    await onboardingModel.camera(controller: controller)
                })
            ]
            
            let configuration: OBControllerConfiguration = OBControllerConfiguration(image: image,
                                                                                     textConfiguration: textConfiguration,
                                                                                     secondaryConfiguration: secondaryTextConfiguration,
                                                                                     tertiaryConfiguration: tertiaryTextConfiguration,
                                                                                     buttons: buttons, colors: Colour.vibrantGreens)
            
            return OBController(configuration: configuration)
        }
        
        window.rootViewController = if onboardingComplete {
            TabController(gamesManager: gamesManager)
        } else {
            onboardingController
        }
        
        window.tintColor = .systemGreen
        window.makeKeyAndVisible()
        
        let task: Task = Task {
            try await directoryManager.initializeSystemDirectoriesForInitialLaunch()
        }
        
        Task {
            switch await task.result {
            case .success(_):
                await mandarineSystem.initializePaths()
                await mandarineSystem.initializeMemoryCards()
                await mandarineSystem.initializeSystem()
                
                // reversed because the system needs to be created firat
                await tomatoSystem.initializeSystem()
                await tomatoSystem.initializePaths()
            case .failure(let failure):
                print(failure, failure.localizedDescription)
            }
        }
        
        initializeUserDefaultsWithDefaultValues()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {
        // pause
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // resume, if enabled
    }
    
    private func initializeUserDefaultsWithDefaultValues() {
        let systemsWithValues: [System : [String : Any]] = [
            .mandarine : [
                "widescreen" : false,
                "forceWidescreen" : false,
                "vsync" : false,
                "forceNTSC" : false,
                "height" : 480,
                "width" : 640,
                "soundEnabled" : true,
                "extendedMemory" : false
            ]
        ]
        
        let userDefaults: UserDefaults = .standard
        for (system, values) in systemsWithValues {
            for (key, value) in values {
                if userDefaults.value(forKey: "\(system.string.localizedLowercase).\(key)") == nil {
                    userDefaults.set(value, forKey: "\(system.string.localizedLowercase).\(key)")
                }
            }
        }
    }
}
