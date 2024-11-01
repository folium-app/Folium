//
//  Machine.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 27/8/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation

enum Machine : String, Codable, CaseIterable, Hashable {
    case iPad10Gen_1 = "iPad13,19"
    case iPad10Gen_2 = "iPad13,18"

    case iPad9Gen_1 = "iPad12,1"
    case iPad9Gen_2 = "iPad12,2"

    case iPad8Gen_1 = "iPad11,6"
    case iPad8Gen_2 = "iPad11,7"

    case iPad7Gen_1 = "iPad7,11"
    case iPad7Gen_2 = "iPad7,12"

    case iPad6Gen_1 = "iPad7,5"
    case iPad6Gen_2 = "iPad7,6"

    case iPad5Gen_1 = "iPad6,11"
    case iPad5Gen_2 = "iPad6,12"

    case iPadAir6Gen_1 = "iPad14,10" // 13-in (M2)
    case iPadAir6Gen_2 = "iPad14,11" // 13-in (M2)

    case iPadAir6Gen_3 = "iPad14,8" // 11-in (M2)
    case iPadAir6Gen_4 = "iPad14,9" // 11-in (M2)

    case iPadAir5Gen_1 = "iPad13,16"
    case iPadAir5Gen_2 = "iPad13,17"
    
    case iPadAir4Gen_1 = "iPad13,1"
    case iPadAir4Gen_2 = "iPad13,2"
    
    case iPadMini7Gen_1 = "iPad16,1" // A17 Pro
    case iPadMini7Gen_2 = "iPad16,2" // A17 Pro

    case iPadMini6Gen_1 = "iPad14,1"
    case iPadMini6Gen_2 = "iPad14,2"

    case iPadMini5Gen_1 = "iPad11,1"
    case iPadMini5Gen_2 = "iPad11,2"

    case iPadPro_1 = "iPad6,7"
    case iPadPro_2 = "iPad6,8"

    case iPadPro_3 = "iPad6,3"
    case iPadPro_4 = "iPad6,4"

    case iPadPro2Gen_1 = "iPad7,1"
    case iPadPro2Gen_2 = "iPad7,2"

    case iPadPro2Gen_3 = "iPad7,3"
    case iPadPro2Gen_4 = "iPad7,4"

    case iPadPro3Gen_1 = "iPad8,1"
    case iPadPro3Gen_2 = "iPad8,2"

    case iPadPro3Gen_3 = "iPad8,3"
    case iPadPro3Gen_4 = "iPad8,4"

    case iPadPro3Gen_5 = "iPad8,5"
    case iPadPro3Gen_6 = "iPad8,6"

    case iPadPro3Gen_7 = "iPad8,7"
    case iPadPro3Gen_8 = "iPad8,8"

    case iPadPro4Gen_1 = "iPad8,9"
    case iPadPro4Gen_2 = "iPad8,10"

    case iPadPro5Gen_1 = "iPad8,11"
    case iPadPro5Gen_2 = "iPad8,12"

    case iPadPro5Gen_3 = "iPad13,4"
    case iPadPro5Gen_4 = "iPad13,5"

    case iPadPro5Gen_5 = "iPad13,6"
    case iPadPro5Gen_6 = "iPad13,7"

    case iPadPro5Gen_7 = "iPad13,8"
    case iPadPro5Gen_8 = "iPad13,9"

    case iPadPro5Gen_9 = "iPad13,10"
    case iPadPro5Gen_10 = "iPad13,11"

    // case iPadPro6Gen_1 = "iPad" // TODO: iPad Pro (11-inch) (4th generation)
    // case iPadPro6Gen_2 = "iPad" // TODO: iPad Pro (11-inch) (4th generation)

    case iPadPro6Gen_1 = "iPad14,3" // TODO: iPad Pro (11-inch) (4th generation)
    case iPadPro6Gen_2 = "iPad14,4" // TODO: iPad Pro (11-inch) (4th generation)
    
    case iPadPro6Gen_3 = "iPad14,5" // TODO: iPad Pro (12.9-inch) (6th generation)
    case iPadPro6Gen_4 = "iPad14,6" // TODO: iPad Pro (12.9-inch) (6th generation)

    // case iPadPro6Gen_1 = "iPad" // TODO: iPad Pro (12.9-inch) (6th generation)
    // case iPadPro6Gen_2 = "iPad" // TODO: iPad Pro (12.9-inch) (6th generation)

    case iPadPro7Gen_1 = "iPad16,3" // 11-in (M4)
    case iPadPro7Gen_2 = "iPad16,4" // 11-in (M4)

    case iPadPro7Gen_3 = "iPad16,5" // 13-in (M4)
    case iPadPro7Gen_4 = "iPad16,6" // 13-in (M4)
    
    
    case iPhone8_1 = "iPhone10,1"
    case iPhone8_2 = "iPhone10,4"

    case iPhone8_3 = "iPhone10,2"
    case iPhone8_4 = "iPhone10,5"

    case iPhoneX_1 = "iPhone10,3"
    case iPhoneX_2 = "iPhone10,6"

