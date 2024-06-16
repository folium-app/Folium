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
        guard let window = view.window, let windowScene = window.windowScene else {
            return Orientation.portrait
        }
        
        switch windowScene.interfaceOrientation {
        case .unknown, .portrait, .portraitUpsideDown:
            return Orientation.portrait
        case .landscapeLeft, .landscapeRight:
            return Orientation.landscape
        @unknown default:
            fatalError("[\(String(describing: type(of: self))).orientationForCurrentOrientation]: Unknown interface orientation")
        }
    }
}
