//
//  WhatsNewController.swift
//  Folium
//
//  Created by Jarrod Norwell on 27/9/2026.
//

import Foundation
import ExtensionsKit
import FontKit
import OnboardingKit
import UIKit

class WhatsNewController : OBControllerWithList {
    init() {
        let textFont: UIFont = .regular(from: .compatibleExtraLargeTitle)
        
        let image: UIImage? = UIImage(systemName: "sparkles")
        
        let textConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                       color: .label,
                                                                       font: textFont,
                                                                       text: "What's New")
        
        let secondaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                                color: .secondaryLabel,
                                                                                font: UIFont.regular(from: .body),
                                                                                text: "What's new in the latest version of Folium")
        
        let tertiaryTextConfiguration: LabelConfiguration = LabelConfiguration(alignment: .center,
                                                                               color: .tertiaryLabel,
                                                                               font: UIFont.regular(from: .callout),
                                                                               text: "2.2.2")
        
        let buttons: [(UIButton.Configuration, @MainActor (UIViewController) async -> Void)] = [
            (UIButton.Configuration.configuration(.large, .capsule, nil, "Continue"), { controller in
                UserDefaults.standard.set(true, forKey: "folium.2.2.2.whatsNewComplete")
                
                controller.dismiss(animated: true)
            })
        ]
        
        let cells: [String : [CellConfiguration]] = [
            "Library" : [
                CellConfiguration(image: UIImage(systemName: "character.cursor.ibeam")?
                    .applyingSymbolConfiguration(UIImage.SymbolConfiguration(paletteColors: [.label])), labels: (
                        LabelConfiguration(alignment: .left,
                                           color: .label,
                                           font: UIFont.regular(from: .headline),
                                           text: "Game Titles"),
                        LabelConfiguration(alignment: .left,
                                           color: .secondaryLabel,
                                           font: UIFont.regular(from: .subheadline),
                                           text: "Fixed an issue where game titles for Nintendo 3DS games would be read from the file name instead of the embedded header")
                    )),
                CellConfiguration(image: UIImage(systemName: "hand.point.up.left.fill")?
                    .applyingSymbolConfiguration(UIImage.SymbolConfiguration(paletteColors: [.label])), labels: (
                        LabelConfiguration(alignment: .left,
                                           color: .label,
                                           font: UIFont.regular(from: .headline),
                                           text: "Pull to Refresh"),
                        LabelConfiguration(alignment: .left,
                                           color: .secondaryLabel,
                                           font: UIFont.regular(from: .subheadline),
                                           text: "Adds a pull to refresh gesture which repopulates the games of all available systems")
                    ))
            ],
            "On-Screen Controls" : [
                CellConfiguration(image: UIImage(systemName: "l.joystick.tilt.right")?
                    .applyingSymbolConfiguration(UIImage.SymbolConfiguration(paletteColors: [.label])), labels: (
                        LabelConfiguration(alignment: .left,
                                           color: .label,
                                           font: UIFont.regular(from: .headline),
                                           text: "Analog Sticks"),
                        LabelConfiguration(alignment: .left,
                                           color: .secondaryLabel,
                                           font: UIFont.regular(from: .subheadline),
                                           text: "Adds functional left and right analog sticks to the PlayStation 1 emulation system with added support for diagonal movement")
                    ))
            ],
            "Settings" : [
                CellConfiguration(image: UIImage(systemName: "gearshape.fill")?
                    .applyingSymbolConfiguration(UIImage.SymbolConfiguration(paletteColors: [.label])), labels: (
                        LabelConfiguration(alignment: .left,
                                           color: .label,
                                           font: UIFont.regular(from: .headline),
                                           text: "Default System"),
                        LabelConfiguration(alignment: .left,
                                           color: .secondaryLabel,
                                           font: UIFont.regular(from: .subheadline),
                                           text: "Adds a new selection setting to the Application settings to set the system that will be displayed upon application launch")
                    )),
                CellConfiguration(image: UIImage(systemName: "gearshape.fill")?
                    .applyingSymbolConfiguration(UIImage.SymbolConfiguration(paletteColors: [.label])), labels: (
                        LabelConfiguration(alignment: .left,
                                           color: .label,
                                           font: UIFont.regular(from: .headline),
                                           text: "Game Boy"),
                        LabelConfiguration(alignment: .left,
                                           color: .secondaryLabel,
                                           font: UIFont.regular(from: .subheadline),
                                           text: "Adds new Game Boy, Game Boy Advance and Game Boy Color settings allowing users to set several graphics related settings")
                    )),
                CellConfiguration(image: UIImage(systemName: "gearshape.fill")?
                    .applyingSymbolConfiguration(UIImage.SymbolConfiguration(paletteColors: [.label])), labels: (
                        LabelConfiguration(alignment: .left,
                                           color: .label,
                                           font: UIFont.regular(from: .headline),
                                           text: "Nintendo DS"),
                        LabelConfiguration(alignment: .left,
                                           color: .secondaryLabel,
                                           font: UIFont.regular(from: .subheadline),
                                           text: "Adds new Nintendo DS settings allowing users to toggle boot screen skipping and set the console model")
                    ))
            ],
            "Systems" : [
                CellConfiguration(image: UIImage(systemName: "sparkle")?
                    .applyingSymbolConfiguration(UIImage.SymbolConfiguration(paletteColors: [.systemYellow])), labels: (
                        LabelConfiguration(alignment: .left,
                                           color: .label,
                                           font: UIFont.regular(from: .headline),
                                           text: "ColecoVision"),
                        LabelConfiguration(alignment: .left,
                                           color: .secondaryLabel,
                                           font: UIFont.regular(from: .subheadline),
                                           text: "Replaced the project Cherry is built on from Gearcoleco over to MesenCE and rewrote a portion of the bridging code")
                    )),
                CellConfiguration(image: UIImage(systemName: "arrow.up.forward.app.fill")?
                    .applyingSymbolConfiguration(UIImage.SymbolConfiguration(paletteColors: [.label])), labels: (
                        LabelConfiguration(alignment: .left,
                                           color: .label,
                                           font: UIFont.regular(from: .headline),
                                           text: "PlayStation 1"),
                        LabelConfiguration(alignment: .left,
                                           color: .secondaryLabel,
                                           font: UIFont.regular(from: .subheadline),
                                           text: "Adds support for Ape Escape and Gran Turismo 2, changed from Avocado to my own fork with a large potion of code rewritten")
                    ))
            ]
        ]
        
        let configuration: OBControllerWithListConfiguration = OBControllerWithListConfiguration(image: image,
                                                                                                 textConfiguration: textConfiguration,
                                                                                                 secondaryConfiguration: secondaryTextConfiguration,
                                                                                                 tertiaryConfiguration: tertiaryTextConfiguration,
                                                                                                 buttons: buttons,
                                                                                                 cells: cells)
        super.init(configuration: configuration)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
