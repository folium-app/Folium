//
//  NintendoEntertainmentSystemCell.swift
//  Folium
//
//  Created by Jarrod Norwell on 22/2/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Foundation
import UIKit

@MainActor class NintendoEntertainmentSystemCell : DefaultCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 1).isActive = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
