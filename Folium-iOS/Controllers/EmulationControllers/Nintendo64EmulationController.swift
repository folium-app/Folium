//
//  Nintendo64EmulationController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 23/7/2024.
//

import Foundation
import SDL
import UIKit

typealias GuavaAudioCallback = @convention(c)(UnsafeMutableRawPointer?, UnsafeMutablePointer<UInt8>?, Int32) -> Void
@MainActor class Nintendo64EmulationController : UIViewController {
    //let guava = Guava.shared
    
    fileprivate var audioDeviceID: SDL_AudioDeviceID!
    
    init(game: Nintendo64Game) {
        super.init(nibName: nil, bundle: nil)
        //guava.insertCartridge(from: game.fileDetails.url)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        imageView = UIImageView(frame: UIScreen.main.bounds)
        view.addSubview(imageView)
        
        configureAudio()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(run))
        displayLink.preferredFrameRateRange = .init(minimum: 30, maximum: 60)
        displayLink.add(to: .main, forMode: .common)
    }
    
    @objc func run() {
        /*
        while true {
            guava.start()
            guava.videoBuffer { data, width, height in
                guard let cgImage = CGImage.cgImage(data, Int(width), Int(height)) else {
                    return
                }
                
                print(width, height)
                
                Task {
                    self.imageView.image = .init(cgImage: cgImage)
                }
            }
        }
         */
    }
    
    fileprivate func configureAudio() {
        SDL_SetMainReady()
        SDL_InitSubSystem(SDL_INIT_AUDIO)
        
        let callback: GuavaAudioCallback = { userdata, stream, len in
            // guard let userdata else {
            //     return
            // }
            
            // let viewController = Unmanaged<Nintendo64EmulationController>.fromOpaque(userdata).takeUnretainedValue()
            // SDL_memcpy(stream, viewController.guava.audioBuffer(), Int(len))
        }
        
        var spec = SDL_AudioSpec()
        spec.callback = callback
        spec.userdata = Unmanaged.passUnretained(self).toOpaque()
        spec.channels = 2
        spec.format = SDL_AudioFormat(AUDIO_S16)
        spec.freq = 48000
        spec.samples = 1024
        
        audioDeviceID = SDL_OpenAudioDevice(nil, 0, &spec, nil, 0)
        SDL_PauseAudioDevice(audioDeviceID, 0)
    }
}
