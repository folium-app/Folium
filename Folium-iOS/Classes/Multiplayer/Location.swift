//
//  Location.swift
//  Folium
//
//  Created by Jarrod Norwell on 23/4/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Cytrus
import CoreLocation
import Foundation

class MultiplayerLocation : AnyHashableSendable, @unchecked Sendable {
    var state: StateChange
    var latitude, longitude: CLLocationDegrees

    init(state: StateChange, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.state = state
        self.latitude = latitude
        self.longitude = longitude
    }
    
    var coordinate: CLLocationCoordinate2D { .init(latitude: latitude, longitude: longitude) }
}
