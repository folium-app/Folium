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

enum ThumbstickPlacement : Int {
    case left, right
}

class ThumbstickView : UIView, UIGestureRecognizerDelegate {
    var label: UILabel? = nil
    
    private var deadZone: Double = 0.05
    private var touchMoved: Bool = false
    
    var didClick: (() -> Void)? = nil
    var didUnclick: (() -> Void)? = nil
    
    var didDrag: (((x: UInt8, y: UInt8)) -> Void)? = nil
    var didUndrag: (() -> Void)? = nil
    
    private(set) var normalizedPoint: (UInt8, UInt8) = (0, 0) {
        didSet {
            didDrag?(normalizedPoint)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let symbolConfiguration: UIImage.SymbolConfiguration = UIImage.SymbolConfiguration(hierarchicalColor: .secondarySystemBackground)
        
        let imageView: UIImageView = UIImageView(image: UIImage(systemName: "app.background.dotted")?
            .applyingSymbolConfiguration(symbolConfiguration))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(imageView, belowSubview: self)
        
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let gradient = CAGradientLayer()
        gradient.type = .radial
        gradient.colors = [
            UIColour.white.cgColor,
            UIColour.white.cgColor,
            UIColour.clear.cgColor
        ]
        gradient.locations = [0.0, 0.33, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = frame

        layer.mask = gradient
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
    
    private func normalize(location: CGPoint) -> (UInt8, UInt8) {
        let w = bounds.width
        let h = bounds.height
        guard w > 0, h > 0 else {
            return (0, 0)
        }

        let clampedX: Double = min(max(location.x, 0), w)
        let clampedY: Double = min(max(location.y, 0), h)

        var x: Double = (clampedX - w / 2) / (w / 2)
        var y: Double = (clampedY - h / 2) / (h / 2)

        let magnitude: Double = sqrt(x * x + y * y)
        guard magnitude > deadZone else {
            return (0, 0)
        }

        let scaled: Double = (magnitude - deadZone) / (1 - deadZone)
        let scale: Double = scaled / magnitude

        x *= scale
        y *= scale

        return (toUInt8(clamp(x)), toUInt8(clamp(y)))
    }

    private func clamp(_ value: Double) -> Int {
        let scaled: Int = Int(round(value * 127))
        return min(max(scaled, -127), 127)
    }
    
    private func toUInt8(_ value: Int) -> UInt8 {
        UInt8(bitPattern: Int8(value))
    }
}
