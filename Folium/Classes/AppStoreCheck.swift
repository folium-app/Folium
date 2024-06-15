//
//  AppStoreCheck.swift
//  Folium
//
//  Created by Jarrod Norwell on 15/6/2024.
//

import Foundation
import TargetConditionals

struct AppStoreCheck {
    enum Environment : Int {
        case appStore = 0, testFlight = 1, other = 2
    }
    
    static let shared = AppStoreCheck()
    
    func currentAppEnvironment() -> Environment {
#if targetEnvironment(simulator)
        return .other
#else
        func hasEmbeddedMobileProvision() -> Bool {
            Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil
        }
        
        if hasEmbeddedMobileProvision() {
            return .other
        }
        
        func isAppStoreReceipt() -> Bool {
            #if targetEnvironment(simulator)
            false
            #else
            if let url = Bundle.main.appStoreReceiptURL {
                url.lastPathComponent == "sandboxReceipt"
            } else {
                false
            }
            #endif
        }
        
        if isAppStoreReceipt() {
            return .testFlight
        }
        
        return .appStore
#endif
    }
}
