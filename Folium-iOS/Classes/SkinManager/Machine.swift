//
//  Machine.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 27/8/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation

enum Machine : String, Codable, CaseIterable, CustomStringConvertible, Hashable {
    // MARK: iPhone Begin
    case iPhone12mini = "iPhone13,1"
    case iPhone12 = "iPhone13,2"
    case iPhone12Pro = "iPhone13,3"
    case iPhone12ProMax = "iPhone13,4"
    
    case iPhone13Pro = "iPhone14,2"
    case iPhone13ProMax = "iPhone14,3"
    case iPhone13mini = "iPhone14,4"
    case iPhone13 = "iPhone14,5"
    
    case iPhone14 = "iPhone14,7"
    case iPhone14Plus = "iPhone14,8"
    case iPhone14Pro = "iPhone15,2"
    case iPhone14ProMax = "iPhone15,3"
    
    case iPhone15 = "iPhone15,4"
    case iPhone15Plus = "iPhone15,5"
    case iPhone15Pro = "iPhone16,1"
    case iPhone15ProMax = "iPhone16,2"
    // MARK: iPhone End
    
    // MARK: iPad Begin
    case iPad_10th = "iPad13,19"
    case iPadPro_11_inch_4th = "iPad14,4"
    case iPadPro_12_9_inch_6th = "iPad14,6"
    case iPadAir_6th = "iPad14,9"
    case iPadAir_7th = "iPad14,11"
    case iPadPro_11_inch_5th = "iPad16,4"
    case iPadPro_12_9_inch_7th = "iPad16,6"
    // MARK: iPad End
    
    enum CodingKeys : String, CodingKey {
        case iPad_10th = "iPad13,18"
        case iPadPro_11_inch_4th = "iPad14,3"
        case iPadPro_12_9_inch_6th = "iPad14,5"
        case iPadAir_6th = "iPad14,8"
        case iPadAir_7th = "iPad14,10"
        case iPadPro_11_inch_5th = "iPad16,3"
        case iPadPro_12_9_inch_7th = "iPad16,5"
    }
    
    
    var description: String {
        switch self {
        case .iPhone12mini:
            "iPhone 12 mini"
        case .iPhone12:
            "iPhone 12"
        case .iPhone12Pro:
            "iPhone 12 Pro"
        case .iPhone12ProMax:
            "iPhone 12 Pro Max"
        case .iPhone13Pro:
            "iPhone 13 Pro"
        case .iPhone13ProMax:
            "iPhone 13 Pro Max"
        case .iPhone13mini:
            "iPhone 13 mini"
        case .iPhone13:
            "iPhone 13"
        case .iPhone14:
            "iPhone 14"
        case .iPhone14Plus:
            "iPhone 14 Plus"
        case .iPhone14Pro:
            "iPhone 14 Pro"
        case .iPhone14ProMax:
            "iPhone 14 Pro Max"
        case .iPhone15:
            "iPhone 15"
        case .iPhone15Plus:
            "iPhone 15 Plus"
        case .iPhone15Pro:
            "iPhone 15 Pro"
        case .iPhone15ProMax:
            "iPhone 15 Pro Max"
            
        case .iPad_10th:
            "iPad 10th Gen"
        case .iPadPro_11_inch_4th:
            "iPad Pro 11 inch 4th Gen"
        case .iPadPro_12_9_inch_6th:
            "iPad Pro 12.9 inch 6th Gen"
        case .iPadAir_6th:
            "iPad Air 6th Gen"
        case .iPadAir_7th:
            "iPad Air 7th Gen"
        case .iPadPro_11_inch_5th:
            "iPad Pro 11 inch 5th Gen"
        case .iPadPro_12_9_inch_7th:
            "iPad Pro 12.9 inch 7th Gen"
        }
    }
}
