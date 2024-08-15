//
//  SkinManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 13/6/2024.
//

import Foundation
import UIKit

enum Machine : String, Codable, CaseIterable, CustomStringConvertible, Hashable {
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
    
    var description: String {
        switch self {
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
        }
    }
}

class SkinManager {
    static let shared = SkinManager()
    
    var skins: [Skin] = []
    func getSkins() throws {
        enum SkinError : Error {
            case enumeratorFailed
        }
        
        let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        guard let enumerator = FileManager.default.enumerator(at: documentDirectory, includingPropertiesForKeys: [.isRegularFileKey]) else {
            throw SkinError.enumeratorFailed
        }
        
        try enumerator.forEach { element in
            switch element {
            case let url as URL:
                let attributes = try url.resourceValues(forKeys: [.isRegularFileKey])
                if let isRegularFile = attributes.isRegularFile, isRegularFile {
                    if url.lastPathComponent.lowercased() == "info.json" {
                        let data = try Data(contentsOf: url)
                        var skin = try JSONDecoder().decode(Skin.self, from: data)
                        skin.url = url.deletingLastPathComponent()
                        
                        skins.append(skin)
                    }
                }
            default:
                break
            }
        }
    }
    
    func skins(for core: Core) -> [Skin] {
        skins.filter { $0.core == core }
    }
    
    var cytrusSkin: Skin? {
        let bounds = UIScreen.main.bounds
        let width = bounds.width
        let height = bounds.height
        let safeAreaInsets = UIApplication.shared.windows[0].safeAreaInsets
        
        var machine = machine
#if targetEnvironment(simulator)
        machine = "iPhone16,2"
#endif
        
        guard let machine = Machine(rawValue: machine) else {
            return nil
        }
        
        switch machine {
        case .iPhone13mini:
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
                
                .init(x: width / 2 - 12.5, y: height - (25 + safeAreaInsets.bottom), width: 25, height: 25, type: .home),
                .init(x: width / 2 - 55, y: height - (25 + safeAreaInsets.bottom), width: 25, height: 25, type: .minus),
                .init(x: width / 2 + 30, y: height - (25 + safeAreaInsets.bottom), width: 25, height: 25, type: .plus),
                
                .init(x: 10 + safeAreaInsets.left, y: height - (190 + safeAreaInsets.bottom), width: lrzlzrButtonHeight, height: 45, type: .l),
                .init(x: 10 + lrzlzrButtonHeight + 20 + safeAreaInsets.left, y: height - (190 + safeAreaInsets.bottom), width: lrzlzrButtonHeight, height: 45, type: .zl),
                .init(x: width - (10 + lrzlzrButtonHeight + safeAreaInsets.right), y: height - (190 + safeAreaInsets.bottom), width: lrzlzrButtonHeight, height: 45, type: .r),
                .init(x: width - (10 + (lrzlzrButtonHeight * 2) + 20 + safeAreaInsets.right), y: height - (190 + safeAreaInsets.bottom), width: lrzlzrButtonHeight, height: 45, type: .zr),
            ], screens: [
                .init(x: safeAreaInsets.left, y: safeAreaInsets.top, width: width - (safeAreaInsets.left + safeAreaInsets.right), height: height - (safeAreaInsets.top + safeAreaInsets.bottom))
            ], thumbsticks: [
                .init(x: 10 + safeAreaInsets.left, y: height - (135 + safeAreaInsets.bottom), width: 135, height: 135, type: .left),
                .init(x: width - (135 + 10 + safeAreaInsets.right), y: height - (135 + safeAreaInsets.bottom), width: 135, height: 135, type: .right)
            ])
            
            let landscapeLeft = portrait
            let landscapeRight = landscapeLeft
            
