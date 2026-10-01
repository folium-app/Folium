//
//  SelectedSnapshot.swift
//  Folium
//
//  Created by Jarrod Norwell on 21/6/2026.
//

import UniformTypeIdentifiers

enum SelectedSnapshot : Int {
    case application,
         cherry,
         cytrus,
         durian,
         grape,
         kiwi,
         lychee,
         mandarine,
         mango,
         plum,
         tomato
    
    static func from(string: String) -> SelectedSnapshot? {
        switch string {
        case "Cherry":
            SelectedSnapshot.cherry
        case "Cytrus":
            SelectedSnapshot.cytrus
        case "Durian":
            SelectedSnapshot.durian
        case "Grape":
            SelectedSnapshot.grape
        case "Kiwi":
            SelectedSnapshot.kiwi
        case "Lychee":
            SelectedSnapshot.lychee
        case "Mandarine":
            SelectedSnapshot.mandarine
        case "Mango":
            SelectedSnapshot.mango
        case "Plum":
            SelectedSnapshot.plum
        case "Tomato":
            SelectedSnapshot.tomato
        default:
            nil
        }
    }
    
    var string: String {
        switch self {
        case .application:
            "Application"
        case .cherry:
            "Cherry"
        case .cytrus:
            "Cytrus"
        case .durian:
            "Durian"
        case .grape:
            "Grape"
        case .kiwi:
            "Kiwi"
        case .lychee:
            "Lychee"
        case .mandarine:
            "Mandarine"
        case .mango:
            "Mango"
        case .plum:
            "Plum"
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
        case .durian:
            System.durian
        case .grape:
            System.grape
        case .kiwi:
            System.kiwi
        case .lychee:
            System.lychee
        case .mandarine:
            System.mandarine
        case .mango:
            System.mango
        case .plum:
            System.plum
        case .tomato:
            System.tomato
        }
    }
    
    var types: Array<UTType> {
        switch self {
        case .application:
            []
        case .cherry:
            Array<UTType>.cherry
        case .cytrus:
            Array<UTType>.cytrus
        case .durian:
            Array<UTType>.durian
        case .grape:
            Array<UTType>.grape
        case .kiwi:
            Array<UTType>.kiwi
        case .lychee:
            Array<UTType>.lychee
        case .mandarine:
            Array<UTType>.mandarine
        case .mango:
            Array<UTType>.mango
        case .plum:
            Array<UTType>.plum
        case .tomato:
            Array<UTType>.tomato
        }
    }
    
    var valid: Bool { neq(.application) }
    
    private func neq(_ value: SelectedSnapshot) -> Bool { self != value }
}
