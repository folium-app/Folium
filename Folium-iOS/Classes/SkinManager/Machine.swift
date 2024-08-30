//
//  Machine.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 27/8/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation

enum Machine : String, Codable, CaseIterable, Hashable {
    // iPad Pro 12.9-inch series
    case iPadPro12_9_1stGen = "iPad6,7"  // iPad Pro 12.9-inch (1st generation)
    case iPadPro12_9_2ndGen = "iPad6,8"  // iPad Pro 12.9-inch (2nd generation)
    case iPadPro12_9_3rdGen = "iPad8,5"  // iPad Pro 12.9-inch (3rd generation)
    case iPadPro12_9_4thGen = "iPad8,11" // iPad Pro 12.9-inch (4th generation)
    case iPadPro12_9_5thGen = "iPad13,8" // iPad Pro 12.9-inch (5th generation)
    case iPadPro12_9_6thGen = "iPad14,5" // iPad Pro 12.9-inch (6th generation)
    case iPadPro12_9_7thGen = "iPad16,5" // iPad Pro 12.9-inch (7th generation)

    // iPad Pro 11-inch series
    case iPadPro11_1stGen = "iPad8,1"    // iPad Pro 11-inch (1st generation)
    case iPadPro11_2ndGen = "iPad8,3"    // iPad Pro 11-inch (2nd generation)
    case iPadPro11_3rdGen = "iPad8,9"    // iPad Pro 11-inch (3rd generation)
    case iPadPro11_4thGen = "iPad8,10"   // iPad Pro 11-inch (4th generation)
    case iPadPro11_5thGen = "iPad13,4"   // iPad Pro 11-inch (5th generation)
    case iPadPro11_6thGen = "iPad13,5"   // iPad Pro 11-inch (5th generation)
    case iPadPro11_7thGen = "iPad16,3"   // iPad Pro 11-inch (5th generation)

    // iPad (10th generation)
    case iPad10thGen = "iPad13,18"  // iPad (10th generation)

    // iPad (9th generation)
    case iPad9thGen = "iPad12,1"   // iPad (9th generation)

    // iPad (8th generation)
    case iPad8thGen = "iPad11,6"   // iPad (8th generation)

    // iPad (7th generation)
    case iPad7thGen = "iPad7,11"   // iPad (7th generation)

    // iPad (6th generation)
    case iPad6thGen = "iPad7,5"    // iPad (6th generation)

    // iPad (5th generation)
    case iPad5thGen = "iPad6,11"   // iPad (5th generation)

    // iPad mini series
    case iPadMini5thGen = "iPad11,1"  // iPad mini (5th generation)
    case iPadMini6thGen = "iPad14,1"  // iPad mini (6th generation)

    // iPad Air series
    case iPadAir3rdGen = "iPad11,3"   // iPad Air (3rd generation)
    case iPadAir4thGen = "iPad13,1"   // iPad Air (4th generation)
    case iPadAir5thGen = "iPad13,16"  // iPad Air (5th generation)
    case iPadAir6thGen = "iPad14,8"   // iPad Air (6th generation)
    case iPadAir7thGen = "iPad14,10"  // iPad Air (7th generation)
    
    
    // iPhone 14 series
    case iPhone14 = "iPhone14,7"  // iPhone 14
    case iPhone14Plus = "iPhone14,8"  // iPhone 14 Plus
    case iPhone14Pro = "iPhone15,2"  // iPhone 14 Pro
    case iPhone14ProMax = "iPhone15,3"  // iPhone 14 Pro Max

    // iPhone 13 series
    case iPhone13 = "iPhone14,5"  // iPhone 13
    case iPhone13Mini = "iPhone14,4"  // iPhone 13 Mini
    case iPhone13Pro = "iPhone14,2"  // iPhone 13 Pro
    case iPhone13ProMax = "iPhone14,3"  // iPhone 13 Pro Max

