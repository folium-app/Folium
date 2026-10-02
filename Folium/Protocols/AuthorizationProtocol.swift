//
//  AuthorizationProtocol.swift
//  Folium
//
//  Created by Jarrod Norwell on 1/10/2026.
//

protocol AuthorizationProtocol {
    func authorize() async -> Bool
    func checkAuthorizationStatus() async -> Bool
}
