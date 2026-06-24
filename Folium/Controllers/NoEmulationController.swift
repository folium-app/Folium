//
//  NoEmulationController.swift
//  Folium
//
//  Created by Jarrod Norwell on 23/6/2026.
//

import ColourKit
import FontKit
import OnboardingKit
import SwiftUI
import UIKit

class NoEmulationController : OBController {
    init() {
        let textConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                       color: .label,
                                                                       font: .regular(from: .extraLargeTitle),
                                                                       text: "Select a Game")
        
        let secondaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                color: .secondaryLabel,
                                                                                font: .regular(from: .body),
                                                                                text: "Select a game from the Games screen")
        
        let configuration: OBControllerConfiguration = OBControllerConfiguration(image: UIImage(systemName: "opticaldisc.fill"),
                                                                                 textConfiguration: textConfiguration,
                                                                                 secondaryConfiguration: secondaryTextConfiguration,
                                                                                 tertiaryConfiguration: nil,
                                                                                 buttons: [],
                                                                                 colors: [
                                                                                    Colour(red: 0.90, green: 0.90, blue: 1.00),
                                                                                    Colour(red: 0.80, green: 0.80, blue: 1.00),
                                                                                    Colour(red: 0.70, green: 0.70, blue: 1.00),
                                                                                    Colour(red: 0.55, green: 0.55, blue: 0.95),
                                                                                    Colour(red: 0.45, green: 0.45, blue: 0.90),
                                                                                    Colour(red: 0.35, green: 0.35, blue: 0.84), // iOS systemIndigo
                                                                                    Colour(red: 0.30, green: 0.30, blue: 0.72),
                                                                                    Colour(red: 0.25, green: 0.25, blue: 0.60),
                                                                                    Colour(red: 0.20, green: 0.20, blue: 0.48)
                                                                                 ])
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