    // iPhone 12 series
    case iPhone12 = "iPhone13,2"  // iPhone 12
    case iPhone12Mini = "iPhone13,1"  // iPhone 12 Mini
    case iPhone12Pro = "iPhone13,3"  // iPhone 12 Pro
    case iPhone12ProMax = "iPhone13,4"  // iPhone 12 Pro Max

    // iPhone 11 series
    case iPhone11 = "iPhone12,1"  // iPhone 11
    case iPhone11Pro = "iPhone12,3"  // iPhone 11 Pro
    case iPhone11ProMax = "iPhone12,5"  // iPhone 11 Pro Max

    // iPhone XS series
    case iPhoneXS = "iPhone11,2"  // iPhone XS
    case iPhoneXSMax = "iPhone11,4"  // iPhone XS Max
    case iPhoneXSMaxGlobal = "iPhone11,6"  // iPhone XS Max Global

    // iPhone XR
    case iPhoneXR = "iPhone11,8"  // iPhone XR

    // iPhone X
    case iPhoneX = "iPhone10,3"  // iPhone X Global
    case iPhoneXGSM = "iPhone10,6"  // iPhone X GSM

    // iPhone 8 series
    case iPhone8 = "iPhone10,1"  // iPhone 8
    case iPhone8Plus = "iPhone10,2"  // iPhone 8 Plus

    // iPhone SE series
    case iPhoneSE2 = "iPhone12,8"  // iPhone SE (2nd generation)
    case iPhoneSE3 = "iPhone14,6"  // iPhone SE (3rd generation)

    // iPhone 15 series
    case iPhone15 = "iPhone15,4"  // iPhone 15
    case iPhone15Plus = "iPhone15,5"  // iPhone 15 Plus
    case iPhone15Pro = "iPhone16,1"  // iPhone 15 Pro
    case iPhone15ProMax = "iPhone16,2"  // iPhone 15 Pro Max
    
    static let iPad: [Machine] = [
        .iPadPro12_9_1stGen,
        .iPadPro12_9_2ndGen,
        .iPadPro12_9_3rdGen,
        .iPadPro12_9_4thGen,
        .iPadPro12_9_5thGen,
        .iPadPro12_9_6thGen,
        .iPadPro12_9_7thGen,
        .iPadPro11_1stGen,
        .iPadPro11_2ndGen,
        .iPadPro11_3rdGen,
        .iPadPro11_4thGen,
        .iPadPro11_5thGen,
        .iPadPro11_6thGen,
        .iPadPro11_7thGen,
        .iPad10thGen,
        .iPad9thGen,
        .iPad8thGen,
        .iPad7thGen,
        .iPad6thGen,
        .iPad5thGen,
        .iPadMini5thGen,
        .iPadMini6thGen,
        .iPadAir3rdGen,
        .iPadAir4thGen,
        .iPadAir5thGen,
        .iPadAir6thGen,
        .iPadAir7thGen
    ]
    
    static let iPhone_mini: [Machine] = [
        .iPhoneSE2,
        .iPhoneSE3,
        .iPhone12Mini,
        .iPhone13Mini
    ]
    
    static let iPhone: [Machine] = [
        .iPhone8,
        .iPhone8Plus,
        .iPhoneX,
        .iPhoneXGSM,
        .iPhoneXR,
        .iPhoneXS,
        .iPhoneXSMax,
        .iPhoneXSMaxGlobal,
        .iPhone11,
        .iPhone11Pro,
        .iPhone11ProMax,
        .iPhone12,
        .iPhone12Pro,
        .iPhone12ProMax,
        .iPhone13,
        .iPhone13Pro,
        .iPhone13ProMax,
        .iPhone14,
        .iPhone14Plus,
        .iPhone14Pro,
        .iPhone14ProMax,
        .iPhone15,
        .iPhone15Plus,
        .iPhone15Pro,
        .iPhone15ProMax
    ]
}
