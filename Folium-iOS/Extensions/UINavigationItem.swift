//
//  UINavigationItem.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 4/7/2024.
//

import Foundation
import UIKit

extension UINavigationItem {
    func largeTitleAccessoryView(with view: UIView) {
        perform(NSSelectorFromString("_setLargeTitleAccessoryView:"), with: view)
    }
    
    func weeTitle(with string: String) {
        perform(NSSelectorFromString("_setWeeTitle:"), with: string)
    }
}
