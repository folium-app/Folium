//
//  ScanningController.swift
//  Folium
//
//  Created by Jarrod Norwell on 16/5/2024.
//

import Foundation
import UIKit

class ScanningController : UIViewController {
    fileprivate var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.color = .secondarySystemBackground
        view.addSubview(activityIndicatorView)
        
        view.addConstraints([
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        do {
            activityIndicatorView.startAnimating()
            
            try DirectoryManager.shared.createMissingDirectoriesInDocumentsDirectory()
            try LibraryManager.shared.library()
            Core.cores.forEach { core in
                DirectoryManager.shared.scanDirectoriesForRequiredFiles(core)
            }
            
            activityIndicatorView.stopAnimating()
            
            let libraryController = UINavigationController(rootViewController: LibraryController(collectionViewLayout: LayoutManager.shared.library))
            libraryController.modalPresentationStyle = .fullScreen
            let this = self
            dismiss(animated: true) {
                this.present(libraryController, animated: true)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
