//
//  GameBoyCell.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 4/7/2024.
//

import Foundation
import UIKit

@MainActor class GameBoyCell : DefaultCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 1).isActive = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
