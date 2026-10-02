//
//  CameraAuthorization.swift
//  Folium
//
//  Created by Jarrod Norwell on 1/10/2026.
//

import AVFoundation

// MARK: Finished (3/10/2026)

actor CameraAuthorization : AuthorizationProtocol {
    func authorize() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }
    
    func checkAuthorizationStatus() async -> Bool {
        await withCheckedContinuation { continuation in
            continuation.resume(returning: AVCaptureDevice.authorizationStatus(for: .video) == .authorized)
        }
    }
}
