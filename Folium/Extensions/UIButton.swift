//
//  UIButton.swift
//  Folium
//
//  Created by Jarrod Norwell on 17/6/2024.
//

import Foundation
import UIKit

@available(iOS 17, *)
extension UIButton {
    private var imageView: UIImageView? {
        return subviews.first(where: { $0.isKind(of: UIImageView.self) }) as? UIImageView
    }

    func addSymbolEffect(_ effect: some IndefiniteSymbolEffect & SymbolEffect, options: SymbolEffectOptions = .default, animated: Bool = true, completion: UISymbolEffectCompletion? = nil) {
        imageView?.addSymbolEffect(effect, options: options, animated: animated, completion: completion)
    }

    func addSymbolEffect(_ effect: some DiscreteSymbolEffect & IndefiniteSymbolEffect & SymbolEffect, options: SymbolEffectOptions = .default, animated: Bool = true, completion: UISymbolEffectCompletion? = nil) {
        imageView?.addSymbolEffect(effect, options: options, animated: animated, completion: completion)
    }

    func addSymbolEffect(_ effect: some DiscreteSymbolEffect & SymbolEffect, options: SymbolEffectOptions = .default, animated: Bool = true, completion: UISymbolEffectCompletion? = nil) {
        imageView?.addSymbolEffect(effect, options: options, animated: animated, completion: completion)
    }

    func removeSymbolEffect(ofType effect: some IndefiniteSymbolEffect & SymbolEffect, options: SymbolEffectOptions = .default, animated: Bool = true, completion: UISymbolEffectCompletion? = nil) {
        imageView?.removeSymbolEffect(ofType: effect, options: options, animated: animated, completion:  completion)
    }

    func removeSymbolEffect(ofType effect: some DiscreteSymbolEffect & IndefiniteSymbolEffect & SymbolEffect, options: SymbolEffectOptions = .default, animated: Bool = true, completion: UISymbolEffectCompletion? = nil) {
        imageView?.removeSymbolEffect(ofType: effect, options: options, animated: animated, completion:  completion)
    }

    func removeSymbolEffect(ofType effect: some DiscreteSymbolEffect & SymbolEffect, options: SymbolEffectOptions = .default, animated: Bool = true, completion: UISymbolEffectCompletion? = nil) {
        imageView?.removeSymbolEffect(ofType: effect, options: options, animated: animated, completion:  completion)
    }

    func removeAllSymbolEffects(options: SymbolEffectOptions = .default, animated: Bool = true) {
        imageView?.removeAllSymbolEffects(options: options, animated: animated)
    }
}
