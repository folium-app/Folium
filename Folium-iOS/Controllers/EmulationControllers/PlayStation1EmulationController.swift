//
//  PlayStation1EmulationController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 29/7/2024.
//

import Foundation
// import Lychee
import UIKit

class PlayStation1EmulationController : UIViewController {
    var imageView: UIImageView? = nil
    
    var game: PlayStation1Game
    init(game: PlayStation1Game) {
        self.game = game
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        imageView = .init(frame: .zero)
        guard let imageView else {
            return
        }
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.widthAnchor, multiplier: 3 / 4).isActive = true
    }
}
