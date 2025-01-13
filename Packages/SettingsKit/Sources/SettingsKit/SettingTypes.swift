//
//  SettingTypes.swift
//  SettingsKit
//
//  Created by Jarrod Norwell on 14/1/2025.
//

import Foundation

public class AHS : NSObject, @unchecked Sendable {}

public class BaseSetting : AHS, @unchecked Sendable {
    public let key, title: String
    public var details: String? = nil
    public var delegate: SettingDelegate? = nil
    
    public init(key: String,
                title: String,
                details: String? = nil,
                delegate: (any SettingDelegate)? = nil) {
        self.key = key
        self.title = title
        self.details = details
        self.delegate = delegate
    }
}

/*
 MARK: BlankSetting
 Used to add whitespace between settings
 */
public class BlankSetting : AHS, @unchecked Sendable {}

/*
 MARK: BoolSetting
 Used to toggle something off or on
 */
public class BoolSetting : BaseSetting, @unchecked Sendable {
    public var value: Bool
    
    public init(key: String,
                title: String,
                details: String? = nil,
                value: Bool,
                delegate: (any SettingDelegate)? = nil) {
        self.value = value
        super.init(key: key,
                   title: title,
                   details: details,
                   delegate: delegate)
    }
}

/*
 MARK: InputNumberSetting
 Used to input a number
 */
public class InputNumberSetting : BaseSetting, @unchecked Sendable {
    public let min, max: Double
    public var value: Double
    
    public init(key: String,
                title: String,
                details: String? = nil,
                min: Double,
                max: Double,
                value: Double,
                delegate: (any SettingDelegate)? = nil) {
        self.min = min
        self.max = max
        self.value = value
        super.init(key: key,
                   title: title,
                   details: details,
                   delegate: delegate)
    }
}

/*
 MARK: InputStringSetting
 Used to input a string
 */
public class InputStringSetting : BaseSetting, @unchecked Sendable {
    public var placeholder: String? = nil, value: String? = nil
    public let action: () -> Void
    
    public init(key: String,
                title: String,
                details: String? = nil,
                placeholder: String? = nil,
                value: String? = nil,
                action: @escaping () -> Void,
                delegate: (any SettingDelegate)? = nil) {
        self.placeholder = placeholder
        self.value = value
        self.action = action
        super.init(key: key,
                   title: title,
                   details: details,
                   delegate: delegate)
    }
}

public class SelectionSetting : BaseSetting, @unchecked Sendable {
    public let values: [String : Any]
    public var selectedValue: Any? = nil
    
    public init(key: String,
                title: String,
                details: String? = nil,
                values: [String : Any],
                selectedValue: Any? = nil,
                delegate: (any SettingDelegate)? = nil) {
        self.values = values
        self.selectedValue = selectedValue
        super.init(key: key,
                   title: title,
                   details: details,
                   delegate: delegate)
    }
}

/*
 MARK: StepperSetting
 Used to step a value
 */
public class StepperSetting : BaseSetting, @unchecked Sendable {
    public let min, max: Double
    public var value: Double
    
    public init(key: String,
                title: String,
                details: String? = nil,
                min: Double,
                max: Double,
                value: Double,
                delegate: (any SettingDelegate)? = nil) {
        self.min = min
        self.max = max
        self.value = value
        super.init(key: key,
                   title: title,
                   details: details,
                   delegate: delegate)
    }
}
