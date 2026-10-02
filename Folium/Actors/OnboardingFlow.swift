//
//  OnboardingFlow.swift
//  Folium
//
//  Created by Jarrod Norwell on 7/6/2026.
//

import UIKit

// MARK: Finished (3/10/2026)

actor OnboardingFlow {
    private let authorizationActors: AuthorizationActors
    
    private let directoryManager: DirectoryManager
    private let gamePopulationManager: GamePopulationManager
    
    init(_ authorizationActors: AuthorizationActors, _ directoryManager: DirectoryManager, _ gamePopulationManager: GamePopulationManager) {
        self.authorizationActors = authorizationActors
        
        self.directoryManager = directoryManager
        self.gamePopulationManager = gamePopulationManager
    }
    
    func cameraAuthorization(_ presentingController: UIViewController) async {
        if await authorizationActors.cameraAuthorization.checkAuthorizationStatus() {
            await microphoneAuthorization(presentingController)
        } else {
            await onMainThread {
                let cameraAuthorizationController: CameraAuthorizationController = CameraAuthorizationController(presentingController) { controller in
                    _ = await self.authorizationActors.cameraAuthorization.authorize()
                    await self.microphoneAuthorization(controller)
                }
                cameraAuthorizationController.modalPresentationStyle = .fullScreen
                presentingController.present(cameraAuthorizationController, animated: true)
            }
        }
    }
    
    func microphoneAuthorization(_ presentingController: UIViewController) async {
        let result = if #available(iOS 17, *) {
            await authorizationActors.microphoneAuthorization.checkAuthorizationStatus()
        } else {
            await authorizationActors.deprecatedMicrophoneAuthorization.checkAuthorizationStatus()
        }
        
        if result {
            await motionAuthorization(presentingController)
        } else {
            await onMainThread {
                let microphoneAuthorizationController: MicrophoneAuthorizationController = MicrophoneAuthorizationController(presentingController) { controller in
                    if #available(iOS 17, *) {
                        _ = await self.authorizationActors.microphoneAuthorization.authorize()
                    } else {
                        _ = await self.authorizationActors.deprecatedMicrophoneAuthorization.authorize()
                    }
                    
                    await self.motionAuthorization(controller)
                }
                microphoneAuthorizationController.modalPresentationStyle = .fullScreen
                presentingController.present(microphoneAuthorizationController, animated: true)
            }
        }
    }
    
    func motionAuthorization(_ presentingController: UIViewController) async {
        if await authorizationActors.motionAuthorization.checkAuthorizationStatus() {
            UserDefaults.standard.set(true, forKey: "folium.onboardingComplete")
            
            await onMainThread {
                let viewController = TabController(directoryManager: self.directoryManager, gamePopulationManager: self.gamePopulationManager)
                viewController.modalPresentationStyle = .fullScreen
                presentingController.present(viewController, animated: true)
            }
        } else {
            await onMainThread {
                let motionAuthorizationController: MotionAuthorizationController = MotionAuthorizationController(presentingController) { controller in
                    _ = await self.authorizationActors.motionAuthorization.authorize()
                    
                    UserDefaults.standard.set(true, forKey: "folium.onboardingComplete")
                    
                    let viewController: TabController = TabController(directoryManager: self.directoryManager, gamePopulationManager: self.gamePopulationManager)
                    viewController.modalPresentationStyle = .fullScreen
                    controller.present(viewController, animated: true)
                }
                motionAuthorizationController.modalPresentationStyle = .fullScreen
                presentingController.present(motionAuthorizationController, animated: true)
            }
        }
    }
}
