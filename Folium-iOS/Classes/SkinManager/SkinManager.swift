//
//  SkinManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 13/6/2024.
//

import Foundation
import UIKit

class SkinManager {
    static let shared = SkinManager()
    
    var skins: [Skin] = []
    func getSkins() throws {
        skins.removeAll()
        
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
    
    func skin(from url: URL) throws -> Skin {
        let url = url.appendingPathComponent("info.json", conformingTo: .fileURL)
        let data = try Data(contentsOf: url)
        var skin = try JSONDecoder().decode(Skin.self, from: data)
        skin.url = url.deletingLastPathComponent()
        return skin
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
        case .iPhone12mini, .iPhone13mini:
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
                .iPhone12mini, .iPhone13mini
            ]), title: "Default Skin")
        case .iPhone12, .iPhone12Pro, .iPhone12ProMax,
                .iPhone13Pro, .iPhone13ProMax, .iPhone13,
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
                .iPhone12, .iPhone12Pro, .iPhone12ProMax,
                .iPhone13Pro, .iPhone13ProMax, .iPhone13,
                .iPhone14, .iPhone14Plus, .iPhone14Pro, .iPhone14ProMax,
                .iPhone15, .iPhone15Plus, .iPhone15Pro, .iPhone15ProMax
            ]), title: "Default Skin")
        case .iPad_10th,
                .iPadPro_11_inch_4th, .iPadPro_12_9_inch_6th,
                .iPadAir_6th, .iPadAir_7th,
                .iPadPro_11_inch_5th, .iPadPro_12_9_inch_7th:
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
                .iPad_10th,
                .iPadPro_11_inch_4th, .iPadPro_12_9_inch_6th,
                .iPadAir_6th, .iPadAir_7th,
                .iPadPro_11_inch_5th, .iPadPro_12_9_inch_7th
            ]), title: "Default Skin")
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
        case .iPhone12mini, .iPhone13mini:
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
            ]), core: .cytrus, orientations: .init(portrait: portrait, supportedDevices: [
                .iPhone12mini, .iPhone13mini
            ]), title: "Default Skin")
        case .iPhone12, .iPhone12Pro, .iPhone12ProMax,
                .iPhone13Pro, .iPhone13ProMax, .iPhone13,
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
                .iPhone12, .iPhone12Pro, .iPhone12ProMax,
                .iPhone13Pro, .iPhone13ProMax, .iPhone13,
                .iPhone14, .iPhone14Plus, .iPhone14Pro, .iPhone14ProMax,
                .iPhone15, .iPhone15Plus, .iPhone15Pro, .iPhone15ProMax
            ]), title: "Default Skin")
        case .iPad_10th,
                .iPadPro_11_inch_4th, .iPadPro_12_9_inch_6th,
                .iPadAir_6th, .iPadAir_7th,
                .iPadPro_11_inch_5th, .iPadPro_12_9_inch_7th:
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
            ]), core: .grape, orientations: .init(portrait: portrait, supportedDevices: [
                .iPad_10th,
                .iPadPro_11_inch_4th, .iPadPro_12_9_inch_6th,
                .iPadAir_6th, .iPadAir_7th,
                .iPadPro_11_inch_5th, .iPadPro_12_9_inch_7th
            ]), title: "Default Skin")
        }
    }
    
    var mangoSkin: Skin? {
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
        case .iPhone12mini, .iPhone13mini:
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
                .init(x: 0, y: safeAreaInsets.top, width: width, height: width * (7 / 8))
            ], thumbsticks: [])
            
            return .init(author: .init(name: "Antique", socials: [
                .init(type: .twitter, username: "antique_codes")
            ]), core: .mango, orientations: .init(portrait: portrait, supportedDevices: [
                .iPhone12mini, .iPhone13mini
            ]), title: "Default Skin")
        case .iPhone12, .iPhone12Pro, .iPhone12ProMax,
                .iPhone13Pro, .iPhone13ProMax, .iPhone13,
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
                .init(x: 0, y: safeAreaInsets.top, width: width, height: width * (7 / 8))
            ], thumbsticks: [])
            
            return .init(author: .init(name: "Antique", socials: [
                .init(type: .twitter, username: "antique_codes")
            ]), core: .mango, orientations: .init(portrait: portrait, supportedDevices: [
                .iPhone12, .iPhone12Pro, .iPhone12ProMax,
                .iPhone13Pro, .iPhone13ProMax, .iPhone13,
                .iPhone14, .iPhone14Plus, .iPhone14Pro, .iPhone14ProMax,
                .iPhone15, .iPhone15Plus, .iPhone15Pro, .iPhone15ProMax
            ]), title: "Default Skin")
        case .iPad_10th,
                .iPadPro_11_inch_4th, .iPadPro_12_9_inch_6th,
                .iPadAir_6th, .iPadAir_7th,
                .iPadPro_11_inch_5th, .iPadPro_12_9_inch_7th:
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
                .init(x: 0, y: safeAreaInsets.top, width: width, height: width * (7 / 8))
            ], thumbsticks: [])
            
            return .init(author: .init(name: "Antique", socials: [
                .init(type: .twitter, username: "antique_codes")
            ]), core: .mango, orientations: .init(portrait: portrait, supportedDevices: [
                .iPad_10th,
                .iPadPro_11_inch_4th, .iPadPro_12_9_inch_6th,
                .iPadAir_6th, .iPadAir_7th,
                .iPadPro_11_inch_5th, .iPadPro_12_9_inch_7th
            ]), title: "Default Skin")
        }
    }
}
