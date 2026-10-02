//
//  MicrophoneAuthorization.swift
//  Folium
//
//  Created by Jarrod Norwell on 2/10/2026.
//

import AVFAudio

// MARK: Finished (3/10/2026)

@available(iOS 17, *)
actor MicrophoneAuthorization : AuthorizationProtocol {
    func authorize() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }
    
    func checkAuthorizationStatus() async -> Bool {
        AVAudioApplication.shared.recordPermission == .granted
    }
}

@available(iOS 16, *)
actor DeprecatedMicrophoneAuthorization : AuthorizationProtocol {
    func authorize() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    func checkAuthorizationStatus() async -> Bool {
        AVAudioSession.sharedInstance().recordPermission == .granted
    }
}
