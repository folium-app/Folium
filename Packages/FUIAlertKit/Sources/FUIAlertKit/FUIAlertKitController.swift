//
//  File.swift
//  FUIAlertKit
//
//  Created by Jarrod Norwell on 18/10/2024.
//

import BlurView
import Foundation
import UIKit

public class PassthroughView : BlurView {
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        super.hitTest(point, with: event) == self ? nil : super.hitTest(point, with: event)
    }
}

public class FUIAlertKitController : UIViewController {
    var blurView: BlurView? = nil
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        blurView = .init()
        guard let blurView else {
            return
        }
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)
        
        blurView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    public func set(blurRadius: Double = 0) {
        guard let blurView else {
            return
        }
        
        print("blurRadius = ", blurRadius)
        blurView.blurRadius = blurRadius
    }
}
