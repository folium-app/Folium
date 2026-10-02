//
//  FoliumOnboardingController.swift
//  Folium
//
//  Created by Jarrod Norwell on 3/10/2026.
//

import ColourKit
import ExtensionsKit
import FontKit
import OnboardingKit
import SwiftUI
import UIKit

// MARK: Finished (3/10/2026)

final class FoliumOnboardingController : OBController {
    init(_ viewController: UIViewController, _ handler: @escaping @MainActor (UIViewController) async -> Void) {
        let textFont: UIFont = .regular(from: .compatibleExtraLargeTitle)
        
        let image: UIImage? = UIImage(named: "App Icon")
        
        let textConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                       color: .label,
                                                                       font: textFont,
                                                                       text: "Folium")
        
        let secondaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                color: .secondaryLabel,
                                                                                font: UIFont.regular(from: .body),
                                                                                text: "Generations of gaming in the palm of your hands")
        
        let tertiaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                               color: .tertiaryLabel,
                                                                               font: .regular(from: .callout),
                                                                               text: "Developed by Jarrod Norwell\nLicensed under GPLv3")
        
        let buttons: [(UIButton.Configuration, @MainActor (UIViewController) async -> Void)] = [
            (UIButton.Configuration.configuration(.large, .capsule, nil, "Continue"), { controller in
                await handler(controller)
            })
        ]
        
        let configuration: OBControllerConfiguration = OBControllerConfiguration(image: image,
                                                                                 textConfiguration: textConfiguration,
                                                                                 secondaryConfiguration: secondaryTextConfiguration,
                                                                                 tertiaryConfiguration: tertiaryTextConfiguration,
                                                                                 shouldUseVibrancy: false,
                                                                                 buttons: buttons,
                                                                                 colors: Color.vibrantIndigos)
        
        super.init(configuration: configuration)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
