//
//  ArchivingViewController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 18/8/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import AppleArchive
import Foundation
import System
import UIKit

protocol ArchivingDelegate {
    func archivingDidFinish()
}

class ArchivingViewController : UIViewController {
    var delegate: ArchivingDelegate? = nil
    var currentlyInstalledVersion: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        activityIndicatorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -10).isActive = true
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = .init(string: "Archiving", attributes: [
            .font : UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize),
            .foregroundColor : UIColor.label
        ])
        view.addSubview(label)
        
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 10).isActive = true
        label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        
        do {
            try startArchivalProcess {
                guard let delegate = self.delegate else {
                    return
                }
                
                delegate.archivingDidFinish()
            }
        } catch {
            print(#function, error, error.localizedDescription)
        }
    }
    
    func startArchivalProcess(_ completion: @escaping () -> Void) throws {
        guard let currentlyInstalledVersion else {
            return
        }
        
        let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let backupDirectory = documentDirectory.appending(path: currentlyInstalledVersion)
        try FileManager.default.createDirectory(at: backupDirectory, withIntermediateDirectories: false)
        
        let contents = try FileManager.default.contentsOfDirectory(atPath: documentDirectory.path)
        
        let cores = LibraryManager.shared.cores.reduce(into: [String]()) { partialResult, element in
            partialResult.append(element.description)
        }
        
        let filtered = contents.filter { content in
            cores.contains(content)
        }
        
        try filtered.forEach { content in
            try FileManager.default.moveItem(at: documentDirectory.appending(path: content),
                                             to: backupDirectory.appending(path: content))
        }
        
        let temporary = NSTemporaryDirectory() + "\(currentlyInstalledVersion).aar"
        let archivePath = FilePath(temporary)
        
        guard let writeFileStream = ArchiveByteStream.fileStream(path: archivePath,
                                                                 mode: .writeOnly,
                                                                 options: [
                                                                    .create,
                                                                 ],
                                                                 permissions: .init(rawValue: 0o644)) else {
            return
        }
        
        defer {
            try? writeFileStream.close()
        }
        
        guard let compressStream = ArchiveByteStream.compressionStream(using: .lzfse,
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
        
        guard let source = FilePath(backupDirectory) else {
            return
        }

        try encodeStream.writeDirectoryContents(archiveFrom: source, keySet: keySet)
        
        try FileManager.default.moveItem(atPath: temporary,
                                         toPath: documentDirectory.appending(path: "\(currentlyInstalledVersion).aar").path)
        
        try FileManager.default.removeItem(at: backupDirectory)
        
        completion()
    }
}
