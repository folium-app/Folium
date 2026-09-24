//
//  CameraAccess.swift
//  Folium
//
//  Created by Jarrod Norwell on 13/9/2026.
//

import AVFoundation

actor CameraAccess {
    var authorised: Bool = false
    var status: AVAuthorizationStatus = .notDetermined
    
    func checkAuthorisationStatus() async {
        await withCheckedContinuation { continuation in
            status = AVCaptureDevice.authorizationStatus(for: .video)
            authorised = status == .authorized
            continuation.resume()
        }
    }
    
    func authorise() async -> Bool {
        authorised = await AVCaptureDevice.requestAccess(for: .video)
        return authorised
    }
}
