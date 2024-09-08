//
//  GrapeSkin.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 30/8/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation
import UIKit

var grapeSkin: Skin? {
    let bounds = UIScreen.main.bounds
    let width = bounds.width
    let height = bounds.height
    
    let window = if #available(iOS 16, *) {
        UIApplication.shared.window
    } else {
        UIApplication.shared.windows[0]
    }
    
    guard let window else {
        return nil
    }
    
    let safeAreaInsets = window.safeAreaInsets
    
    var machine = machine
#if targetEnvironment(simulator)
    machine = "iPhone16,2"
#endif
    
    guard let machine = Machine(rawValue: machine) else {
        return nil
    }
    
    switch machine {
    case .iPhoneSE2, .iPhoneSE3, .iPhone12Mini, .iPhone13Mini:
        let lrzlzrButtonHeight = Double(45 * (3 / 2))
        
        let portrait: Orientation = .init(buttons: [
            .init(x: width - (45 + 10 + safeAreaInsets.right), y: height - (90 + safeAreaInsets.bottom), width: 45, height: 45, type: .a),
            .init(x: width - (90 + 10 + safeAreaInsets.right), y: height - (45 + safeAreaInsets.bottom), width: 45, height: 45, type: .b),
            .init(x: width - (90 + 10 + safeAreaInsets.right), y: height - (135 + safeAreaInsets.bottom), width: 45, height: 45, type: .x),
            .init(x: width - (135 + 10 + safeAreaInsets.right), y: height - (90 + safeAreaInsets.bottom), width: 45, height: 45, type: .y),
            
            .init(x: 45 + 10 + safeAreaInsets.left, y: height - (135 + safeAreaInsets.bottom), width: 45, height: 45, type: .dpadUp),
            .init(x: 45 + 10 + safeAreaInsets.left, y: height - (45 + safeAreaInsets.bottom), width: 45, height: 45, type: .dpadDown),
            .init(x: 10 + safeAreaInsets.left, y: height - (90 + safeAreaInsets.bottom), width: 45, height: 45, type: .dpadLeft),
            .init(x: 90 + 10 + safeAreaInsets.left, y: height - (90 + safeAreaInsets.bottom), width: 45, height: 45, type: .dpadRight),
            
            .init(x: width / 2 - 55, y: height - (25 + safeAreaInsets.bottom), width: 25, height: 25, type: .minus),
            .init(x: width / 2 + 30, y: height - (25 + safeAreaInsets.bottom), width: 25, height: 25, type: .plus),
            
            .init(x: 10 + safeAreaInsets.left, y: height - (190 + safeAreaInsets.bottom), width: lrzlzrButtonHeight, height: 45, type: .l),
            .init(x: width - (10 + lrzlzrButtonHeight + safeAreaInsets.right), y: height - (190 + safeAreaInsets.bottom), width: lrzlzrButtonHeight, height: 45, type: .r),
        ], screens: [
            .init(x: 0, y: safeAreaInsets.top, width: width, height: width * (3 / 4)),
            .init(x: 0, y: safeAreaInsets.top + (width * (3 / 4)), width: width, height: width * (3 / 4))
        ], thumbsticks: [])
        
        return .init(author: .init(name: "Antique", socials: [
            .init(type: .twitter, username: "antique_codes")
        ]),
                     core: .cytrus,
                     orientations: .init(portrait: portrait,
                                         supportedDevices: Machine.iPhone_mini),
                     title: "Default Skin")
    case .iPhone8, .iPhone8Plus, .iPhoneX, .iPhoneXGSM,
            .iPhoneXR, .iPhoneXS, .iPhoneXSMax, .iPhoneXSMaxGlobal,
            .iPhone11, .iPhone11Pro, .iPhone11ProMax, .iPhone12,
            .iPhone12Pro, .iPhone12ProMax, .iPhone13, .iPhone13Pro,
            .iPhone13ProMax, .iPhone14, .iPhone14Plus, .iPhone14Pro,
            .iPhone14ProMax, .iPhone15, .iPhone15Plus, .iPhone15Pro,
            .iPhone15ProMax:
        let portrait: Orientation = .init(buttons: [
            .init(x: width - (50 + 10 + safeAreaInsets.right), y: height - (100 + safeAreaInsets.bottom), width: 50, height: 50, type: .a),
            .init(x: width - (100 + 10 + safeAreaInsets.right), y: height - (50 + safeAreaInsets.bottom), width: 50, height: 50, type: .b),
            .init(x: width - (100 + 10 + safeAreaInsets.right), y: height - (150 + safeAreaInsets.bottom), width: 50, height: 50, type: .x),
            .init(x: width - (150 + 10 + safeAreaInsets.right), y: height - (100 + safeAreaInsets.bottom), width: 50, height: 50, type: .y),
            
            .init(x: 50 + 10 + safeAreaInsets.left, y: height - (150 + safeAreaInsets.bottom), width: 50, height: 50, type: .dpadUp),
            .init(x: 50 + 10 + safeAreaInsets.left, y: height - (50 + safeAreaInsets.bottom), width: 50, height: 50, type: .dpadDown),
            .init(x: 10 + safeAreaInsets.left, y: height - (100 + safeAreaInsets.bottom), width: 50, height: 50, type: .dpadLeft),
            .init(x: 100 + 10 + safeAreaInsets.left, y: height - (100 + safeAreaInsets.bottom), width: 50, height: 50, type: .dpadRight),
            
            .init(x: width / 2 - 65, y: height - (30 + safeAreaInsets.bottom), width: 30, height: 30, type: .minus),
            .init(x: width / 2 + 35, y: height - (30 + safeAreaInsets.bottom), width: 30, height: 30, type: .plus),
            
            .init(x: 10 + safeAreaInsets.left, y: height - (210 + safeAreaInsets.bottom), width: Double(50 * (3 / 2)), height: 50, type: .l),
            .init(x: width - (10 + Double(50 * (3 / 2)) + safeAreaInsets.right), y: height - (210 + safeAreaInsets.bottom), width: Double(50 * (3 / 2)), height: 50, type: .r),
        ], screens: [
            .init(x: 0, y: safeAreaInsets.top, width: width, height: width * (3 / 4)),
            .init(x: 0, y: safeAreaInsets.top + (width * (3 / 4)), width: width, height: width * (3 / 4))
        ], thumbsticks: [])
        
        return .init(author: .init(name: "Antique", socials: [
            .init(type: .twitter, username: "antique_codes")
        ]),
                     core: .cytrus,
                     orientations: .init(portrait: portrait,
                                         supportedDevices: Machine.iPhone),
                     title: "Default Skin")
    case .iPadPro12_9_1stGen, .iPadPro12_9_2ndGen, .iPadPro12_9_3rdGen, .iPadPro12_9_4thGen,
            .iPadPro12_9_5thGen, .iPadPro12_9_6thGen, .iPadPro12_9_7thGen, .iPadPro11_1stGen,
            .iPadPro11_2ndGen, .iPadPro11_3rdGen, .iPadPro11_4thGen, .iPadPro11_5thGen,
            .iPadPro11_6thGen, .iPadPro11_7thGen, .iPad10thGen, .iPad9thGen,
            .iPad8thGen, .iPad7thGen, .iPad6thGen, .iPad5thGen,
            .iPadMini5thGen, .iPadMini6thGen, .iPadAir3rdGen, .iPadAir4thGen,
            .iPadAir5thGen, .iPadAir6thGen, .iPadAir7thGen:
        let portrait: Orientation = .init(buttons: [
            .init(x: width - (50 + 10 + safeAreaInsets.right), y: height - (100 + safeAreaInsets.bottom), width: 50, height: 50, type: .a),
            .init(x: width - (100 + 10 + safeAreaInsets.right), y: height - (50 + safeAreaInsets.bottom), width: 50, height: 50, type: .b),
            .init(x: width - (100 + 10 + safeAreaInsets.right), y: height - (150 + safeAreaInsets.bottom), width: 50, height: 50, type: .x),
            .init(x: width - (150 + 10 + safeAreaInsets.right), y: height - (100 + safeAreaInsets.bottom), width: 50, height: 50, type: .y),
            
            .init(x: 50 + 10 + safeAreaInsets.left, y: height - (150 + safeAreaInsets.bottom), width: 50, height: 50, type: .dpadUp),
            .init(x: 50 + 10 + safeAreaInsets.left, y: height - (50 + safeAreaInsets.bottom), width: 50, height: 50, type: .dpadDown),
            .init(x: 10 + safeAreaInsets.left, y: height - (100 + safeAreaInsets.bottom), width: 50, height: 50, type: .dpadLeft),
            .init(x: 100 + 10 + safeAreaInsets.left, y: height - (100 + safeAreaInsets.bottom), width: 50, height: 50, type: .dpadRight),
            
            .init(x: width / 2 - 65, y: height - (30 + safeAreaInsets.bottom), width: 30, height: 30, type: .minus),
            .init(x: width / 2 + 35, y: height - (30 + safeAreaInsets.bottom), width: 30, height: 30, type: .plus),
            
            .init(x: 10 + safeAreaInsets.left, y: height - (210 + safeAreaInsets.bottom), width: Double(50 * (3 / 2)), height: 50, type: .l),
            .init(x: width - (10 + Double(50 * (3 / 2)) + safeAreaInsets.right), y: height - (210 + safeAreaInsets.bottom), width: Double(50 * (3 / 2)), height: 50, type: .r),
        ], screens: [
            .init(x: 0, y: safeAreaInsets.top, width: width, height: width * (3 / 4)),
            .init(x: 0, y: safeAreaInsets.top + (width * (3 / 4)), width: width, height: width * (3 / 4))
        ], thumbsticks: [])
        
        return .init(author: .init(name: "Antique", socials: [
            .init(type: .twitter, username: "antique_codes")
        ]),
                     core: .grape,
                     orientations: .init(portrait: portrait,
                                         supportedDevices: Machine.iPad),
                     title: "Default Skin")
    }
}
