//
//  AppIntent.swift
//  LastPlayedWidget
//
//  Created by Jarrod Norwell on 13/11/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }

    // An example configurable parameter.
    // @Parameter(title: "SHA256", default: "")
    // var sha256: String
}
