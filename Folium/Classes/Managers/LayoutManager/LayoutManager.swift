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
    
    var cheats: UICollectionViewCompositionalLayout {
        .init { sectionIndex, layoutEnvironment in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
            let group: NSCollectionLayoutGroup = if #available(iOS 16, *) {
                .horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
            } else {
                .horizontal(layoutSize: groupSize, subitem: item, count: 1)
            }
            group.interItemSpacing = .fixed(10)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
            section.interGroupSpacing = 10
            return section
        }
    }
    
    var library: UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 10
        
        return .init(sectionProvider: { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) in
            let core = Core.cores[sectionIndex]
            var missingFiles: Bool = false
            switch core {
#if canImport(Cytrus)
            case .cytrus:
                missingFiles = LibraryManager.shared.cytrusManager.library.missingFiles.contains(where: { $0.fileDetails.importance == .required })
#endif
            case .grape:
                missingFiles = LibraryManager.shared.grapeManager.library.missingFiles.contains(where: { $0.fileDetails.importance == .required })
            default:
                break
            }
            
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
                let isiPad = UIDevice.current.userInterfaceIdiom == .pad
                let columns: CGFloat = layoutEnvironment.container.effectiveContentSize.width < UIScreen.main.bounds.height ? isiPad ? 5 : 2 : isiPad ? 7 : 4
                let bottomColumns: CGFloat = layoutEnvironment.container.effectiveContentSize.width < UIScreen.main.bounds.height ? isiPad ? 6 : 3 : isiPad ? 8 : 4
                
                let isLandscape: Bool = layoutEnvironment.container.effectiveContentSize.width > UIScreen.main.bounds.height
                
                let topItem = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1 / columns), heightDimension: .estimated(300)))
                let bottomItem = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1 / (isLandscape ? bottomColumns : columns)), heightDimension: .estimated(300)))
                
                let topGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                                    heightDimension: .estimated(300)), subitem: topItem, count: Int(columns))
                topGroup.interItemSpacing = .fixed(10)
                
                let bottomGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                                       heightDimension: .estimated(300)), subitem: bottomItem, count: Int((isLandscape ? bottomColumns : columns)))
                bottomGroup.interItemSpacing = .fixed(10)
                
                let nestedGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(600)), subitems: [topGroup, bottomGroup])
                nestedGroup.interItemSpacing = .fixed(10)
                
                let section = NSCollectionLayoutSection(group: nestedGroup)
                section.boundarySupplementaryItems = [
                    .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)),
                          elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                ]
                section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
                section.interGroupSpacing = 10
                return section
                
                /*
                 let isiPad = UIDevice.current.userInterfaceIdiom == .pad
                let columns: CGFloat = layoutEnvironment.container.effectiveContentSize.width < UIScreen.main.bounds.height ? isiPad ? 5 : 2 : isiPad ? 7 : 4
                
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1 / columns),
                                                                    heightDimension: .estimated(300)))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)),
                                                               subitems: [item])
                group.interItemSpacing = .fixed(10)
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
                section.interGroupSpacing = 10
                section.boundarySupplementaryItems = [
                    .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)),
                          elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                ]
                
                return section*/
                
            }
        }, configuration: configuration)
    }
}
