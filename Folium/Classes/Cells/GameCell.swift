//
//  GameCell.swift
//  Folium
//
//  Created by Jarrod Norwell on 22/6/2026.
//

import ConstraintKit
import ExtensionsKit
import FontKit
import UIKit

class GameCell : UICollectionViewCell {
    var fileManager: FileManager = .default
    
    var hasCustomArtwork: Bool = false
    var hasDefaultArtwork: Bool = false
    
    var visualEffectView: UIVisualEffectView? = nil
    
    var missingImageView: UIImageView? = nil,
        imageView: UIImageView? = nil,
        backgroundImageView: UIImageView? = nil
    
    var averageImageColour: UIColor? = nil
    var button: UIButton? = nil
    
    var label: UILabel? = nil,
        secondaryLabel: UILabel? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        visualEffectView = UIVisualEffectView(effect: UIGlassEffect(style: .regular))
        guard let visualEffectView: UIVisualEffectView else {
            return
        }
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(visualEffectView)
        
        visualEffectView.top.constraint(equalTo: contentView.salg.top).isActive = true
        visualEffectView.left.constraint(equalTo: contentView.salg.left).isActive = true
        visualEffectView.right.constraint(equalTo: contentView.salg.right).isActive = true
        visualEffectView.height.constraint(equalTo: contentView.salg.width).isActive = true
        
        missingImageView = UIImageView(image: UIImage(systemName: "nosign"))
        guard let missingImageView: UIImageView else {
            return
        }
        missingImageView.translatesAutoresizingMaskIntoConstraints = false
        missingImageView.tintColor = .separator
        visualEffectView.contentView.addSubview(missingImageView)
        
        missingImageView.width.constraint(equalTo: visualEffectView.contentView.salg.width, multiplier: 2.0 / 5.0).isActive = true
        missingImageView.height.constraint(equalTo: missingImageView.salg.width).isActive = true
        missingImageView.centerX.constraint(equalTo: visualEffectView.contentView.salg.centerX).isActive = true
        missingImageView.centerY.constraint(equalTo: visualEffectView.contentView.salg.centerY).isActive = true
        
        backgroundImageView = UIImageView()
        guard let backgroundImageView: UIImageView else {
            return
        }
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.clipsToBounds = true
        contentView.insertSubview(backgroundImageView, belowSubview: visualEffectView)
        
        backgroundImageView.top.constraint(equalTo: visualEffectView.contentView.salg.top, constant: 4.0).isActive = true
        backgroundImageView.left.constraint(equalTo: visualEffectView.contentView.salg.left, constant: 4.0).isActive = true
        backgroundImageView.bottom.constraint(equalTo: visualEffectView.contentView.salg.bottom, constant: -4.0).isActive = true
        backgroundImageView.right.constraint(equalTo: visualEffectView.contentView.salg.right, constant: -4.0).isActive = true
        
        imageView = UIImageView()
        guard let imageView: UIImageView else {
            return
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        visualEffectView.contentView.addSubview(imageView)
        
        imageView.top.constraint(equalTo: visualEffectView.contentView.salg.top, constant: 4.0).isActive = true
        imageView.left.constraint(equalTo: visualEffectView.contentView.salg.left, constant: 4.0).isActive = true
        imageView.bottom.constraint(equalTo: visualEffectView.contentView.salg.bottom, constant: -4.0).isActive = true
        imageView.right.constraint(equalTo: visualEffectView.contentView.salg.right, constant: -4.0).isActive = true
        
        // let configuration: UIButton.Configuration = .glassConfiguration(.medium, .capsule, UIImage(systemName: "ellipsis"), nil, .medium)
        
        var configuration: UIButton.Configuration = .glass()
        configuration.buttonSize = .medium
        configuration.cornerStyle = .capsule
        configuration.image = UIImage(systemName: "ellipsis")?
            .applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .medium))
        
        button = UIButton(configuration: configuration)
        guard let button: UIButton else {
            return
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.showsMenuAsPrimaryAction = true
        contentView.addSubview(button)
        
        button.top.constraint(equalTo: visualEffectView.contentView.salg.bottom, constant: 8.0).isActive = true
        button.right.constraint(equalTo: contentView.salg.right).isActive = true
        
        label = UILabel()
        guard let label: UILabel else {
            return
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .bold(from: .headline)
        label.lineBreakMode = .byTruncatingMiddle
        contentView.addSubview(label)
        
        label.top.constraint(equalTo: visualEffectView.contentView.salg.bottom, constant: 8.0).isActive = true
        label.left.constraint(equalTo: contentView.salg.left).isActive = true
        label.right.constraint(equalTo: button.salg.left, constant: -8.0).isActive = true
        
        secondaryLabel = UILabel()
        guard let secondaryLabel: UILabel else {
            return
        }
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryLabel.font = .regular(from: .subheadline)
        secondaryLabel.textColor = .secondaryLabel
        contentView.addSubview(secondaryLabel)
        
        secondaryLabel.top.constraint(equalTo: label.salg.bottom, constant: 8.0).isActive = true
        secondaryLabel.left.constraint(equalTo: contentView.salg.left).isActive = true
        secondaryLabel.bottom.constraint(equalTo: contentView.salg.bottom).isActive = true
        secondaryLabel.right.constraint(equalTo: button.salg.left, constant: -8.0).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let visualEffectView: UIVisualEffectView,
              let imageView: UIImageView, let backgroundImageView: UIImageView else {
            return
        }
        
        visualEffectView.cornerConfiguration = .corners(radius: UICornerRadius.fixed(40.0))
        imageView.cornerConfiguration = .corners(radius: .fixed(36.0))
        backgroundImageView.cornerConfiguration = imageView.cornerConfiguration
        visualEffectView.layoutIfNeeded()
        imageView.layoutIfNeeded()
        backgroundImageView.layoutIfNeeded()
    }
    
    func configureCell<T>(with game: T, controller: GamesController) {}
}
