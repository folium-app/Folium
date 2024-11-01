//
//  File.swift
//  FUIAlertKit
//
//  Created by Jarrod Norwell on 18/10/2024.
//

import Foundation
import UIKit

public class PassthroughView : UIView {
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        super.hitTest(point, with: event) == self ? nil : super.hitTest(point, with: event)
    }
}

public class FUIAlertKitController : UIViewController {
    public override func loadView() {
        view = PassthroughView()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
}
