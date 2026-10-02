//
//  AuthorizationActors.swift
//  Folium
//
//  Created by Jarrod Norwell on 1/10/2026.
//

import Foundation

// MARK: Finished (3/10/2026)

struct AuthorizationActors {
    let cameraAuthorization = CameraAuthorization()
    
    @available(iOS 17, *)
    var microphoneAuthorization: MicrophoneAuthorization {
        MicrophoneAuthorization()
    }
    
    @available(iOS 16, *)
    var deprecatedMicrophoneAuthorization: DeprecatedMicrophoneAuthorization {
        DeprecatedMicrophoneAuthorization()
    }
    
    let motionAuthorization = MotionAuthorization()
}
