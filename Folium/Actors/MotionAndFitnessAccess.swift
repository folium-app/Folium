//
//  MotionAndFitnessAccess.swift
//  Folium
//
//  Created by Jarrod Norwell on 13/9/2026.
//

import CoreMotion

actor MotionAndFitnessAccess {
    var authorised: Bool = false
    var status: CMAuthorizationStatus = .notDetermined
    
    var pedometer: CMPedometer = .init()
    
    func checkAuthorisationStatus() async {
        await withCheckedContinuation { continuation in
            status = CMPedometer.authorizationStatus()
            authorised = status == .authorized
            continuation.resume()
        }
    }
    
    func authorise() async -> Bool {
#if targetEnvironment(simulator)
        return true
#else
        await withCheckedContinuation { continuation in
            pedometer.queryPedometerData(from: .now, to: .now) { _, error in
                continuation.resume(returning: error == nil)
            }
        }
#endif
    }
}
