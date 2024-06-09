//
//  LayoutManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 16/5/2024.
//

import Foundation
import UIKit

class LayoutManager {
    static let shared = LayoutManager()
    
    var library: UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 10
        
        return .init(sectionProvider: { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) in
            let core = Core.cores[sectionIndex]
            var missingFiles: Bool = false
            switch core {
            case .cytrus:
                missingFiles = LibraryManager.shared.cytrusManager.library.missingFiles.contains(where: { $0.fileDetails.importance == .required })
            case .grape:
                missingFiles = LibraryManager.shared.grapeManager.library.missingFiles.contains(where: { $0.fileDetails.importance == .required })
            default:
                break
            }
            
            let isiPad = UIDevice.current.userInterfaceIdiom == .pad
            let columns: CGFloat = layoutEnvironment.container.effectiveContentSize.width < UIScreen.main.bounds.height ? missingFiles ? 1 : isiPad ? 4 : 2 : missingFiles ? 2 : isiPad ? 6 : 4
            
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1 / columns),
                                                                heightDimension: .estimated(300)))
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)),
                                                           subitems: [item])
            group.interItemSpacing = .fixed(10)
            
            if missingFiles {
                var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                configuration.backgroundColor = .secondarySystemBackground
                
                let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
                section.boundarySupplementaryItems = [
                    .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)),
                          elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                ]
                
                return section
            } else {
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
                section.interGroupSpacing = 10
                section.boundarySupplementaryItems = [
                    .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)),
                          elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                ]
                
                return section
            }
        }, configuration: configuration)
    }
}