    case iPhoneXR_1 = "iPhone11,8"

    case iPhoneXS_1 = "iPhone11,2"
    case iPhoneXS_2 = "iPhone11,4" // Max
    case iPhoneXS_3 = "iPhone11,6" // Max

    case iPhone11_1 = "iPhone12,1"
    case iPhone11_2 = "iPhone12,3" // Pro
    case iPhone11_3 = "iPhone12,5" // Pro Max

    case iPhoneSE2Gen_1 = "iPhone12,8"
    case iPhoneSE3Gen_1 = "iPhone14,6"

    case iPhone12_1 = "iPhone13,1" // mini
    case iPhone12_2 = "iPhone13,2"
    case iPhone12_3 = "iPhone13,3" // Pro
    case iPhone12_4 = "iPhone13,4" // Pro Max

    case iPhone13_1 = "iPhone14,4" // mini
    case iPhone13_2 = "iPhone14,5"
    case iPhone13_3 = "iPhone14,2" // Pro
    case iPhone13_4 = "iPhone14,3" // Pro Max

    case iPhone14_1 = "iPhone14,7"
    case iPhone14_2 = "iPhone14,8" // Plus
    case iPhone14_3 = "iPhone15,2" // Pro
    case iPhone14_4 = "iPhone15,3" // Pro Max

    case iPhone15_1 = "iPhone15,4"
    case iPhone15_2 = "iPhone15,5" // Plus
    case iPhone15_3 = "iPhone16,1" // Pro
    case iPhone15_4 = "iPhone16,2" // Pro Max
    
    case iPhone16_1 = "iPhone17,3"
    case iPhone16_2 = "iPhone17,4" // Plus
    case iPhone16_3 = "iPhone17,1" // Pro
    case iPhone16_4 = "iPhone17,2" // Pro Max

    static let iPad: [Machine] = [
        iPad10Gen_1,
        iPad10Gen_2,
        iPad9Gen_1,
        iPad9Gen_2,
        iPad8Gen_1,
        iPad8Gen_2,
        iPad7Gen_1,
        iPad7Gen_2,
        iPad6Gen_1,
        iPad6Gen_2,
        iPad5Gen_1,
        iPad5Gen_2,
        iPadAir6Gen_1,
        iPadAir6Gen_2,
        iPadAir6Gen_3,
        iPadAir6Gen_4,
        iPadAir5Gen_1,
        iPadAir5Gen_2,
        iPadAir4Gen_1,
        iPadAir4Gen_2,
        iPadMini7Gen_1,
        iPadMini7Gen_2,
        iPadMini6Gen_1,
        iPadMini6Gen_2,
        iPadMini5Gen_1,
        iPadMini5Gen_2,
        iPadPro_1,
        iPadPro_2,
        iPadPro_3,
        iPadPro_4,
        iPadPro2Gen_1,
        iPadPro2Gen_2,
        iPadPro2Gen_3,
        iPadPro2Gen_4,
        iPadPro3Gen_1,
        iPadPro3Gen_2,
        iPadPro3Gen_3,
        iPadPro3Gen_4,
        iPadPro3Gen_5,
        iPadPro3Gen_6,
        iPadPro3Gen_7,
        iPadPro3Gen_8,
        iPadPro4Gen_1,
        iPadPro4Gen_2,
        iPadPro5Gen_1,
        iPadPro5Gen_2,
        iPadPro5Gen_3,
        iPadPro5Gen_4,
        iPadPro5Gen_5,
        iPadPro5Gen_6,
        iPadPro5Gen_7,
        iPadPro5Gen_8,
        iPadPro5Gen_9,
        iPadPro5Gen_10,
        iPadPro6Gen_1,
        iPadPro6Gen_2,
        iPadPro6Gen_3,
        iPadPro6Gen_4,
        iPadPro7Gen_1,
        iPadPro7Gen_2,
        iPadPro7Gen_3,
        iPadPro7Gen_4
    ]

    static let iPhone: [Machine] = [
        iPhone8_1,
        iPhone8_2,
        iPhone8_3,
        iPhone8_4,
        iPhoneX_1,
        iPhoneX_2,
        iPhoneXR_1,
        iPhoneXS_1,
        iPhoneXS_2,
        iPhoneXS_3,
        iPhone11_1,
        iPhone11_2,
        iPhone11_3,
        iPhone12_2,
        iPhone12_3,
        iPhone12_4,
        iPhone13_2,
        iPhone13_3,
        iPhone13_4,
        iPhone14_1,
        iPhone14_2,
        iPhone14_3,
        iPhone14_4,
        iPhone15_1,
        iPhone15_2,
        iPhone15_3,
        iPhone15_4,
        iPhone16_1,
        iPhone16_2,
        iPhone16_3,
        iPhone16_4
    ]

    static let iPhone_mini: [Machine] = [
        iPhoneSE2Gen_1,
        iPhoneSE3Gen_1,
        iPhone12_1,
        iPhone13_1
    ]
}
