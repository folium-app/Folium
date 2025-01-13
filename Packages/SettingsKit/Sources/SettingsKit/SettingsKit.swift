// The Swift Programming Language
// https://docs.swift.org/swift-book

public struct SettingsKit {
    public static let shared = SettingsKit()
    
    public func blank() -> BlankSetting { .init() }
    
    public func bool(key: String,
                     title: String,
                     details: String? = nil,
                     value: Bool,
                     delegate: (any SettingDelegate)? = nil) -> BoolSetting {
        .init(key: key,
              title: title,
              details: details,
              value: value,
              delegate: delegate)
    }
    
    public func inputNumber(key: String,
                            title: String,
                            details: String? = nil,
                            min: Double,
                            max: Double,
                            value: Double,
                            delegate: (any SettingDelegate)? = nil) -> InputNumberSetting {
        .init(key: key,
              title: title,
              details: details,
              min: min,
              max: max,
              value: value,
              delegate: delegate)
    }
    
    public func inputString(key: String,
                            title: String,
                            details: String? = nil,
                            placeholder: String? = nil,
                            value: String? = nil,
                            action: @escaping () -> Void,
                            delegate: (any SettingDelegate)? = nil) -> InputStringSetting {
        .init(key: key,
              title: title,
              details: details,
              placeholder: placeholder,
              value: value,
              action: action,
              delegate: delegate)
    }
    
    public func selection(key: String,
                          title: String,
                          details: String? = nil,
                          values: [String : Any],
                          selectedValue: Any? = nil,
                          delegate: (any SettingDelegate)? = nil) -> SelectionSetting {
        .init(key: key,
              title: title,
              details: details,
              values: values,
              selectedValue: selectedValue,
              delegate: delegate)
    }
    
    public func stepper(key: String,
                 title: String,
                 details: String? = nil,
                 min: Double,
                 max: Double,
                 value: Double,
                 delegate: (any SettingDelegate)? = nil) -> StepperSetting {
        .init(key: key,
              title: title,
              details: details,
              min: min,
              max: max,
              value: value,
              delegate: delegate)
    }
}
