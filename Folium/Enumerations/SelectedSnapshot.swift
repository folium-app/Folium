//
//  SelectedSnapshot.swift
//  Folium
//
//  Created by Jarrod Norwell on 21/6/2026.
//

enum SelectedSnapshot : Int {
    case application, cherry, cytrus, grape, kiwi, mandarine, tomato
    
    var string: String {
        switch self {
        case .application:
            "Application"
        case .cherry:
            "Cherry"
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
    
    var system: System? {
        switch self {
        case .application:
            nil
        case .cherry:
            System.cherry
        case .cytrus:
            System.cytrus
        case .grape:
            System.grape
        case .kiwi:
            System.kiwi
        case .mandarine:
            System.mandarine
        case .tomato:
            System.tomato
        }
    }
    
    var valid: Bool {
        neq(.application)
    }
    
    private func neq(_ value: SelectedSnapshot) -> Bool {
        self != value
    }
}
