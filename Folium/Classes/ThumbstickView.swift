//
//  ThumbstickView.swift
//  Folium
//
//  Created by Jarrod Norwell on 18/6/2026.
//

import ColourKit
import ConstraintKit
import FontKit
import UIKit

class ThumbstickView : UIView, UIGestureRecognizerDelegate {
    var label: UILabel? = nil
    
    private let gradientMask: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.type = .radial
        gradient.colors = [
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        gradient.locations = [0.0, 0.33, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        return gradient
    }()
    
    private var deadZone: Double = 0.05
    private var touchMoved: Bool = false
    
    var didClick: (() -> Void)? = nil
    var didUnclick: (() -> Void)? = nil
    
    var didDrag: (((x: Float, y: Float)) -> Void)? = nil
    var didUndrag: (() -> Void)? = nil
    
    private(set) var normalizedPoint: (Float, Float) = (0, 0) {
        didSet {
            didDrag?(normalizedPoint)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.mask = gradientMask
        
        let imageView: UIImageView = UIImageView(image: UIImage(systemName: "app.background.dotted"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .secondarySystemBackground
        addSubview(imageView)
        
        imageView.top.constraint(equalTo: salg.top).isActive = true
        imageView.left.constraint(equalTo: salg.left).isActive = true
        imageView.bottom.constraint(equalTo: salg.bottom).isActive = true
        imageView.right.constraint(equalTo: salg.right).isActive = true
        
        label = UILabel()
        guard let label else {
            return
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .regular(from: .title3)
        label.textColor = .label
        addSubview(label)
        
        label.centerX.constraint(equalTo: salg.centerX).isActive = true
        label.centerY.constraint(equalTo: salg.centerY).isActive = true
        
        let gestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        gestureRecognizer.delegate = self
        gestureRecognizer.minimumPressDuration = 2 / 3
        addGestureRecognizer(gestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func longPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            if !touchMoved {
                didClick?()
            }
        default:
            touchMoved = false
            didUnclick?()
        }
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        gradientMask.frame = bounds
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isExclusiveTouch = true
        touchMoved = true
        update(with: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        isExclusiveTouch = true
        touchMoved = true
        update(with: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isExclusiveTouch = false
        touchMoved = false
        normalizedPoint = (0, 0)
        didUndrag?()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        isExclusiveTouch = false
        touchMoved = false
        normalizedPoint = (0, 0)
        didUndrag?()
    }
    
    private func update(with touches: Set<UITouch>) {
        guard let touch: UITouch = touches.first else {
            return
        }
        
        normalizedPoint = normalize(location: touch.location(in: self))
    }
    
    private func normalize(location: CGPoint) -> (Float, Float) {
        let w = Float(bounds.width)
        let h = Float(bounds.height)
        
        guard w > 0, h > 0 else {
            return (0, 0)
        }
        
        let locationX = Float(location.x)
        let locationY = Float(location.y)
        
        let clampedX = min(max(locationX, 0), w)
        let clampedY = min(max(locationY, 0), h)
        
        var x = (clampedX - w / 2) / (w / 2)
        var y = (clampedY - h / 2) / (h / 2)
        
        let magnitude = sqrt(x * x + y * y)
        let deadZone = Float(deadZone)
        
        guard magnitude > deadZone else {
            return (0, 0)
        }
        
        let scaled = (magnitude - deadZone) / (1 - deadZone)
        let scale = scaled / magnitude
        
        x = min(max(x * scale, -1), 1)
        y = min(max(y * scale, -1), 1)
        
        return (x, -y)
    }
    
    private func clamp(_ value: Double) -> Double {
        min(max(value, -1.0), 1.0)
    }
}
