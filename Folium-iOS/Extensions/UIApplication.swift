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
}
