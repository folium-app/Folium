//
//  MTKCallbackView.swift
//  Folium
//
//  Created by Jarrod Norwell on 22/4/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Foundation
import MetalKit

class MTKCallbackView : MTKView {
    var callback: (() -> Void)? = nil
    
    override init(frame frameRect: CGRect, device: (any MTLDevice)?) {
        super.init(frame: frameRect, device: device)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw() {
        super.draw()
        if let callback { callback() }
    }
}
