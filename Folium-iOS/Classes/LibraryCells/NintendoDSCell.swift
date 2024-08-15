//
//  NintendoDSCell.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 18/7/2024.
//

import Foundation
import UIKit

@MainActor class NintendoDSCell : DefaultCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 1).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(text string: String, image data: UnsafeMutablePointer<UInt32>? = nil, with color: UIColor? = nil) {
        super.set(text: string, with: color)
        guard let blurredImageView, let imageView, let data, let image = CGImage.cgImage(data, 32, 32) else {
            return
        }
        
        blurredImageView.image = .init(cgImage: image)
        imageView.image = .init(cgImage: image).blurMasked(radius: 2)
    }
}
