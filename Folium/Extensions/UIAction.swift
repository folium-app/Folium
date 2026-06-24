//
//  UIAction.swift
//  Folium
//
//  Created by Jarrod Norwell on 25/6/2026.
//

import Foundation
import UIKit

typealias AsyncUIActionHandler = (UIAction) async -> Void
typealias AsyncThrowingUIActionHandler = (UIAction) async throws -> Void
typealias ThrowingUIActionHandler = (UIAction) throws -> Void

extension UIAction {
    static func async(title: String = "", image: UIImage? = nil,
                      identifier: UIAction.Identifier? = nil, discoverabilityTitle: String? = nil,
                      attributes: UIMenuElement.Attributes = [], state: UIMenuElement.State = .off, handler: @escaping AsyncUIActionHandler) -> UIAction {
        UIAction(title: title, image: image,
                 identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                 attributes: attributes, state: state) { action in
            Task {
                await handler(action)
            }
        }
    }

    static func async(title: String = "", subtitle: String? = nil, image: UIImage? = nil,
                      identifier: UIAction.Identifier? = nil, discoverabilityTitle: String? = nil,
                      attributes: UIMenuElement.Attributes = [], state: UIMenuElement.State = .off, handler: @escaping AsyncUIActionHandler) -> UIAction {
        UIAction(title: title, subtitle: subtitle, image: image,
                 identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                 attributes: attributes, state: state) { action in
            Task {
                await handler(action)
            }
        }
    }

    @available(iOS 17, *)
    static func async(title: String = "", subtitle: String? = nil, image: UIImage? = nil, selectedImage: UIImage? = nil,
                      identifier: UIAction.Identifier? = nil, discoverabilityTitle: String? = nil,
                      attributes: UIMenuElement.Attributes = [], state: UIMenuElement.State = .off, handler: @escaping AsyncUIActionHandler) -> UIAction {
        UIAction(title: title, subtitle: subtitle, image: image, selectedImage: selectedImage,
                 identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                 attributes: attributes, state: state) { action in
            Task {
                await handler(action)
            }
        }
    }
    
    static func asyncThrowing(title: String = "", image: UIImage? = nil,
                              identifier: UIAction.Identifier? = nil, discoverabilityTitle: String? = nil,
                              attributes: UIMenuElement.Attributes = [], state: UIMenuElement.State = .off, handler: @escaping AsyncThrowingUIActionHandler) -> UIAction {
        UIAction(title: title, image: image,
                 identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                 attributes: attributes, state: state) { action in
            _ = Task {
                try await handler(action)
            }
        }
    }

    static func asyncThrowing(title: String = "", subtitle: String? = nil, image: UIImage? = nil,
                              identifier: UIAction.Identifier? = nil, discoverabilityTitle: String? = nil,
                              attributes: UIMenuElement.Attributes = [], state: UIMenuElement.State = .off, handler: @escaping AsyncThrowingUIActionHandler) -> UIAction {
        UIAction(title: title, subtitle: subtitle, image: image,
                 identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                 attributes: attributes, state: state) { action in
            _ = Task {
                try await handler(action)
            }
        }
    }

    @available(iOS 17, *)
    static func asyncThrowing(title: String = "", subtitle: String? = nil, image: UIImage? = nil, selectedImage: UIImage? = nil,
                              identifier: UIAction.Identifier? = nil, discoverabilityTitle: String? = nil,
                              attributes: UIMenuElement.Attributes = [], state: UIMenuElement.State = .off, handler: @escaping AsyncThrowingUIActionHandler) -> UIAction {
        UIAction(title: title, subtitle: subtitle, image: image, selectedImage: selectedImage,
                 identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                 attributes: attributes, state: state) { action in
            _ = Task {
                try await handler(action)
            }
        }
    }
    
    static func throwing(title: String = "", image: UIImage? = nil,
                              identifier: UIAction.Identifier? = nil, discoverabilityTitle: String? = nil,
                              attributes: UIMenuElement.Attributes = [], state: UIMenuElement.State = .off, handler: @escaping ThrowingUIActionHandler) -> UIAction {
        UIAction(title: title, image: image,
                 identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                 attributes: attributes, state: state) { action in
            _ = Task {
                try handler(action)
            }
        }
    }

    static func throwing(title: String = "", subtitle: String? = nil, image: UIImage? = nil,
                              identifier: UIAction.Identifier? = nil, discoverabilityTitle: String? = nil,
                              attributes: UIMenuElement.Attributes = [], state: UIMenuElement.State = .off, handler: @escaping ThrowingUIActionHandler) -> UIAction {
        UIAction(title: title, subtitle: subtitle, image: image,
                 identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                 attributes: attributes, state: state) { action in
            _ = Task {
                try handler(action)
            }
        }
    }

    @available(iOS 17, *)
    static func throwing(title: String = "", subtitle: String? = nil, image: UIImage? = nil, selectedImage: UIImage? = nil,
                              identifier: UIAction.Identifier? = nil, discoverabilityTitle: String? = nil,
                              attributes: UIMenuElement.Attributes = [], state: UIMenuElement.State = .off, handler: @escaping ThrowingUIActionHandler) -> UIAction {
        UIAction(title: title, subtitle: subtitle, image: image, selectedImage: selectedImage,
                 identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                 attributes: attributes, state: state) { action in
            _ = Task {
                try handler(action)
            }
        }
    }
}

