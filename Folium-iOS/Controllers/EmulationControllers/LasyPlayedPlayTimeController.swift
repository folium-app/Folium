//
//  LasyPlayedPlayTimeController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 13/11/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation
import UIKit
import WidgetKit

struct User : Codable {
    struct Game : Codable {
        var console: String = ""
        var icon: Data? = nil
        let sha256: String
        var lastPlayed, playTime: TimeInterval
    }
    
    var games: [Game]
    let name: String
    
    mutating func updateGame(console: String, sha256: String, with lastPlayed: TimeInterval = 0,
                             and playTime: TimeInterval = 0, icon: Data? = nil) {
        if let index = games.firstIndex(where: { $0.sha256 == sha256 }) {
            games[index].icon = icon
            games[index].lastPlayed = lastPlayed
            games[index].playTime += playTime
        } else {
            games.append(.init(console: console, icon: icon, sha256: sha256, lastPlayed: lastPlayed, playTime: playTime))
        }
    }
}

class LastPlayedPlayTimeController : UIViewController {
    var time: TimeInterval = 0
    var timer: Timer? = nil
    
    var game: GameBase
    init(game: GameBase) {
        self.game = game
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = .scheduledTimer(withTimeInterval: 1, repeats: true) { _ in self.time += 1 }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let timer { timer.invalidate() }
        
        let icon: Data? = switch game {
        case let grapeGame as GrapeGame:
            if let cgImage = CGImage.cgImage(grapeGame.icon, 32, 32) {
                UIImage(cgImage: cgImage).pngData()
            } else {
                nil
            }
        case let cytrusGame as CytrusGame: cytrusGame.icon
        case let lycheeGame as LycheeGame: lycheeGame.data
        case let playStation2Game as PlayStation2Game: playStation2Game.iconData
        case let mangoGame as MangoGame: mangoGame.data
        default:
            nil
        }
        
        let user = Auth.auth().currentUser
        let userDefaults = UserDefaults(suiteName: "group.com.antique.Folium")
        let sha256 = game.fileDetails.sha256
        
        Task {
            if AppStoreCheck.shared.additionalFeaturesAreAllowed, let user {
                if let sha256 {
                    let document = Firestore.firestore().collection("users").document(user.uid)
                    var user = try await document.getDocument(as: User.self)
                    user.updateGame(console: game.core, sha256: sha256, with: Date.now.timeIntervalSince1970, and: self.time, icon: icon)
                    
                    try document.setData(from: user, merge: true)
                    
                    if let userDefaults {
                        userDefaults.set(try JSONEncoder().encode(user), forKey: "user")
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
            }
        }
    }
}
