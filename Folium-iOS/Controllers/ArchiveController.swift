//
//  ArchiveController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 8/9/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import AppleArchive
import FirebaseAuth
import Foundation
import LayoutManager
import System
import UIKit

class ArchiveController : UIViewController {
    var textLabel: UILabel? = nil
    var activityIndicatorView: UIActivityIndicatorView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        activityIndicatorView = .init(style: .medium)
        guard let activityIndicatorView else {
            return
        }
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        textLabel = .init()
        guard let textLabel else {
            return
        }
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.attributedText = .init(string: "Archiving", attributes: [
            .font : UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize),
            .foregroundColor : UIColor.label
        ])
        view.addSubview(textLabel)
        
        textLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        textLabel.topAnchor.constraint(equalTo: activityIndicatorView.safeAreaLayoutGuide.bottomAnchor, constant: 8).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        do {
            let documentsDirectory = try FileManager.default.url(for: .documentDirectory,
                                                                 in: .userDomainMask,
                                                                 appropriateFor: nil,
                                                                 create: false)
            
            let archiveDestination = NSTemporaryDirectory() + "archive.aar"
            let archiveFilePath = FilePath(archiveDestination)


            guard let writeFileStream = ArchiveByteStream.fileStream(
                    path: archiveFilePath,
                    mode: .writeOnly,
                    options: [ .create ],
                    permissions: FilePermissions(rawValue: 0o644)) else {
                return
            }
            
            defer {
                try? writeFileStream.close()
            }
            
            guard let compressStream = ArchiveByteStream.compressionStream(
                    using: .lzfse,
                    writingTo: writeFileStream) else {
                return
            }
            
            defer {
                try? compressStream.close()
            }
            
            guard let encodeStream = ArchiveStream.encodeStream(writingTo: compressStream) else {
                return
            }
            
            defer {
                try? encodeStream.close()
            }
            
            guard let keySet = ArchiveHeader.FieldKeySet("TYP,PAT,LNK,DEV,DAT,UID,GID,MOD,FLG,MTM,BTM,CTM") else {
                return
            }
            
            let source = FilePath(documentsDirectory.path)

            try encodeStream.writeDirectoryContents(
                archiveFrom: source,
                keySet: keySet)
            
            try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil).forEach {
                try FileManager.default.removeItem(at: $0)
            }
            
            if let window = view.window, let windowScene = window.windowScene, let delegate = windowScene.delegate as? SceneDelegate {
                try delegate.configureMissingDirectories(for: LibraryManager.shared.cores.map { $0.rawValue })
            }
            
            let aarURL = if #available(iOS 16, *) {
                documentsDirectory.appending(component: "archive.aar")
            } else {
                documentsDirectory.appendingPathComponent("archive.aar")
            }
            
            try FileManager.default.moveItem(atPath: archiveDestination, toPath: aarURL.path)
        } catch {}
        
        let viewController = if AppStoreCheck.shared.additionalFeaturesAreAllowed {
            if Auth.auth().currentUser == nil, !UserDefaults.standard.bool(forKey: "userSkippedAuthentication") {
                AuthenticationController()
            } else {
                UINavigationController(rootViewController: LibraryController(collectionViewLayout: LayoutManager.shared.library))
            }
        } else {
            UINavigationController(rootViewController: LibraryController(collectionViewLayout: LayoutManager.shared.library))
        }
        
        UserDefaults.standard.set(true, forKey: "shouldShowArchived")
        
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
}
