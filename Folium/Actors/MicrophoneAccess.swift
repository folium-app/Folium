//
//  MicrophoneAccessProtocol.swift
//  Folium
//
//  Created by Jarrod Norwell on 13/9/2026.
//

import AVFAudio

protocol MicrophoneAccessProtocol : Sendable {
    init()
    
    func checkAuthorisationStatus() async
    func authorise() async -> Bool
}

// MARK: iOS 17+
@available(iOS 17, *)
actor LatestMicrophoneAccess : MicrophoneAccessProtocol {
    var authorised: Bool = false
    var status: AVAudioApplication.recordPermission = .undetermined
    
    init() {}
    
    func checkAuthorisationStatus() async {
        await withCheckedContinuation { continuation in
            status = AVAudioApplication.shared.recordPermission
            authorised = status == .granted
            continuation.resume()
        }
    }
    
    func authorise() async -> Bool {
        authorised = await AVAudioApplication.requestRecordPermission()
        return authorised
    }
}

// MARK: iOS 16
@available(iOS 16, *)
actor MicrophoneAccess : MicrophoneAccessProtocol  {
    var authorised: Bool = false
    var status: AVAudioSession.RecordPermission = .undetermined
    
    init() {}
    
    func checkAuthorisationStatus() async {
        await withCheckedContinuation { continuation in
            status = AVAudioSession.sharedInstance().recordPermission
            authorised = status == .granted
            continuation.resume()
        }
    }
    
    func authorise() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { result in
                continuation.resume(returning: result)
            }
        }
    }
}
