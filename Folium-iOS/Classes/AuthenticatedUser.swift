//
//  AuthenticatedUser.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 2/7/2024.
//

import Foundation

struct AuthenticatedUser : Codable {
    var email: String? = nil
    var fullName: PersonNameComponents? = nil
}
