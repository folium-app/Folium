//
//  SettingDelegate.swift
//  SettingsKit
//
//  Created by Jarrod Norwell on 14/1/2025.
//

import Foundation

public protocol SettingDelegate {
    func didChangeSetting(at indexPath: IndexPath)
}
