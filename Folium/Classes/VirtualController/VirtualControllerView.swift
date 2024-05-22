//
//  LMVirtualControllerView.swift
//  Limon
//
//  Created by Jarrod Norwell on 10/9/23.
//

import Foundation
import UIKit

class VirtualControllerView : UIView {
    var virtualButtonDelegate: VirtualControllerButtonDelegate
    
    var dpadView, xybaView: UIView!
    fileprivate var dpadUpButton, dpadLeftButton, dpadDownButton, dpadRightButton: VirtualControllerButton!
    
    fileprivate var leftThumbstickView, rightThumbstickView: UIView!
    
    fileprivate var aButton, bButton, xButton, yButton: VirtualControllerButton!
    
    fileprivate var minusButton, plusButton: VirtualControllerButton!
    
    fileprivate var lButton, zlButton, rButton, zrButton: VirtualControllerButton!
    
    fileprivate var portraitConstraints, landscapeConstraints: [[NSLayoutConstraint]]!
    
    init(core: Core, virtualButtonDelegate: VirtualControllerButtonDelegate) {
        self.virtualButtonDelegate = virtualButtonDelegate
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        portraitConstraints = []
        landscapeConstraints = []
        addDpadView()
        addXYBAView()
        
        switch core {
        case .grape:
            addDpadUp(false, buttonColor: .systemGray)
            addDpadLeft(false, buttonColor: .systemGray)
            addDpadDown(false, buttonColor: .systemGray)
            addDpadRight(false, buttonColor: .systemGray)
            
            addA(false, buttonColor: .systemGray)
            addB(false, buttonColor: .systemGray)
            addX(false, buttonColor: .systemGray)
            addY(false, buttonColor: .systemGray)
            
            addMinus(false, buttonColor: .systemGray)
            addPlus(false, buttonColor: .systemGray)
            
            addL(false, buttonColor: .systemGray)
            addR(false, buttonColor: .systemGray)
        case .kiwi:
            addDpadUp(false, buttonColor: .systemGray)
            addDpadLeft(false, buttonColor: .systemGray)
            addDpadDown(false, buttonColor: .systemGray)
            addDpadRight(false, buttonColor: .systemGray)
            
            addA(false, buttonColor: .systemGray)
            addB(false, buttonColor: .systemGray)
            
            addMinus(false, buttonColor: .systemGray)
            addPlus(false, buttonColor: .systemGray)
        default:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        super.hitTest(point, with: event) == self ? nil : super.hitTest(point, with: event)
    }
    
    func layout() {
        if UIApplication.shared.statusBarOrientation == .portrait {
            addConstraints(portraitConstraints[0])
            addConstraints(portraitConstraints[1])
            
            removeConstraints(landscapeConstraints[0])
            removeConstraints(landscapeConstraints[1])
        } else {
            removeConstraints(portraitConstraints[0])
            removeConstraints(portraitConstraints[1])
            
            addConstraints(landscapeConstraints[0])
            addConstraints(landscapeConstraints[1])
        }
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
    
    fileprivate func addDpadView() {
        dpadView = .init()
        dpadView.translatesAutoresizingMaskIntoConstraints = false
        dpadView.isUserInteractionEnabled = true
        addSubview(dpadView)
        
        let portraitWidthConstraint = if UIDevice.current.userInterfaceIdiom == .phone {
            dpadView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor, constant: -40)
        } else {
            dpadView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 1 / 5, constant: -40)
        }
        
        portraitConstraints.append([
            dpadView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            dpadView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            portraitWidthConstraint,
            dpadView.heightAnchor.constraint(equalTo: dpadView.widthAnchor)
        ])
        
        let landscapeHeightConstraint = if UIDevice.current.userInterfaceIdiom == .phone {
            dpadView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor, constant: 30)
        } else {
            dpadView.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 1 / 5, constant: -40)
        }
        
        landscapeConstraints.append([
            landscapeHeightConstraint,
            dpadView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            dpadView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            dpadView.widthAnchor.constraint(equalTo: dpadView.heightAnchor)
        ])
        
        
        if UIApplication.shared.statusBarOrientation == .portrait {
            addConstraints(portraitConstraints[0])
        } else {
            addConstraints(landscapeConstraints[0])
        }
    }
    
    fileprivate func addXYBAView() {
        xybaView = .init()
        xybaView.translatesAutoresizingMaskIntoConstraints = false
        xybaView.isUserInteractionEnabled = true
        addSubview(xybaView)
        
        let portraitWidthConstraint = if UIDevice.current.userInterfaceIdiom == .phone {
            xybaView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor, constant: 40)
        } else {
            xybaView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 1 / 5, constant: -40)
        }
        
        portraitConstraints.append([
            xybaView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            portraitWidthConstraint,
            xybaView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            xybaView.heightAnchor.constraint(equalTo: xybaView.widthAnchor)
        ])
        
        let landscapeHeightConstraint = if UIDevice.current.userInterfaceIdiom == .phone {
            xybaView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor, constant: 30)
        } else {
            xybaView.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 1 / 5, constant: -40)
        }
        
        landscapeConstraints.append([
            landscapeHeightConstraint,
            xybaView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            xybaView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            xybaView.widthAnchor.constraint(equalTo: xybaView.heightAnchor)
        ])
        
        if UIApplication.shared.statusBarOrientation == .portrait {
            addConstraints(portraitConstraints[1])
        } else {
            addConstraints(landscapeConstraints[1])
        }
    }
    
    fileprivate func addDpadUp(_ shouldHide: Bool, buttonColor: UIColor) {
        dpadUpButton = .init(buttonColor: buttonColor, buttonType: .dpadUp, virtualButtonDelegate: virtualButtonDelegate, shouldHide: shouldHide)
        dpadView.addSubview(dpadUpButton)
        
        addConstraints([
            dpadUpButton.topAnchor.constraint(equalTo: dpadView.topAnchor),
            dpadUpButton.widthAnchor.constraint(equalTo: dpadView.widthAnchor, multiplier: 1 / 3),
            dpadUpButton.heightAnchor.constraint(equalTo: dpadView.heightAnchor, multiplier: 1 / 3),
            dpadUpButton.centerXAnchor.constraint(equalTo: dpadView.centerXAnchor)
        ])
    }
    
    fileprivate func addDpadLeft(_ shouldHide: Bool, buttonColor: UIColor) {
        dpadLeftButton = .init(buttonColor: buttonColor, buttonType: .dpadLeft, virtualButtonDelegate: virtualButtonDelegate, shouldHide: shouldHide)
        dpadView.addSubview(dpadLeftButton)
        
        addConstraints([
            dpadLeftButton.leadingAnchor.constraint(equalTo: dpadView.leadingAnchor),
            dpadLeftButton.widthAnchor.constraint(equalTo: dpadView.widthAnchor, multiplier: 1 / 3),
            dpadLeftButton.heightAnchor.constraint(equalTo: dpadView.heightAnchor, multiplier: 1 / 3),
            dpadLeftButton.centerYAnchor.constraint(equalTo: dpadView.centerYAnchor)
        ])
    }
    
    fileprivate func addDpadDown(_ shouldHide: Bool, buttonColor: UIColor) {
        dpadDownButton = .init(buttonColor: buttonColor, buttonType: .dpadDown, virtualButtonDelegate: virtualButtonDelegate, shouldHide: shouldHide)
        dpadView.addSubview(dpadDownButton)
        
        addConstraints([
            dpadDownButton.bottomAnchor.constraint(equalTo: dpadView.bottomAnchor),
            dpadDownButton.widthAnchor.constraint(equalTo: dpadView.widthAnchor, multiplier: 1 / 3),
            dpadDownButton.heightAnchor.constraint(equalTo: dpadView.heightAnchor, multiplier: 1 / 3),
            dpadDownButton.centerXAnchor.constraint(equalTo: dpadView.centerXAnchor)
        ])
    }
    
    fileprivate func addDpadRight(_ shouldHide: Bool, buttonColor: UIColor) {
        dpadRightButton = .init(buttonColor: buttonColor, buttonType: .dpadRight, virtualButtonDelegate: virtualButtonDelegate, shouldHide: shouldHide)
        dpadView.addSubview(dpadRightButton)
        
        addConstraints([
            dpadRightButton.trailingAnchor.constraint(equalTo: dpadView.trailingAnchor),
            dpadRightButton.widthAnchor.constraint(equalTo: dpadView.widthAnchor, multiplier: 1 / 3),
            dpadRightButton.heightAnchor.constraint(equalTo: dpadView.heightAnchor, multiplier: 1 / 3),
            dpadRightButton.centerYAnchor.constraint(equalTo: dpadView.centerYAnchor)
        ])
    }
    
    fileprivate func addX(_ shouldHide: Bool, buttonColor: UIColor) {
        xButton = .init(buttonColor: buttonColor, buttonType: .x, virtualButtonDelegate: virtualButtonDelegate, shouldHide: shouldHide)
        xybaView.addSubview(xButton)
        
        addConstraints([
            xButton.topAnchor.constraint(equalTo: xybaView.topAnchor),
            xButton.widthAnchor.constraint(equalTo: xybaView.widthAnchor, multiplier: 1 / 3),
            xButton.heightAnchor.constraint(equalTo: xybaView.heightAnchor, multiplier: 1 / 3),
            xButton.centerXAnchor.constraint(equalTo: xybaView.centerXAnchor)
        ])
    }
    
    fileprivate func addY(_ shouldHide: Bool, buttonColor: UIColor) {
        yButton = .init(buttonColor: buttonColor, buttonType: .y, virtualButtonDelegate: virtualButtonDelegate, shouldHide: shouldHide)
        xybaView.addSubview(yButton)
        
        addConstraints([
            yButton.leadingAnchor.constraint(equalTo: xybaView.leadingAnchor),
            yButton.widthAnchor.constraint(equalTo: xybaView.widthAnchor, multiplier: 1 / 3),
            yButton.heightAnchor.constraint(equalTo: xybaView.heightAnchor, multiplier: 1 / 3),
            yButton.centerYAnchor.constraint(equalTo: xybaView.centerYAnchor)
        ])
    }
    
    fileprivate func addB(_ shouldHide: Bool, buttonColor: UIColor) {
        bButton = .init(buttonColor: buttonColor, buttonType: .b, virtualButtonDelegate: virtualButtonDelegate, shouldHide: shouldHide)
        xybaView.addSubview(bButton)
        
        addConstraints([
            bButton.bottomAnchor.constraint(equalTo: xybaView.bottomAnchor),
            bButton.widthAnchor.constraint(equalTo: xybaView.widthAnchor, multiplier: 1 / 3),
            bButton.heightAnchor.constraint(equalTo: xybaView.heightAnchor, multiplier: 1 / 3),
            bButton.centerXAnchor.constraint(equalTo: xybaView.centerXAnchor)
        ])
    }
    
    fileprivate func addA(_ shouldHide: Bool, buttonColor: UIColor) {
        aButton = .init(buttonColor: buttonColor, buttonType: .a, virtualButtonDelegate: virtualButtonDelegate, shouldHide: shouldHide)
        xybaView.addSubview(aButton)
        
        addConstraints([
            aButton.trailingAnchor.constraint(equalTo: xybaView.trailingAnchor),
            aButton.widthAnchor.constraint(equalTo: xybaView.widthAnchor, multiplier: 1 / 3),
            aButton.heightAnchor.constraint(equalTo: xybaView.heightAnchor, multiplier: 1 / 3),
            aButton.centerYAnchor.constraint(equalTo: xybaView.centerYAnchor)
        ])
    }
    
    fileprivate func addMinus(_ shouldHide: Bool, buttonColor: UIColor) {
        minusButton = .init(buttonColor: buttonColor, buttonType: .minus, virtualButtonDelegate: virtualButtonDelegate, shouldHide: shouldHide)
        dpadView.addSubview(minusButton)
        
        addConstraints([
            minusButton.bottomAnchor.constraint(equalTo: dpadView.bottomAnchor),
            minusButton.trailingAnchor.constraint(equalTo: dpadView.trailingAnchor),
            minusButton.widthAnchor.constraint(equalTo: dpadView.widthAnchor, multiplier: 1 / 5),
            minusButton.heightAnchor.constraint(equalTo: dpadView.heightAnchor, multiplier: 1 / 5)
        ])
    }
    
    fileprivate func addPlus(_ shouldHide: Bool, buttonColor: UIColor) {
        plusButton = .init(buttonColor: buttonColor, buttonType: .plus, virtualButtonDelegate: virtualButtonDelegate, shouldHide: shouldHide)
        xybaView.addSubview(plusButton)
        
        addConstraints([
            plusButton.leadingAnchor.constraint(equalTo: xybaView.leadingAnchor),
            plusButton.bottomAnchor.constraint(equalTo: xybaView.bottomAnchor),
            plusButton.widthAnchor.constraint(equalTo: xybaView.widthAnchor, multiplier: 1 / 5),
            plusButton.heightAnchor.constraint(equalTo: xybaView.heightAnchor, multiplier: 1 / 5)
        ])
    }
    
    fileprivate func addL(_ shouldHide: Bool, buttonColor: UIColor) {
        lButton = .init(buttonColor: buttonColor, buttonType: .l, virtualButtonDelegate: virtualButtonDelegate, shouldHide: shouldHide)
        addSubview(lButton)
        
        addConstraints([
            lButton.leadingAnchor.constraint(equalTo: dpadView.leadingAnchor),
            lButton.bottomAnchor.constraint(equalTo: dpadView.topAnchor, constant: -20),
            lButton.trailingAnchor.constraint(equalTo: dpadView.centerXAnchor, constant: -10),
            lButton.heightAnchor.constraint(equalTo: lButton.widthAnchor, multiplier: 1 / 2)
        ])
    }
    
    fileprivate func addZL(_ shouldHide: Bool, buttonColor: UIColor) {
        zlButton = .init(buttonColor: buttonColor, buttonType: .zl, virtualButtonDelegate: virtualButtonDelegate, shouldHide: shouldHide)
        addSubview(zlButton)
        
        addConstraints([
            zlButton.leadingAnchor.constraint(equalTo: dpadView.centerXAnchor, constant: 10),
            zlButton.bottomAnchor.constraint(equalTo: dpadView.topAnchor, constant: -20),
            zlButton.trailingAnchor.constraint(equalTo: dpadView.trailingAnchor),
            zlButton.heightAnchor.constraint(equalTo: zlButton.widthAnchor, multiplier: 1 / 2)
        ])
    }
    
    fileprivate func addR(_ shouldHide: Bool, buttonColor: UIColor) {
        rButton = .init(buttonColor: buttonColor, buttonType: .r, virtualButtonDelegate: virtualButtonDelegate, shouldHide: shouldHide)
        addSubview(rButton)
        
        addConstraints([
            rButton.leadingAnchor.constraint(equalTo: xybaView.centerXAnchor, constant: 10),
            rButton.bottomAnchor.constraint(equalTo: xybaView.topAnchor, constant: -20),
            rButton.trailingAnchor.constraint(equalTo: xybaView.trailingAnchor),
            rButton.heightAnchor.constraint(equalTo: rButton.widthAnchor, multiplier: 1 / 2)
        ])
    }
    
    fileprivate func addZR(_ shouldHide: Bool, buttonColor: UIColor) {
        zrButton = .init(buttonColor: buttonColor, buttonType: .zr, virtualButtonDelegate: virtualButtonDelegate, shouldHide: shouldHide)
        addSubview(zrButton)
        
        addConstraints([
            zrButton.leadingAnchor.constraint(equalTo: xybaView.leadingAnchor),
            zrButton.bottomAnchor.constraint(equalTo: xybaView.topAnchor, constant: -20),
            zrButton.trailingAnchor.constraint(equalTo: xybaView.centerXAnchor, constant: -10),
            zrButton.heightAnchor.constraint(equalTo: zrButton.widthAnchor, multiplier: 1 / 2)
        ])
    }
}
