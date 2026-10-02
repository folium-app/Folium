//
//  MotionAuthorizationController.swift
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

final class MotionAuthorizationController : OBController {
    init(_ viewController: UIViewController, _ handler: @escaping @MainActor (UIViewController) async -> Void) {
        let textFont: UIFont = .regular(from: .compatibleExtraLargeTitle)
        
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
                await handler(controller)
            })
        ]
        
        let configuration: OBControllerConfiguration = OBControllerConfiguration(image: image,
                                                                                 textConfiguration: textConfiguration,
                                                                                 secondaryConfiguration: secondaryTextConfiguration,
                                                                                 tertiaryConfiguration: nil,
                                                                                 buttons: buttons,
                                                                                 colors: Color.vibrantGreens)
        
        super.init(configuration: configuration)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
