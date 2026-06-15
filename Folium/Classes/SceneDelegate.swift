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

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow? = nil
    
    var directoryManager: DirectoryManager = DirectoryManager()
    var onboardingModel: OnboardingModel = OnboardingModel()
    
    var mandarineSystem: MandarineSystem = MandarineSystem()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        
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
                    await self.onboardingModel.camera(controller: controller)
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
            TabController()
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
                break
            case .failure(let failure):
                print(failure, failure.localizedDescription)
            }
        }
        
        mandarineSystem.printAbout()
        mandarineSystem.initializePaths()
        mandarineSystem.initializeMemoryCards()
        mandarineSystem.initializeSystem()
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
}
