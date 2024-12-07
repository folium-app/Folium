// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import UIKit

public struct LayoutManager {
    public static let shared = LayoutManager()
    
    public var library: UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 10
        
        return .init(sectionProvider: { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) in
            let isiPad = UIDevice.current.userInterfaceIdiom == .pad
            let columns: CGFloat = layoutEnvironment.container.effectiveContentSize.width < UIScreen.main.bounds.height ? isiPad ? 4 : 2 : isiPad ? 6 : 4
            let bottomColumns: CGFloat = layoutEnvironment.container.effectiveContentSize.width < UIScreen.main.bounds.height ? isiPad ? 5 : 3 : isiPad ? 7 : 4
            
            let isLandscape: Bool = layoutEnvironment.container.effectiveContentSize.width > UIScreen.main.bounds.height
            
            let topItem = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1 / columns), heightDimension: .estimated(300)))
            let bottomItem = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1 / (isLandscape ? bottomColumns : columns)), heightDimension: .estimated(300)))
            
            let topGroup: NSCollectionLayoutGroup = if #available(iOS 16, *) {
                .horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)),
                            repeatingSubitem: topItem, count: Int(columns))
            } else {
                .horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)),
                            subitem: topItem, count: Int(columns))
            }
            topGroup.interItemSpacing = .fixed(10)
            
            let bottomGroup: NSCollectionLayoutGroup = if #available(iOS 16, *) {
                .horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)),
                            repeatingSubitem: bottomItem, count: Int(isLandscape ? bottomColumns : columns))
            } else {
                .horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)),
                            subitem: bottomItem, count: Int(isLandscape ? bottomColumns : columns))
            }
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
        }, configuration: configuration)
    }
}
