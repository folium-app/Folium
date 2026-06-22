//
//  NoEmulationController.swift
//  Folium
//
//  Created by Jarrod Norwell on 23/6/2026.
//

import ColourKit
import FontKit
import OnboardingKit
import UIKit

class NoEmulationController : OBController {
    init() {
        let textFont: UIFont = if #available(iOS 17.0, *) {
            UIFont.regular(from: .extraLargeTitle)
        } else {
            UIFont.regular(from: .largeTitle)
        }
        
        let image: UIImage? = UIImage(systemName: "opticaldisc.fill")
        
        let textConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                       color: .label,
                                                                       font: textFont,
                                                                       text: "Select a Game")
        
        let secondaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                color: .secondaryLabel,
                                                                                font: UIFont.regular(from: .body),
                                                                                text: "Select a game from the Games screen")
        
        let configuration: OBControllerConfiguration = OBControllerConfiguration(image: image,
                                                                                 textConfiguration: textConfiguration,
                                                                                 secondaryConfiguration: secondaryTextConfiguration,
                                                                                 tertiaryConfiguration: nil,
                                                                                 buttons: [], colors: Colour.vibrantGreens)
        super.init(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarItem.badgeValue = nil
    }
}
