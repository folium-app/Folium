//
//  Nintendo3DSCell.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 17/7/2024.
//

import Foundation
import UIKit

@MainActor class Nintendo3DSCell : DefaultCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 1).isActive = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func set(text string: String, image data: Data? = nil, with color: UIColor? = nil) {
        super.set(text: string, image: data, with: color)
        guard let blurredImageView, let imageView, let data, let image = data.decodeRGB565(width: 48, height: 48) else {
            return
        }
        
        blurredImageView.image = image
        imageView.image = image.blurMasked(radius: 2)
    }
}
