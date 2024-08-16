//
//  Bundle.swift
//  Folium
//
//  Created by Jarrod Norwell on 16/8/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation

extension Bundle {
    var appBuild: String? {
        getInfo("CFBundleVersion")
    }
    
    var appVersionLong: String? {
        getInfo("CFBundleShortVersionString")
    }
    
    fileprivate func getInfo(_ str: String) -> String? {
        infoDictionary?[str] as? String
    }
}
