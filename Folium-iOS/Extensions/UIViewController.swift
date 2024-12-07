//
//  UIViewController.swift
//  Folium-tvOS
//
//  Created by Jarrod Norwell on 2/7/2024.
//

import Foundation
import QuartzCore
import UIKit
import FUIAlertKit

class ProgressiveVisualEffectView : UIVisualEffectView {}

extension UIViewController {
    func alert(title: String? = nil, message: String? = nil, preferredStyle: UIAlertController.Style = .alert,
                      actions: [UIAlertAction]? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        if let actions {
            actions.forEach { alertController.addAction($0) }
        }
        
        return alertController
    }
    
    func interfaceOrientation() -> UIInterfaceOrientation {
        guard let window = view.window, let windowScene = window.windowScene else {
            return .portrait
        }
        
        return windowScene.interfaceOrientation
    }
    
    func prefersLargeTitles(_ preferred: Bool = false) {
        guard let navigationController else {
            return
        }
        
        navigationController.navigationBar.prefersLargeTitles = preferred
    }
    
    func screen() -> UIScreen {
        guard let window = view.window, let windowScene = window.windowScene else {
            return .main
        }
        
        return windowScene.screen
    }
    
    func toggleProgressiveVisualEffectView(_ isVisible: Bool = false) {
        if let visualEffectView = view.subviews.first(where: { $0.isKind(of: ProgressiveVisualEffectView.classForCoder()) }) {
            UIView.animate(withDuration: 0.2) {
                visualEffectView.alpha = isVisible ? 1 : 0
            }
        } else {
            guard let lastSubview = view.subviews.last else {
                return
            }
            
            let visualEffectView = ProgressiveVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial))
            visualEffectView.translatesAutoresizingMaskIntoConstraints = false
            UIView.animate(withDuration: 0.2) {
                visualEffectView.alpha = isVisible ? 1 : 0
            }
            view.insertSubview(visualEffectView, aboveSubview: lastSubview)
            
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            visualEffectView.heightAnchor.constraint(equalToConstant: view.safeAreaInsets.top).isActive = true
        }
    }
}
