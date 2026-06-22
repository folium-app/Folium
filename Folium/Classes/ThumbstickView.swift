//
//  ThumbstickView.swift
//  Folium
//
//  Created by Jarrod Norwell on 18/6/2026.
//

import UIKit

enum ThumbstickPlacement : Int {
    case left, right
}

class ThumbstickView : UIView, UIGestureRecognizerDelegate {
    var label: UILabel? = nil
    
    var deadZone: CGFloat = 0.05
    
    var didDrag: (((x: UInt8, y: UInt8)) -> Void)?
    var didUndrag: (() -> Void)?
    
    var didClick: (() -> Void)?
    var didUnclick: (() -> Void)?
    
    private var touchMoved = false
    
    private(set) var normalizedPoint: (UInt8, UInt8) = (0, 0) {
        didSet {
            didDrag?(normalizedPoint)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let isSmallScreen: Bool = false
        
        let imageView: UIImageView = UIImageView(image: UIImage(systemName: "app.background.dotted")?
            .applyingSymbolConfiguration(UIImage.SymbolConfiguration(hierarchicalColor: .secondarySystemBackground)))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(imageView, belowSubview: self)
        
        label = UILabel()
        guard let label else {
            return
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: isSmallScreen ? .body : .title3)
        label.textColor = .label
        addSubview(label)
        
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
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
            guard !touchMoved else {
                return
            }
            
            didClick?()
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
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        gradient.locations = [0.0, 2 / 3, 1.0] as [NSNumber]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = bounds

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
        guard let touch = touches.first else {
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

        let clampedX = min(max(location.x, 0), w)
        let clampedY = min(max(location.y, 0), h)

        var x = (clampedX - w / 2) / (w / 2)
        var y = (clampedY - h / 2) / (h / 2)

        let magnitude = sqrt(x * x + y * y)
        guard magnitude > deadZone else {
            return (0, 0)
        }

        let scaled = (magnitude - deadZone) / (1 - deadZone)
        let scale = scaled / magnitude

        x *= scale
        y *= scale

        return (
            toUInt8(clamp(x)),
            toUInt8(clamp(y))
        )
    }

    private func clamp(_ value: CGFloat) -> Int {
        let scaled = Int(round(value * 127))
        return min(max(scaled, -127), 127)
    }
    
    private func toUInt8(_ value: Int) -> UInt8 {
        UInt8(bitPattern: Int8(value))
    }
}