            return .init(author: .init(name: "Antique", socials: [
                .init(type: .twitter, username: "antique_codes")
            ]), core: .cytrus, orientations: .init(portrait: portrait, landscapeLeft: landscapeLeft, landscapeRight: landscapeRight, supportedDevices: [
                .iPhone13mini
            ]))
        case .iPhone13Pro, .iPhone13ProMax, .iPhone13,
                .iPhone14, .iPhone14Plus, .iPhone14Pro, .iPhone14ProMax,
                .iPhone15, .iPhone15Plus, .iPhone15Pro, .iPhone15ProMax:
            let portrait: Orientation = .init(buttons: [
                .init(x: width - (50 + 10 + safeAreaInsets.right), y: height - (100 + safeAreaInsets.bottom), width: 50, height: 50, type: .a),
                .init(x: width - (100 + 10 + safeAreaInsets.right), y: height - (50 + safeAreaInsets.bottom), width: 50, height: 50, type: .b),
                .init(x: width - (100 + 10 + safeAreaInsets.right), y: height - (150 + safeAreaInsets.bottom), width: 50, height: 50, type: .x),
                .init(x: width - (150 + 10 + safeAreaInsets.right), y: height - (100 + safeAreaInsets.bottom), width: 50, height: 50, type: .y),
                
                .init(x: 50 + 10 + safeAreaInsets.left, y: height - (150 + safeAreaInsets.bottom), width: 50, height: 50, type: .dpadUp),
                .init(x: 50 + 10 + safeAreaInsets.left, y: height - (50 + safeAreaInsets.bottom), width: 50, height: 50, type: .dpadDown),
                .init(x: 10 + safeAreaInsets.left, y: height - (100 + safeAreaInsets.bottom), width: 50, height: 50, type: .dpadLeft),
                .init(x: 100 + 10 + safeAreaInsets.left, y: height - (100 + safeAreaInsets.bottom), width: 50, height: 50, type: .dpadRight),
                
                .init(x: width / 2 - 15, y: height - (30 + safeAreaInsets.bottom), width: 30, height: 30, type: .home),
                .init(x: width / 2 - 65, y: height - (30 + safeAreaInsets.bottom), width: 30, height: 30, type: .minus),
                .init(x: width / 2 + 35, y: height - (30 + safeAreaInsets.bottom), width: 30, height: 30, type: .plus),
                
                .init(x: 10 + safeAreaInsets.left, y: height - (210 + safeAreaInsets.bottom), width: Double(50 * (3 / 2)), height: 50, type: .l),
                .init(x: 10 + Double(50 * (3 / 2)) + 20 + safeAreaInsets.left, y: height - (210 + safeAreaInsets.bottom), width: Double(50 * (3 / 2)), height: 50, type: .zl),
                .init(x: width - (10 + Double(50 * (3 / 2)) + safeAreaInsets.right), y: height - (210 + safeAreaInsets.bottom), width: Double(50 * (3 / 2)), height: 50, type: .r),
                .init(x: width - (10 + (Double(50 * (3 / 2)) * 2) + 20 + safeAreaInsets.right), y: height - (210 + safeAreaInsets.bottom), width: Double(50 * (3 / 2)), height: 50, type: .zr),
            ], screens: [
                .init(x: safeAreaInsets.left, y: safeAreaInsets.top, width: width - (safeAreaInsets.left + safeAreaInsets.right), height: height - (safeAreaInsets.top + safeAreaInsets.bottom))
            ], thumbsticks: [
                .init(x: 10 + safeAreaInsets.left, y: height - (150 + safeAreaInsets.bottom), width: 150, height: 150, type: .left),
                .init(x: width - (150 + 10 + safeAreaInsets.right), y: height - (150 + safeAreaInsets.bottom), width: 150, height: 150, type: .right)
            ])
            
            let landscapeLeft = portrait
            let landscapeRight = landscapeLeft
            
            return .init(author: .init(name: "Antique", socials: [
                .init(type: .twitter, username: "antique_codes")
            ]), core: .cytrus, orientations: .init(portrait: portrait, landscapeLeft: landscapeLeft, landscapeRight: landscapeRight, supportedDevices: [
                .iPhone13Pro, .iPhone13ProMax, .iPhone13,
                .iPhone14, .iPhone14Plus, .iPhone14Pro, .iPhone14ProMax,
                .iPhone15, .iPhone15Plus, .iPhone15Pro, .iPhone15ProMax
            ]))
        }
    }
    
    var grapeSkin: Skin? {
        let bounds = UIScreen.main.bounds
        let width = bounds.width
        let height = bounds.height
        let safeAreaInsets = UIApplication.shared.windows[0].safeAreaInsets
        
        var machine = machine
#if targetEnvironment(simulator)
        machine = "iPhone16,2"
#endif
        
        guard let machine = Machine(rawValue: machine) else {
            return nil
        }
        
        switch machine {
        case .iPhone13mini:
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
            
            let landscapeLeft = portrait
            let landscapeRight = landscapeLeft
            
            return .init(author: .init(name: "Antique", socials: [
                .init(type: .twitter, username: "antique_codes")
            ]), core: .cytrus, orientations: .init(portrait: portrait, landscapeLeft: landscapeLeft, landscapeRight: landscapeRight, supportedDevices: [
                .iPhone13mini
            ]))
        case .iPhone13Pro, .iPhone13ProMax, .iPhone13,
                .iPhone14, .iPhone14Plus, .iPhone14Pro, .iPhone14ProMax,
                .iPhone15, .iPhone15Plus, .iPhone15Pro, .iPhone15ProMax:
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
            ]), core: .cytrus, orientations: .init(portrait: portrait, supportedDevices: [
                .iPhone13Pro, .iPhone13ProMax, .iPhone13,
                .iPhone14, .iPhone14Plus, .iPhone14Pro, .iPhone14ProMax,
                .iPhone15, .iPhone15Plus, .iPhone15Pro, .iPhone15ProMax
            ]))
        }
    }
    
    /*
    var skins: [Skin] = []
    
    func skins(for core: Core, root: URL) throws {
        enum SkinError : Error {
            case enumeratorFailed
        }
        
        let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let coreDirectory = documentsDirectory.appendingPathComponent(core.rawValue, conformingTo: .folder)
        
        guard let enumerator = FileManager.default.enumerator(at: coreDirectory
            .appendingPathComponent("skins", conformingTo: .folder), includingPropertiesForKeys: [.isRegularFileKey]) else {
            throw SkinError.enumeratorFailed
        }
        
        try enumerator.forEach { element in
            switch element {
            case let url as URL:
                let attributes = try url.resourceValues(forKeys: [.isRegularFileKey])
                if let isRegularFile = attributes.isRegularFile, isRegularFile {
                    let pathExtension = url.pathExtension.lowercased()
                    if pathExtension == "json" {
                        let data = try Data(contentsOf: url)
                        var skin = try JSONDecoder().decode(Skin.self, from: data)
                        skin.path = url.deletingLastPathComponent()
                        
                        skins.append(skin)
                    }
                }
            default:
                break
            }
        }
    }
     */
}
