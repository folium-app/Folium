//
//  TomatoSkinController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 15/9/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation
import SpriteKit
import Tomato
import UIKit

class TomatoSkinController : SkinController {
    let tomato = Tomato.shared
    
    var imageView: UIImageView? = nil
    var vbuf = [UInt32](repeating: 0xF8F8F8, count: 160 * 144)
    var abuf = [UInt32](repeating: 0, count: 160 * 144)
    
    override init(game: GameBase, skin: Skin) {
        super.init(game: game, skin: skin)
        tomato.insert(cartridge: game.fileDetails.url)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = .init()
        guard let imageView else {
            return
        }
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 3 / 4).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        while true {
            step()
        }
    }
    
    @objc func step() {
       //  guard let imageView else {
       //      return
       //  }
       //
       //  let diff = tomato.tomatoObjC.step(&vbuf, audio: &abuf)
       //
       //  guard let cgImage = CGImage.gambatteImage(from: vbuf) else {
       //      return
       //  }
       //
       //  Task {
       //      imageView.image = .init(cgImage: cgImage)
       //  }
    }
}
