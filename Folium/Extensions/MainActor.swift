//
//  MainActor.swift
//  Folium
//
//  Created by Jarrod Norwell on 25/6/2026.
//

import Foundation

func onMainThread(performing: @escaping @MainActor @Sendable () -> Void) {
    DispatchQueue.main.async {
        performing()
    }
}
