//
//  File.swift
//  FUIAlertKit
//
//  Created by Jarrod Norwell on 18/10/2024.
//

import Foundation
import UIKit

public class PassthroughWindow : UIWindow {
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        super.hitTest(point, with: event) == self ? nil : super.hitTest(point, with: event)
    }
}

public class FUIAlertKitWindow : PassthroughWindow {
    var passthroughWindow: PassthroughWindow
    
    public override init(windowScene: UIWindowScene) {
        passthroughWindow = .init(windowScene: windowScene)
        super.init(windowScene: windowScene)
        
        passthroughWindow.rootViewController = FUIAlertKitController()
        passthroughWindow.windowLevel = .alert
        passthroughWindow.makeKeyAndVisible()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
