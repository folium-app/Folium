//
//  SuperNESCell.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 24/8/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation

@MainActor class SuperNESCell : DefaultCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 1).isActive = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
