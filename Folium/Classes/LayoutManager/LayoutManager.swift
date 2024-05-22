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
            // let core = Core.cores[sectionIndex]
            
            let columns: CGFloat = layoutEnvironment.container.effectiveContentSize.width < UIScreen.main.bounds.height ? 2 : 4
            
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
            
            return section
        }, configuration: configuration)
    }
}
