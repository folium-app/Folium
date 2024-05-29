//
//  VirtualControllerButtonDelegate.swift
//  Folium
//
//  Created by Jarrod Norwell on 7/2/2024.
//

import Foundation

protocol VirtualControllerButtonDelegate {
    func touchDown(_ buttonType: VirtualControllerButton.ButtonType)
    func touchDragInside(_ buttonType: VirtualControllerButton)
    func touchUpInside(_ buttonType: VirtualControllerButton.ButtonType)
}
