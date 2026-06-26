//
//  OnboardingModel.swift
//  Folium
//
//  Created by Jarrod Norwell on 7/6/2026.
//

import ColourKit
import ExtensionsKit
import FontKit
import OnboardingKit
import UIKit

actor OnboardingModel {
    private let gamesManager: GamesManager
    
    init(gamesManager: GamesManager) {
        self.gamesManager = gamesManager
    }
    
    func camera(controller: UIViewController) async {
        var viewController: OBController {
            let textConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                           color: .label,
                                                                           font: .regular(from: .extraLargeTitle),
                                                                           text: "Camera")
            
            let secondaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                    color: .secondaryLabel,
                                                                                    font: .regular(from: .body),
                                                                                    text: "Folium may require access to Camera where it is used for game and system functionality")
            
            let buttons: [(UIButton.Configuration, @MainActor (UIViewController) async -> Void)] = [
                (UIButton.Configuration.configuration(.large, .capsule, nil, "Continue"), { controller in
                    await self.microphone(controller: controller)
                })
            ]
            
            let configuration: OBControllerConfiguration = OBControllerConfiguration(image: UIImage(systemName: "camera.fill"),
                                                                                     textConfiguration: textConfiguration,
                                                                                     secondaryConfiguration: secondaryTextConfiguration,
                                                                                     tertiaryConfiguration: nil,
                                                                                     buttons: buttons,
                                                                                     colors: Colour.vibrantGreens)
            
            let obController: OBController = OBController(configuration: configuration)
            onMainThread {
                obController.modalPresentationStyle = .fullScreen
            }
            return obController
        }
        
        await controller.present(viewController, animated: true)
    }
    
    private func microphone(controller: UIViewController) async {
        var viewController: OBController {
            let textConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                           color: .label,
                                                                           font: .regular(from: .extraLargeTitle),
                                                                           text: "Microphone")
            
            let secondaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                    color: .secondaryLabel,
                                                                                    font: .regular(from: .body),
                                                                                    text: "Folium may require access to Microphone where it is used for game and system functionality")
            
            let buttons: [(UIButton.Configuration, @MainActor (UIViewController) async -> Void)] = [
                (UIButton.Configuration.configuration(.large, .capsule, nil, "Continue"), { controller in
                    await self.motion(controller: controller)
                })
            ]
            
            let configuration: OBControllerConfiguration = OBControllerConfiguration(image: UIImage(systemName: "microphone.and.signal.meter.fill"),
                                                                                     textConfiguration: textConfiguration,
                                                                                     secondaryConfiguration: secondaryTextConfiguration,
                                                                                     tertiaryConfiguration: nil,
                                                                                     buttons: buttons,
                                                                                     colors: Colour.vibrantOranges)
            
            let obController: OBController = OBController(configuration: configuration)
            onMainThread {
                obController.modalPresentationStyle = .fullScreen
            }
            return obController
        }
        
        await controller.present(viewController, animated: true)
    }
    
    private func motion(controller: UIViewController) async {
        var viewController: OBController {
            let textConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                           color: .label,
                                                                           font: .regular(from: .extraLargeTitle),
                                                                           text: "Motion")
            
            let secondaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                    color: .secondaryLabel,
                                                                                    font: .regular(from: .body),
                                                                                    text: "Folium may require access to Motion where it is used for game and system functionality")
            
            let buttons: [(UIButton.Configuration, @MainActor (UIViewController) async -> Void)] = [
                (UIButton.Configuration.configuration(.large, .capsule, nil, "Continue"), { controller in
                    UserDefaults.standard.set(true, forKey: "folium.onboardingComplete")
                    
                    onMainThread {
                        let viewController: TabController = TabController(gamesManager: self.gamesManager)
                        viewController.modalPresentationStyle = .fullScreen
                        controller.present(viewController, animated: true)
                    }
                })
            ]
            
            let configuration: OBControllerConfiguration = OBControllerConfiguration(image: UIImage(systemName: "figure.walk.motion"),
                                                                                     textConfiguration: textConfiguration,
                                                                                     secondaryConfiguration: secondaryTextConfiguration,
                                                                                     tertiaryConfiguration: nil,
                                                                                     buttons: buttons,
                                                                                     colors: Colour.vibrantGreens)
            
            let obController: OBController = OBController(configuration: configuration)
            onMainThread {
                obController.modalPresentationStyle = .fullScreen
            }
            return obController
        }
        
        await controller.present(viewController, animated: true)
    }
}
