//
//  GameBoyEmulationController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 15/9/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation
import SpriteKit
import Tomato
import UIKit

class GameBoyEmulationController : UIViewController {
    let tomato = Tomato.shared
    
    var scene: SKScene? = nil
    var node: SKSpriteNode? = nil
    
    var game: GameBoyGame
    var skin: Skin
    init(game: GameBoyGame, skin: Skin) {
        self.game = game
        self.skin = skin
        super.init(nibName: nil, bundle: nil)
        tomato.insertCartridge(from: game.fileDetails.url)
    }
    
    override func loadView() {
        view = SKView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene = .init(size: view.frame.size)
        guard let scene else {
            return
        }
        
        node = .init()
        guard let node else {
            return
        }
        
        node.position = CGPoint(x: view.frame.size.width * 0.5,
                                y: view.frame.size.height * 0.5)
        
        scene.addChild(node)
        (view as! SKView).presentScene(scene)
        
        tomato.tomatoObjC.buffers = { _, videoBuffer in
            let texture = self.createTexture(from: videoBuffer)
            texture.preload {
                node.texture = texture
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        Thread.detachNewThread(step)
    }
    
    @objc func step() {
        tomato.loop()
    }
    
    public func createTexture(from buffer: UnsafeMutablePointer<UInt32>) -> SKTexture {
            
            let size = CGSize(width: 160,
                              height: 144)
            let data = createData(from: buffer)
            let texture = SKTexture(data: data, size: size, flipped: true)
            texture.filteringMode = .nearest
            return texture
        }
        
        fileprivate func createData(from buffer: UnsafeMutablePointer<UInt32>) -> Data {
            
            let count = Int(160 * 144) * MemoryLayout<UInt32>.size
            let bufferPointer =  UnsafeBufferPointer(start: buffer, count: count)
            return Data(buffer: bufferPointer)
        }
}
