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
    @MainActor
    func camera(controller: UIViewController) async {
        var fontPackageController: OBController {
            let textFont: UIFont = UIFont.regular(from: .extraLargeTitle)
            
            let image: UIImage? = UIImage(systemName: "camera.fill")
            
            let textConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                           color: .label,
                                                                           font: textFont,
                                                                           text: "Camera")
            
            let secondaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                    color: .secondaryLabel,
                                                                                    font: UIFont.regular(from: .body),
                                                                                    text: "Folium may require access to your Camera where it is used for game and system functionality")
            
            let buttons: [(UIButton.Configuration, @MainActor (UIViewController) async -> Void)] = [
                (UIButton.Configuration.configuration(.large, .capsule, nil, "Continue"), { controller in
                    await self.microphone(controller: controller)
                })
            ]
            
            let configuration: OBControllerConfiguration = OBControllerConfiguration(image: image,
                                                                                     textConfiguration: textConfiguration,
                                                                                     secondaryConfiguration: secondaryTextConfiguration,
                                                                                     tertiaryConfiguration: nil,
                                                                                     buttons: buttons, colors: Colour.vibrantGreens)
            
            let obController: OBController = OBController(configuration: configuration)
            obController.modalPresentationStyle = .fullScreen
            return obController
        }
        
        controller.present(fontPackageController, animated: true)
    }
    
    // TODO: change this
    @MainActor
    func microphone(controller: UIViewController) async {
        var fontPackageController: OBController {
            let textFont: UIFont = UIFont.regular(from: .extraLargeTitle)
            
            let image: UIImage? = UIImage(systemName: "microphone.fill")
            
            let textConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                           color: .label,
                                                                           font: textFont,
                                                                           text: "Microphone")
            
            let secondaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                    color: .secondaryLabel,
                                                                                    font: UIFont.regular(from: .body),
                                                                                    text: "Folium may require access to your Microphone where it is used for game and system functionality")
            
            let buttons: [(UIButton.Configuration, @MainActor (UIViewController) async -> Void)] = [
                (UIButton.Configuration.configuration(.large, .capsule, nil, "Continue"), { controller in
                    await self.motion(controller: controller)
                })
            ]
            
            let configuration: OBControllerConfiguration = OBControllerConfiguration(image: image,
                                                                                     textConfiguration: textConfiguration,
                                                                                     secondaryConfiguration: secondaryTextConfiguration,
                                                                                     tertiaryConfiguration: nil,
                                                                                     buttons: buttons, colors: Colour.vibrantOranges)
            
            let obController: OBController = OBController(configuration: configuration)
            obController.modalPresentationStyle = .fullScreen
            return obController
        }
        
        controller.present(fontPackageController, animated: true)
    }
    
    // TODO: change this
    @MainActor
    func motion(controller: UIViewController) async {
        var fontPackageController: OBController {
            let textFont: UIFont = UIFont.regular(from: .extraLargeTitle)
            
            let image: UIImage? = UIImage(systemName: "figure.walk.motion")
            
            let textConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                           color: .label,
                                                                           font: textFont,
                                                                           text: "Motion")
            
            let secondaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                    color: .secondaryLabel,
                                                                                    font: UIFont.regular(from: .body),
                                                                                    text: "Folium may require access to Motion where it is used for game and system functionality")
            
            let buttons: [(UIButton.Configuration, @MainActor (UIViewController) async -> Void)] = [
                (UIButton.Configuration.configuration(.large, .capsule, nil, "Continue"), { controller in
                    UserDefaults.standard.set(true, forKey: "folium.onboardingComplete")
                    
                    DispatchQueue.main.async {
                        let viewController: TabController = TabController()
                        viewController.modalPresentationStyle = .fullScreen
                        controller.present(viewController, animated: true)
                    }
                })
            ]
            
            let configuration: OBControllerConfiguration = OBControllerConfiguration(image: image,
                                                                                     textConfiguration: textConfiguration,
                                                                                     secondaryConfiguration: secondaryTextConfiguration,
                                                                                     tertiaryConfiguration: nil,
                                                                                     buttons: buttons, colors: Colour.vibrantGreens)
            
            let obController: OBController = OBController(configuration: configuration)
            obController.modalPresentationStyle = .fullScreen
            return obController
        }
        
        controller.present(fontPackageController, animated: true)
    }
}
