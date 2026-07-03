//
//  SelectedSnapshot.swift
//  Folium
//
//  Created by Jarrod Norwell on 21/6/2026.
//

enum SelectedSnapshot : Int {
    case application, cytrus, grape, kiwi, mandarine, tomato
    
    var string: String {
        switch self {
        case .application:
            "Application"
        case .cytrus:
            "Cytrus"
        case .grape:
            "Grape"
        case .kiwi:
            "Kiwi"
        case .mandarine:
            "Mandarine"
        case .tomato:
            "Tomato"
        }
    }
}
