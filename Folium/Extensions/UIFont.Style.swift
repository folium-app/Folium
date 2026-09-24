//
//  UIFont.Style.swift
//  Folium
//
//  Created by Jarrod Norwell on 22/8/2026.
//

import UIKit

extension UIFont.TextStyle {
    static var compatibleExtraLargeTitle: UIFont.TextStyle {
        if #available(iOS 17, *) {
            UIFont.TextStyle.extraLargeTitle
        } else {
            UIFont.TextStyle.largeTitle
        }
    }
}
