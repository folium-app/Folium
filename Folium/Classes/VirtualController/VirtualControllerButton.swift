//
//  VirtualControllerButton.swift
//  Limon
//
//  Created by Jarrod Norwell on 10/18/23.
//

import Foundation
import UIKit

class VirtualControllerButton : UIView {
    enum ButtonType : String, Codable {
        case a = "a", b = "b", x = "x", y = "y"
        case minus = "minus", plus = "plus"
        case dpadUp = "arrowtriangle.up", dpadLeft = "arrowtriangle.left", dpadDown = "arrowtriangle.down",
             dpadRight = "arrowtriangle.right"
        case l = "l.button.roundedbottom.horizontal", zl = "zl.button.roundedtop.horizontal",
             r = "r.button.roundedbottom.horizontal", zr = "zr.button.roundedtop.horizontal"
        
        var systemName: String {
            // if [ButtonType.l, ButtonType.zl, ButtonType.r, ButtonType.zr].contains(self) {
            //     "button.horizontal"
            // } else {
            //     "circle"
            // }
            
            switch self {
            case .a, .b, .x, .y, .minus, .plus, .dpadUp, .dpadLeft, .dpadDown, .dpadRight:
                rawValue.appending(".circle.fill")
            case .l, .zl, .r, .zr:
                if #available(iOS 17, *) {
                    rawValue.appending(".fill")
                } else {
                    rawValue.replacingOccurrences(of: "button", with: "rectangle")
                        .replacingOccurrences(of: "horizontal", with: "fill")
                }
            }
        }
    }
    
    var imageView: UIImageView!
    fileprivate var colors: UIImage.SymbolConfiguration
    fileprivate var pointSize: CGFloat
    
    let buttonColors: (UIColor, UIColor)
    let buttonType: ButtonType
    var virtualButtonDelegate: VirtualControllerButtonDelegate
    init(buttonColors: (UIColor, UIColor), buttonType: ButtonType, virtualButtonDelegate: VirtualControllerButtonDelegate, shouldHide: Bool) {
        self.buttonColors = buttonColors
        self.buttonType = buttonType
        self.virtualButtonDelegate = virtualButtonDelegate
        self.colors = .init(paletteColors: [])
        self.pointSize = if buttonType == .minus || buttonType == .plus { 32 } else { 40 }
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        colors = if buttonType.systemName == "circle"/* || [ButtonType.l, ButtonType.zl, ButtonType.r, ButtonType.zr].contains(buttonType)*/ {
            .init(paletteColors: [buttonColors.0, buttonColors.1])
        } else {
            .init(paletteColors: [buttonColors.0, buttonColors.1])
        }
        
        imageView = .init(image: .init(systemName: buttonType.systemName)?
            .applyingSymbolConfiguration(.init(pointSize: pointSize, weight: .regular, scale: .large))?
            .applyingSymbolConfiguration(colors))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = shouldHide ? 0 : 1
        imageView.isUserInteractionEnabled = shouldHide ? false : true
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        addConstraints([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        virtualButtonDelegate.touchDown(buttonType)
        if buttonType.systemName == "circle"/* || [ButtonType.l, ButtonType.zl, ButtonType.r, ButtonType.zr].contains(buttonType)*/ {
            guard let image = UIImage(systemName: buttonType.systemName.appending(".fill"))?
                .applyingSymbolConfiguration(.init(pointSize: pointSize, weight: .regular, scale: .large))?
                .applyingSymbolConfiguration(colors) else {
                return
            }
            
            if #available(iOS 17, *) {
                imageView.setSymbolImage(image, contentTransition: .automatic)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        virtualButtonDelegate.touchUpInside(buttonType)
        if buttonType.systemName == "circle"/* || [ButtonType.l, ButtonType.zl, ButtonType.r, ButtonType.zr].contains(buttonType)*/ {
            guard let image = UIImage(systemName: buttonType.systemName)?
                .applyingSymbolConfiguration(.init(pointSize: pointSize, weight: .regular, scale: .large))?
                .applyingSymbolConfiguration(colors) else {
                return
            }
            
            if #available(iOS 17, *) {
                imageView.setSymbolImage(image, contentTransition: .automatic)
            }
        }
    }
}
