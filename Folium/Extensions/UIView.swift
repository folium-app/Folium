//
//  UIView.swift
//  Folium
//
//  Created by Jarrod Norwell on 17/6/2026.
//

import UIKit

extension UIView {
    func applyCutout(from button: UIButton, to imageView: UIImageView, expandBy padding: CGFloat) {
        imageView.layoutIfNeeded()
        button.layoutIfNeeded()
        
        // Mask must match imageView size
        let maskLayer = CAShapeLayer()
        maskLayer.frame = imageView.bounds
        
        // Convert UIButton frame → imageView coordinate space
        var holeFrame = button.convert(button.bounds, to: imageView)
        
        // Expand frame by padding
        holeFrame = holeFrame.insetBy(dx: -padding, dy: -padding)
        
        // Full mask area
        let fullPath = UIBezierPath(rect: imageView.bounds)
        
        // Circle (using expanded frame)
        let circlePath = UIBezierPath(
            roundedRect: holeFrame,
            cornerRadius: holeFrame.width / 2   // stays perfectly circular
        )
        
        fullPath.append(circlePath)
        fullPath.usesEvenOddFillRule = true
        
        maskLayer.path = fullPath.cgPath
        maskLayer.fillRule = .evenOdd
        
        imageView.layer.mask = maskLayer
    }
}
