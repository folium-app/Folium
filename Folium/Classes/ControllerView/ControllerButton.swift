//
//  ControllerButton.swift
//  Folium
//
//  Created by Jarrod Norwell on 9/6/2024.
//

import Foundation
import UIKit

protocol ControllerButtonDelegate {
    func touchBegan(with type: Skin.Button.`Type`)
    func touchEnded(with type: Skin.Button.`Type`)
    func touchMoved(with type: Skin.Button.`Type`)
}

class ControllerButton : UIView {
    var button: Skin.Button
    var delegate: ControllerButtonDelegate? = nil
    init(with button: Skin.Button, colors: (UIColor, UIColor), delegate: ControllerButtonDelegate? = nil, skin: Skin) {
        self.button = button
        self.delegate = delegate
        super.init(frame: .zero)
        
        let imageView = UIImageView(image: button.image(for: skin.core)?
            .applyingSymbolConfiguration(.init(paletteColors: [colors.0, colors.1])))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let delegate, let _ = touches.first else {
            return
        }
        
        if button.vibrateWhenTapped {
            if #available(iOS 17.5, *) {
                UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle(rawValue: button.vibrationStrength) ?? .light, view: self).impactOccurred()
            } else {
                UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle(rawValue: button.vibrationStrength) ?? .light).impactOccurred()
            }
        }
        
        delegate.touchBegan(with: button.type)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let delegate, let _ = touches.first else {
            return
        }
        
        delegate.touchEnded(with: button.type)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let delegate, let _ = touches.first else {
            return
        }
        
        delegate.touchMoved(with: button.type)
    }
}
