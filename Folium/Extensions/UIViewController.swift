//
//  UIViewController.swift
//  Folium
//
//  Created by Jarrod Norwell on 23/6/2026.
//

import UIKit

extension UIViewController {
    var windowScene: UIWindowScene? {
        if let window: UIWindow = view.window, let currentWindowScene: UIWindowScene = window.windowScene {
            currentWindowScene
        } else if let currentWindowScene: UIWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            currentWindowScene
        } else {
            nil
        }
    }
    
    func notifySuccess() {
        if #available(iOS 17.5, *) {
            UINotificationFeedbackGenerator(view: view).notificationOccurred(.success)
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}
