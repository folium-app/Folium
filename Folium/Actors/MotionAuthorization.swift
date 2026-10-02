//
//  MotionAuthorization.swift
//  Folium
//
//  Created by Jarrod Norwell on 1/10/2026.
//

import CoreMotion

// MARK: Finished (3/10/2026)

actor MotionAuthorization : AuthorizationProtocol {
    private let pedometer = CMPedometer()
    
    func authorize() async -> Bool {
        await withCheckedContinuation { continuation in
            pedometer.queryPedometerData(from: .now, to: .now) { data, error in
                continuation.resume(returning: error.isNil)
            }
        }
    }
    
    func checkAuthorizationStatus() async -> Bool {
#if targetEnvironment(simulator)
        true
#else
        await withCheckedContinuation { continuation in
            continuation.resume(returning: CMPedometer.authorizationStatus() == .authorized)
        }
#endif
    }
}
