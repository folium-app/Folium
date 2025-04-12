//
//  Nintendo64EmulationController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 23/7/2024.
//

//import Guava
import Foundation
import UIKit

typealias GuavaAudioCallback = @convention(c)(UnsafeMutableRawPointer?, UnsafeMutablePointer<UInt8>?, Int32) -> Void
@MainActor class Nintendo64EmulationController : UIViewController {
    // let guava = Guava.shared
    
    // fileprivate var audioDeviceID: SDL_AudioDeviceID!
    
    init(game: Nintendo64Game) {
        super.init(nibName: nil, bundle: nil)
        //guava.insert(cartridge: game.fileDetails.url)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var imageView: UIImageView? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        imageView = UIImageView(frame: .zero)
        guard let imageView else { return }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 3 / 4).isActive = true
        
        // Guava.shared.abgr8888 { framebuffer, width, height in
        //     guard let cgImage = self.createUIImage(from: framebuffer, width: .init(width), height: .init(height), bytesPerRow: .init(width) * MemoryLayout<UInt8>.size) else { return }
        //     Task {
        //         imageView.image = cgImage
        //     }
        // }
        
        // Guava.shared.rgba5551 { framebuffer, width, height in
        //     guard let cgImage = CGImage.cgImage16(framebuffer, .init(width), .init(height)) else { return }
        //     Task {
        //         imageView.image = .init(cgImage: cgImage)
        //     }
        // }
        
        let displayLink = CADisplayLink(target: self, selector: #selector(step))
        displayLink.preferredFrameRateRange = .init(minimum: 30, maximum: 60)
        displayLink.add(to: .main, forMode: .common)
    }
    
    @objc func step() {
        // guava.step()
    }
    
    func createUIImage(from pointer: UnsafePointer<UInt8>, width: Int, height: Int, bytesPerRow: Int) -> UIImage? {
        let data = Data(bytes: pointer, count: height * bytesPerRow)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let provider = CGDataProvider(data: data as CFData) else { return nil }
        
        guard let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        ) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
