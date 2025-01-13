//
//  SettingHeader.swift
//  SettingsKit
//
//  Created by Jarrod Norwell on 14/1/2025.
//

import Foundation

public class SettingHeader : AHS, @unchecked Sendable {
    public let text: String
    public var secondaryText: String? = nil
    
    public init(text: String, secondaryText: String? = nil) {
        self.text = text
        self.secondaryText = secondaryText
    }
}
