//
//  UIViewController.swift
//  Folium
//
//  Created by Jarrod Norwell on 16/6/2024.
//

import Foundation
import UIKit

extension UIViewController {
    func orientationForCurrentOrientation() -> Orientation {
        switch UIApplication.shared.statusBarOrientation {
        case .unknown, .portrait, .portraitUpsideDown:
            .portrait
        case .landscapeLeft, .landscapeRight:
            .landscape
        @unknown default:
            fatalError("[\(String(describing: type(of: self))).orientationForCurrentOrientation]: Unknown interface orientation")
        }
    }
}
