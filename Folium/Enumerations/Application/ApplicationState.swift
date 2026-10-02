//
//  ApplicationStatus.swift
//  Folium
//
//  Created by Jarrod Norwell on 13/9/2026.
//

import Foundation

enum ApplicationState {
    case backgrounded,
         foregrounded,
         disconnected
    
    var shouldPause: Bool { neq(.foregrounded) }
    
    private func neq(_ value: ApplicationState) -> Bool { self != value }
}
