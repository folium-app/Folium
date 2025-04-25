//
//  LargeMapCell.swift
//  Folium
//
//  Created by Jarrod Norwell on 23/4/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Foundation
import UIKit

class LargeMapCell : UICollectionViewCell {
    var mapViewWithShadow: MapViewWithShadow? = nil
    var getDirectionsButton: UIButton? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        mapViewWithShadow = .init()
        guard let mapViewWithShadow else { return }
        mapViewWithShadow.translatesAutoresizingMaskIntoConstraints = false
        mapViewWithShadow.layer.cornerRadius = 0
        if let mapView = mapViewWithShadow.mapView {
            mapView.layer.cornerRadius = 0
        }
        addSubview(mapViewWithShadow)
        
        var configuration: UIButton.Configuration = .filled()
        configuration.buttonSize = .medium
        configuration.cornerStyle = .capsule
        configuration.imagePadding = 8
        
        getDirectionsButton = .init(configuration: configuration)
        guard let getDirectionsButton else { return }
        getDirectionsButton.translatesAutoresizingMaskIntoConstraints = false
        getDirectionsButton.configurationUpdateHandler = { [weak self] button in
            guard let self, let multiplayerLocation, var configuration = button.configuration else { return }
            
            let state = switch multiplayerLocation.state {
            case .uninitialized: "Tap to Connect"
            case .idle: "Idle"
            case .joining: "Joining"
            case .joined: "Joined"
            case .moderator: "Moderator"
            default: "Unknown"
            }
            
            configuration.attributedTitle = .init(state, attributes: .init([
                .font : UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
            ]))
            
            configuration.baseBackgroundColor = switch multiplayerLocation.state {
            case .uninitialized, .idle: .systemGray
            case .joining: .systemOrange
            case .joined: .systemGreen
            case .moderator: .systemYellow
            default: .systemGray
            }
            
            configuration.image = switch multiplayerLocation.state {
            case .moderator:
                    .init(systemName: "crown.fill")?
                        .applyingSymbolConfiguration(.init(scale: .medium))
            default: nil
            }
            
            button.configuration = configuration
        }
        addSubview(getDirectionsButton)
        
        mapViewWithShadow.topAnchor.constraint(equalTo: topAnchor).isActive = true
        mapViewWithShadow.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        mapViewWithShadow.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        mapViewWithShadow.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        mapViewWithShadow.heightAnchor.constraint(equalTo: mapViewWithShadow.widthAnchor, multiplier: 8 / 7).isActive = true
        
        getDirectionsButton.centerXAnchor.constraint(equalTo: mapViewWithShadow.centerXAnchor).isActive = true
        getDirectionsButton.bottomAnchor.constraint(equalTo: mapViewWithShadow.bottomAnchor, constant: -16).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let mapViewWithShadow else { return }
        
        let gradient = CAGradientLayer()
        gradient.frame = mapViewWithShadow.frame
        gradient.colors = [
            UIColor.black.cgColor,
            UIColor.black.cgColor,
            UIColor.clear.cgColor
        ]
        gradient.locations = [0, 0.66, 1]
        mapViewWithShadow.layer.mask = gradient
    }
    
    var multiplayerLocation: MultiplayerLocation? = nil
    func set(_ multiplayerLocation: MultiplayerLocation, _ selector: Selector, _ target: UIViewController) {
        guard let mapViewWithShadow else { return }
        mapViewWithShadow.region(with: multiplayerLocation.coordinate)
        
        self.multiplayerLocation = multiplayerLocation
        
        guard let getDirectionsButton else { return }
        getDirectionsButton.addTarget(target, action: selector, for: .touchUpInside)
        getDirectionsButton.setNeedsUpdateConfiguration()
    }
}
