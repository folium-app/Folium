//
//  UIViewController.swift
//  Folium-tvOS
//
//  Created by Jarrod Norwell on 2/7/2024.
//

import Foundation
import UIKit

extension UIViewController {
    func alert(with title: String? = nil, message: String? = nil, preferredStyle: UIAlertController.Style = .alert,
                      actions: [UIAlertAction]? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        if let actions {
            actions.forEach { alertController.addAction($0) }
        }
        
        return alertController
    }
}
