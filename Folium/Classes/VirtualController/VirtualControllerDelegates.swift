//
//  VirtualControllerButtonDelegate.swift
//  Folium
//
//  Created by Jarrod Norwell on 7/2/2024.
//

import Foundation

protocol VirtualControllerButtonDelegate {
    func touchDown(_ buttonType: VirtualControllerButton.ButtonType)
    func touchUpInside(_ buttonType: VirtualControllerButton.ButtonType)
}

protocol VirtualControllerThumbstickDelegate {
    func touchDown(_ thumbstickType: VirtualControllerThumbstick.ThumbstickType, _ location: (x: Float, y: Float))
    func touchDragInside(_ thumbstickType: VirtualControllerThumbstick.ThumbstickType, _ location: (x: Float, y: Float))
    func touchUpInside(_ thumbstickType: VirtualControllerThumbstick.ThumbstickType, _ location: (x: Float, y: Float))
}
