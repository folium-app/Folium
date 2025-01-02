//
//  UIApplication.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 8/9/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation
import UIKit
import FUIAlertKit

extension UIApplication {
    var window: UIWindow? {
        return self.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
    
    var alertWindow: UIWindow? {
        return self.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: { $0.isKind(of: FUIAlertKitWindow.classForCoder()) })
    }
    
    var viewController: UIViewController? {
        let base = window?.rootViewController
        return top(base)
    }
    
    func top(_ base: UIViewController?) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return top(nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return top(selected)
            
        } else if let presented = base?.presentedViewController {
            return top(presented)
        }
        return base
    }
}
