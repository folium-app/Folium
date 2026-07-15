//
//  LayoutManager.swift
//  Folium
//
//  Created by Jarrod Norwell on 17/6/2026.
//

import UIKit

struct LayoutManager {
    static let shared: LayoutManager = LayoutManager()
    
    var library: UICollectionViewCompositionalLayout {
        let configuration: UICollectionViewCompositionalLayoutConfiguration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 20.0
        
        return UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, layoutEnvironment in
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                iPadLibrary(layoutEnvironment: layoutEnvironment, sectionIndex: sectionIndex)
            case .phone:
                iPhoneLibrary(layoutEnvironment: layoutEnvironment, sectionIndex: sectionIndex)
            default:
                nil
            }
        }, configuration: configuration)
    }
    
    func iPadLibrary(layoutEnvironment: NSCollectionLayoutEnvironment, sectionIndex: Int) -> NSCollectionLayoutSection? {
        let itemCount: Int = layoutEnvironment.container.effectiveContentSize.width < layoutEnvironment.container.effectiveContentSize.height ? 5 : 6
        
        let boundaryItemFullWidthSize: NSCollectionLayoutSize = NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.fractionalWidth(1.0),
                                                                                       heightDimension: NSCollectionLayoutDimension.estimated(44.0))
        let itemSize: NSCollectionLayoutSize = NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.fractionalWidth(1.0 / CGFloat(itemCount)),
                                                                      heightDimension: NSCollectionLayoutDimension.estimated(300.0))
        let itemFullWidthSize: NSCollectionLayoutSize = NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.fractionalWidth(1.0),
                                                                               heightDimension: NSCollectionLayoutDimension.estimated(300.0))
        
        let item: NSCollectionLayoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group: NSCollectionLayoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: itemFullWidthSize,
                                                                                repeatingSubitem: item,
                                                                                count: itemCount)
        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(20.0)
        
        let header: NSCollectionLayoutBoundarySupplementaryItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundaryItemFullWidthSize,
                                                                                                              elementKind: UICollectionView.elementKindSectionHeader,
                                                                                                              alignment: .top)
        header.pinToVisibleBounds = true
        
        let section: NSCollectionLayoutSection = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.contentInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 20.0, bottom: 20.0, trailing: 20.0)
        section.interGroupSpacing = 20.0
        
        return section
    }
    
    func iPhoneLibrary(layoutEnvironment: NSCollectionLayoutEnvironment, sectionIndex: Int) -> NSCollectionLayoutSection? {
        let itemCount: Int = layoutEnvironment.container.effectiveContentSize.width < layoutEnvironment.container.effectiveContentSize.height ? 2 : 4
        
        let boundaryItemFullWidthSize: NSCollectionLayoutSize = NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.fractionalWidth(1.0),
                                                                                       heightDimension: NSCollectionLayoutDimension.estimated(44.0))
        let itemSize: NSCollectionLayoutSize = NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.fractionalWidth(1.0 / CGFloat(itemCount)),
                                                                      heightDimension: NSCollectionLayoutDimension.estimated(300.0))
        let itemFullWidthSize: NSCollectionLayoutSize = NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.fractionalWidth(1.0),
                                                                               heightDimension: NSCollectionLayoutDimension.estimated(300.0))
        
        let item: NSCollectionLayoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group: NSCollectionLayoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: itemFullWidthSize,
                                                                                repeatingSubitem: item,
                                                                                count: itemCount)
        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(20.0)
        
        let header: NSCollectionLayoutBoundarySupplementaryItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundaryItemFullWidthSize,
                                                                                                              elementKind: UICollectionView.elementKindSectionHeader,
                                                                                                              alignment: .top)
        header.pinToVisibleBounds = false
        
        let section: NSCollectionLayoutSection = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.contentInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 20.0, bottom: 20.0, trailing: 20.0)
        section.interGroupSpacing = 20.0
        
        return section
    }
}
