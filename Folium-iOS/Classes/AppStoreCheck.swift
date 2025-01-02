//
//  AppStoreCheck.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 23/7/2024.
//

import Foundation

struct AppStoreCheck {
    enum Environment : Int {
        case appStore = 0, testFlight = 1, other = 2
    }
    
    static let shared = AppStoreCheck()
    
    var currentAppEnvironment: Environment {
#if targetEnvironment(simulator)
        return .other
#else
        var hasEmbeddedMobileProvision: Bool {
            Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil
        }
        
        if hasEmbeddedMobileProvision {
            return .other
        }
        
        var isAppStoreReceipt: Bool {
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
        
        if isAppStoreReceipt {
            return .testFlight
        }
        
        return .appStore
#endif
    }
    
    var debugging: Bool {
        var info = kinfo_proc()
        var size = MemoryLayout.stride(ofValue: info)
        var mib : [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        assert(junk == 0, "sysctl failed")
        return (info.kp_proc.p_flag & P_TRACED) != 0 || CommandLine.arguments.contains("altstore")
    }
    
    var additionalFeaturesAreAllowed: Bool {
        debugging || [.appStore, .testFlight].contains(currentAppEnvironment)
    }
}
