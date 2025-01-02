//
//  DefaultCell.swift
//  Folium
//
//  Created by Jarrod Norwell on 2/7/2024.
//

import Foundation
import UIKit

@MainActor class DefaultCell : UICollectionViewCell {
    var imageView: UIImageView? = nil, blurredImageView: UIImageView? = nil
    fileprivate var textLabel: UILabel? = nil
    var optionsButton: UIButton? = nil
    
    var color: UIColor? = nil
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let colors: [UIColor] = [
            .systemRed,
            .systemGreen,
            .systemBlue,
            .systemOrange,
            .systemYellow,
            .systemPink,
            .systemPurple,
            .systemTeal,
            .systemCyan,
            .systemBrown,
            .systemMint,
            .systemIndigo
        ]
        
        color = colors.randomElement()
        
        backgroundColor = color // ?.withAlphaComponent(1 / 3)
        clipsToBounds = true
        layer.borderColor = UIColor.tertiarySystemBackground.cgColor
        layer.borderWidth = 3
        layer.cornerCurve = .continuous
        layer.cornerRadius = 15
        
        blurredImageView = .init()
        guard let blurredImageView else {
            return
        }
        
        blurredImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurredImageView)
        
        blurredImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blurredImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        blurredImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        blurredImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        imageView = .init()
        guard let imageView else {
            return
        }
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        blurredImageView.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: blurredImageView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: blurredImageView.leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: blurredImageView.bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: blurredImageView.trailingAnchor).isActive = true
        
        textLabel = .init()
        guard let textLabel else {
            return
        }
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.backgroundColor = .tertiarySystemBackground
        textLabel.clipsToBounds = true
        textLabel.layer.cornerCurve = .continuous
        textLabel.numberOfLines = 3
        textLabel.textAlignment = .left
        imageView.addSubview(textLabel)
        
        textLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 16).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -16).isActive = true
        textLabel.trailingAnchor.constraint(lessThanOrEqualTo: imageView.trailingAnchor, constant: -16).isActive = true
        
        var configuration = UIButton.Configuration.tinted()
        configuration.baseBackgroundColor = .white
        configuration.baseForegroundColor = .white
        configuration.buttonSize = .small
        configuration.cornerStyle = .capsule
        configuration.image = .init(systemName: "ellipsis")?
            .applyingSymbolConfiguration(.init(weight: .bold))
        
        optionsButton = .init(configuration: configuration)
        guard let optionsButton else {
            return
        }
        
        optionsButton.translatesAutoresizingMaskIntoConstraints = false
        optionsButton.showsMenuAsPrimaryAction = true
        addSubview(optionsButton)
        
        optionsButton.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        optionsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        
        if #available(iOS 17, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], action: #selector(traitCollectionDidChange(with:traitCollection:)))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.borderColor = UIColor.tertiarySystemBackground.cgColor
        if let optionsButton, let configuration = optionsButton.configuration {
            layer.cornerRadius = configuration.background.cornerRadius + 16
            guard let textLabel else {
                return
            }
            
            textLabel.layer.cornerRadius = layer.cornerRadius / 3
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #unavailable(iOS 17) {
            backgroundColor = color
            layer.borderColor = UIColor.tertiarySystemBackground.cgColor
        }
    }
    
    @objc fileprivate func traitCollectionDidChange(with traitEnvironment: UITraitEnvironment, traitCollection: UITraitCollection) {
        backgroundColor = color
        layer.borderColor = UIColor.tertiarySystemBackground.cgColor
    }
    
    func set(text string: String, image data: Data? = nil, with color: UIColor? = nil) {
        guard let textLabel else { return }
        
        if let _ = color {
            textLabel.backgroundColor = .clear
        }
        
        let color = color ?? .tertiarySystemBackground
        if data == nil {
            textLabel.attributedText = .init(string: string, attributes: [
                .font : UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize),
                .foregroundColor: color
            ])
        } else {
            if UserDefaults.standard.bool(forKey: "folium.showGameTitles") {
                textLabel.attributedText = .init(string: string, attributes: [
                    .font : UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize),
                    .foregroundColor: color
                ])
            }
        }
        
        
        /*
        print(string, data)
        let userDefaults = UserDefaults.standard
        
        guard let textLabel else {
            return
        }
        
        if let _ = color {
            textLabel.backgroundColor = .clear
        }
        
        let color = color ?? .tertiarySystemBackground
        
        if data == nil {
            textLabel.attributedText = .init(string: string, attributes: [
                .font : UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize),
                .foregroundColor: color
            ])
        } else {
            if userDefaults.bool(forKey: "folium.showGameTitles") {
                textLabel.attributedText = .init(string: string, attributes: [
                    .font : UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize),
                    .foregroundColor: color
                ])
            } else {
                textLabel.attributedText = nil
            }
        }
         */
    }
}
