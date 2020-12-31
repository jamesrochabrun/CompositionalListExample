//
//  CompositionalLayout.swift
//  FlexibleList
//
//  Created by James Rochabrun on 12/30/20.
//

import Foundation
import UIKit

extension UITraitCollection {
    
    var isRegularWidthRegularHeight: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
}

// MARK:- Helper Models
enum ScrollAxis {
    case vertical
    case horizontal(UICollectionLayoutSectionOrthogonalScrollingBehavior)
}

enum VerticalRectanglePosition: CaseIterable {
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
}

struct LayoutDimension {
    let itemWidth: (regularWidthHeight: CGFloat, compact: CGFloat)
    let itemInset: (regularWidthHeight: UIEdgeInsets, compact: UIEdgeInsets)
    let sectionInset: (regularWidthHeight: UIEdgeInsets, compact: UIEdgeInsets)
}

// MARK:- Master Layouts
extension UICollectionViewCompositionalLayout {
    
    // MARK:- Home Master Layout
    
    static func homeLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let insets = NSDirectionalEdgeInsets.all(1.0)
            let groupsFraction: CGFloat = 5.0 // needs to be equal of numbers of final grouped items
            /// PART 1
            let firstGroup = NSCollectionLayoutGroup.mainContentTopLeadingWith(insets, fraction: groupsFraction)
            /// PART 2
            let secondGroup = NSCollectionLayoutGroup.mainContentTopTrailingWith(insets, fraction: groupsFraction)
            /// PART3
            let thirdGroup = NSCollectionLayoutGroup.mainContentBottomLeadingWith(insets, fraction: groupsFraction)
        
            let fourdGroup = NSCollectionLayoutGroup.mainContentBottomTrailingWith(insets, fraction: groupsFraction)
            
            let fifthGroup = NSCollectionLayoutGroup.mainContentVerticalRectangle(insets, fraction: groupsFraction, rectanglePosition: .bottomLeading)
            
            /// FINAL GROUP
            let nestedSubGroups = [firstGroup, secondGroup, thirdGroup, fourdGroup, fifthGroup]
            let nestedSubGroupsCount = CGFloat(nestedSubGroups.count)
            
            let finalNestedGroup = NSCollectionLayoutGroup.vertical(
             layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .fractionalWidth(nestedSubGroupsCount)),
             subitems: nestedSubGroups)
            
            let isVertical = layoutEnvironment.container.contentSize.height > layoutEnvironment.container.contentSize.width

            let section = isVertical ? NSCollectionLayoutSection(group: finalNestedGroup) : UICollectionViewCompositionalLayout.grid(3)
            
            let headerSize: CGFloat = layoutEnvironment.traitCollection.isRegularWidthRegularHeight ? 300.0 : 220.0
            
            let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                          heightDimension: .estimated(headerSize))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerFooterSize,
                elementKind:  UICollectionView.elementKindSectionHeader, alignment: .top)
            
            /// we only want to add a header on the first section
            if sectionIndex == 0 {
              //  section.boundarySupplementaryItems = [sectionHeader]
            }
            return sectionIndex == 0 ? Self.createSingleListSection() : section
        }
        return layout
    }
    
    static private func createSingleListSection() -> NSCollectionLayoutSection {
        // 2
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        // 3
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
        // 4
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                     heightDimension: .estimated(250))
        // 5
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize,
                                                             subitems: [layoutItem])
            
        // 6
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        
        // 7
        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
            
        return layoutSection
    }
    
    // MARK:- Search Master Layout
    
    static func searchLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let groupsFraction: CGFloat = 2.0 // needs to be equal of numbers of final grouped items
            let insets = NSDirectionalEdgeInsets.all(1.0)
            /// PART 1
            let firstGroup = NSCollectionLayoutGroup.mainContentTopTrailingWith(insets, fraction: groupsFraction)
            /// PART 2
            let secondGroup = NSCollectionLayoutGroup.mainContentTopLeadingWith(insets, fraction: groupsFraction)
            
            /// FINAL GROUP
            let nestedSubGroups = [firstGroup, secondGroup]
            let nestedSubGroupsCount = CGFloat(nestedSubGroups.count)
            
            let finalNestedGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalWidth(nestedSubGroupsCount)),
                subitems: nestedSubGroups)
            
            let isVertical = layoutEnvironment.container.contentSize.height > layoutEnvironment.container.contentSize.width

            /// handles layout on device rotation
            let section = isVertical ? NSCollectionLayoutSection(group: finalNestedGroup) : UICollectionViewCompositionalLayout.grid(3)
                        
            let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                          heightDimension: .estimated(180.0))
            
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerFooterSize,
                elementKind:  UICollectionView.elementKindSectionHeader, alignment: .top)
            
            /// we only want to add a header on the first section
            if sectionIndex == 0 {
                section.boundarySupplementaryItems = [sectionHeader]
            }
            return section
        }
        return layout
    }
    
    // MARK:- Profile Master Layout
    
    static func gridProfileLayout(_ columns: Int,
                                  contentInsets: UIEdgeInsets = .zero,
                                  sectionInset: UIEdgeInsets = .zero,
                                  scrollAxis: ScrollAxis = .vertical) -> UICollectionViewLayout {
        
        /// columns must be >= 1
        return UICollectionViewCompositionalLayout { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let gridSection = UICollectionViewCompositionalLayout.grid(columns, contentInsets: contentInsets, sectionInset: sectionInset)
            
            switch scrollAxis {
            case .horizontal(let scrollBehaviour):
                gridSection.orthogonalScrollingBehavior = scrollBehaviour
            case .vertical: break
            }
            
            let higlightsEstimatedHeight: CGFloat = 110.0
            let estimatedHeight: CGFloat = sectionIndex == 0 ? 350.0 : higlightsEstimatedHeight
            let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                          heightDimension: .estimated(estimatedHeight))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerFooterSize,
                elementKind:  UICollectionView.elementKindSectionHeader, alignment: .top)
            
            gridSection.boundarySupplementaryItems = [sectionHeader]
            
            return gridSection
        }
    }
    
    // MARK:- Horizontal hilights layout.
    
    static func horizontalHilightsLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let width: CGFloat = layoutEnvironment.traitCollection.isRegularWidthRegularHeight ? 100.0 : 75.0
            let itemInset: CGFloat = layoutEnvironment.traitCollection.isRegularWidthRegularHeight ? 10.0 : 8.0
            let sectionInset: UIEdgeInsets = .zero
            /// ideal for squares
            let itemSize = NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.absolute(width),
                                                  heightDimension: NSCollectionLayoutDimension.fractionalHeight(1.0))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            /// min line spacing and the min spearator
            item.contentInsets = NSDirectionalEdgeInsets.all(itemInset)
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
            
            /// sections insets
            let section = NSCollectionLayoutSection(group: group)
            
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            
            section.contentInsets = NSDirectionalEdgeInsets(top: sectionInset.top, leading: sectionInset.left, bottom: sectionInset.bottom, trailing: sectionInset.right)
            return section
        }
    }
}

// MARK:- Reusable Layouts
extension UICollectionViewCompositionalLayout {
    
    static func gridLayout(_ columns: Int,
                           contentInsets: UIEdgeInsets = .zero,
                           sectionInset: UIEdgeInsets = .zero,
                           scrollAxis: ScrollAxis = .vertical,
                           sectionIndexCompletion: ((Int) ->  NSCollectionLayoutBoundarySupplementaryItem?)? = nil) -> UICollectionViewLayout {
        
        /// columns must be >= 1
        return UICollectionViewCompositionalLayout { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                        
            let gridSection = UICollectionViewCompositionalLayout.grid(columns, contentInsets: contentInsets, sectionInset: sectionInset)
            
            switch scrollAxis {
            case .horizontal(let scrollBehaviour):
                gridSection.orthogonalScrollingBehavior = scrollBehaviour
            case .vertical: break
            }
            
            if let suplementaryItem = sectionIndexCompletion?(sectionIndex) {
                gridSection.boundarySupplementaryItems = [suplementaryItem]
            }
            return gridSection
        }
    }

    ///  Grid layout
    static func grid(_ columns: Int, contentInsets: UIEdgeInsets = .zero, sectionInset: UIEdgeInsets = .zero) -> NSCollectionLayoutSection {
        
             let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(1.0))
             
             let item = NSCollectionLayoutItem(layoutSize: itemSize)
             
             /// min line spacing and the min spearator
             item.contentInsets = NSDirectionalEdgeInsets(top: contentInsets.top, leading: contentInsets.left, bottom: contentInsets.bottom, trailing: contentInsets.right)
                         
             let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .fractionalWidth(1.0 / CGFloat(columns)))
             
             let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
             
             /// sections insets
             let section = NSCollectionLayoutSection(group: group)
             
             section.contentInsets = NSDirectionalEdgeInsets(top: sectionInset.top, leading: sectionInset.left, bottom: sectionInset.bottom, trailing: sectionInset.right)
        
        return section
    }

    /// item that represents a vertical rectangle.
    static func verticalRectanglesPerGroup() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let insets = NSDirectionalEdgeInsets.all(1.0)
            let groupsFraction = CGFloat(VerticalRectanglePosition.allCases.count)
            let nestedGroups = VerticalRectanglePosition.allCases.map { NSCollectionLayoutGroup.mainContentVerticalRectangle(insets, fraction: groupsFraction, rectanglePosition: $0) }
            let finalNestedGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalWidth(CGFloat(nestedGroups.count))),
                subitems: nestedGroups)
            let section = NSCollectionLayoutSection(group: finalNestedGroup)
            
            return section
            
        }
        return layout
    }
    
    /// Custom Layout constructor
    static func layoutWith(width: CGFloat, itemInset: UIEdgeInsets, sectionInset: UIEdgeInsets) -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            /// ideal for squares
            let itemSize = NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.absolute(width),
                                                  heightDimension: NSCollectionLayoutDimension.fractionalHeight(1.0))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            /// min line spacing and the min spearator
            item.contentInsets = NSDirectionalEdgeInsets(top: itemInset.top, leading: itemInset.left, bottom: itemInset.bottom, trailing: itemInset.right)
    
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
            
            /// sections insets
            let section = NSCollectionLayoutSection(group: group)
            
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            
            section.contentInsets = NSDirectionalEdgeInsets(top: sectionInset.top, leading: sectionInset.left, bottom: sectionInset.bottom, trailing: sectionInset.right)
            return section
        }
    }
    
    /// Custom Layout constructor using `LayoutDimension` helper.
    static func layoutWithDimension(_ dimension: LayoutDimension) -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            /// ideal for squares
            let width: CGFloat = layoutEnvironment.traitCollection.isRegularWidthRegularHeight ? dimension.itemWidth.regularWidthHeight : dimension.itemWidth.compact
            let itemInset: UIEdgeInsets = layoutEnvironment.traitCollection.isRegularWidthRegularHeight ? dimension.itemInset.regularWidthHeight : dimension.itemInset.compact
            let sectionInset: UIEdgeInsets =  layoutEnvironment.traitCollection.isRegularWidthRegularHeight ? dimension.sectionInset.regularWidthHeight : dimension.sectionInset.compact
            
            let itemSize = NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.absolute(width),
                                                  heightDimension: NSCollectionLayoutDimension.fractionalHeight(1.0))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            /// min line spacing and the min spearator
            item.contentInsets = NSDirectionalEdgeInsets(top: itemInset.top, leading: itemInset.left, bottom: itemInset.bottom, trailing: itemInset.right)
    
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
            
            /// sections insets
            let section = NSCollectionLayoutSection(group: group)
            
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            
            section.contentInsets = NSDirectionalEdgeInsets(top: sectionInset.top, leading: sectionInset.left, bottom: sectionInset.bottom, trailing: sectionInset.right)
            return section
        }
    }

    static func createPagingLayoutWithScrollingBehaviour(_ scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior) -> UICollectionViewLayout {

        let config = UICollectionViewCompositionalLayoutConfiguration()

        let layout = UICollectionViewCompositionalLayout(sectionProvider: {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            let leadingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalHeight(1.0)))
            leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

            let trailingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3)))
            trailingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(1.0)),
                                                                 subitem: trailingItem,
                                                                 count: 2)

            let containerGroupFractionalWidth =  CGFloat(0.85) //: CGFloat(1.0)
            let containerGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(containerGroupFractionalWidth),
                                                  heightDimension: .fractionalHeight(0.4)),
                subitems: [leadingItem, trailingGroup])
            let section = NSCollectionLayoutSection(group: containerGroup)
            section.orthogonalScrollingBehavior = scrollingBehaviour
            return section

        }, configuration: config)
        return layout
    }
}

// MARK: Groups
extension NSCollectionLayoutGroup {
    
    /// Returns a square full width aspect ratio 1:1
    static func fullSquareGroupWith(_ insets: NSDirectionalEdgeInsets, fraction: CGFloat) -> NSCollectionLayoutGroup {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = insets
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(CGFloat(1.0/fraction)))
        return NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
    }
    
    /// Returns a Grid with a main content on the leading top area, a grid of 3 items on the bottom and a grid of to items in the trailing section
    static func mainContentTopLeadingWith(_ insets: NSDirectionalEdgeInsets, fraction: CGFloat) -> NSCollectionLayoutGroup {
       
        // Big leading content
        let mainContentLeadingItem = NSCollectionLayoutItem.mainItem
        mainContentLeadingItem.contentInsets = insets
    
        // 2 vertical groups of 2 items each.
        let vertircalRegularItem = NSCollectionLayoutItem.verticalRegularItem
        vertircalRegularItem.contentInsets = insets
        let topTrailingGroup = NSCollectionLayoutGroup.vertical2RegularItems(vertircalRegularItem)
        
        // Horizontal top group
        let nestedTopHorizontalGroup = NSCollectionLayoutGroup.nestedHorizontalGroup([mainContentLeadingItem, topTrailingGroup])

        ////  bottom group
        let bottomRegularItem = NSCollectionLayoutItem.horizontalRegularItem
        bottomRegularItem.contentInsets = insets
        
        // Horizontal bottom group a row of 3 items
        let horizontalBottomGroup = NSCollectionLayoutGroup.horizontal3RegularItems(bottomRegularItem)
        
        return NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1/fraction)),
            subitems: [nestedTopHorizontalGroup, horizontalBottomGroup])
    }
    
    static func mainContentTopTrailingWith(_ insets: NSDirectionalEdgeInsets, fraction: CGFloat) -> NSCollectionLayoutGroup {
        
        // Big trailing content
        let trailingBigItem = NSCollectionLayoutItem.mainItem
        trailingBigItem.contentInsets = insets
        
        // Vertical Group 2 items
        let vertircalRegularItem = NSCollectionLayoutItem.verticalRegularItem
        vertircalRegularItem.contentInsets = insets
        let topLeadingGroup = NSCollectionLayoutGroup.vertical2RegularItems(vertircalRegularItem)
        
        // Horizontal group main content + vertical items
        let nestedTopHorizontalGroup = NSCollectionLayoutGroup.nestedHorizontalGroup([topLeadingGroup, trailingBigItem])
        
        ////  bottom Section
        let bottomRegularItem = NSCollectionLayoutItem.horizontalRegularItem
        bottomRegularItem.contentInsets = insets
        
        let horizontalBottomGroup = NSCollectionLayoutGroup.horizontal3RegularItems(bottomRegularItem)
        
        return NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1/fraction)),
            subitems: [nestedTopHorizontalGroup, horizontalBottomGroup])
    }
    
    static func mainContentBottomTrailingWith(_ insets: NSDirectionalEdgeInsets, fraction: CGFloat) -> NSCollectionLayoutGroup {
        
        ////  top  group
        let topRegularItem = NSCollectionLayoutItem.horizontalRegularItem
        topRegularItem.contentInsets = insets
        let horizontalTopGroup = NSCollectionLayoutGroup.horizontal3RegularItems(topRegularItem)
        
        // Big trailing content
        let trailingBigItem = NSCollectionLayoutItem.mainItem
        trailingBigItem.contentInsets = insets
        
        // Vertical Group 2 items
        let vertircalRegularItem = NSCollectionLayoutItem.verticalRegularItem
        vertircalRegularItem.contentInsets = insets
        let topLeadingVerticalGroup = NSCollectionLayoutGroup.vertical2RegularItems(vertircalRegularItem)
        
        // Horizontal group main content + vertical items
        let nestedBottomHorizontalGroup = NSCollectionLayoutGroup.nestedHorizontalGroup([topLeadingVerticalGroup, trailingBigItem])
        
        return NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1/fraction)),
            subitems: [horizontalTopGroup, nestedBottomHorizontalGroup])
    }
    
    static func mainContentBottomLeadingWith(_ insets: NSDirectionalEdgeInsets, fraction: CGFloat) -> NSCollectionLayoutGroup {
        
        ////  top  group
        let topRegularItem = NSCollectionLayoutItem.horizontalRegularItem
        topRegularItem.contentInsets = insets
        let horizontalTopGroup = NSCollectionLayoutGroup.horizontal3RegularItems(topRegularItem)
        
        // Big trailing content
        let trailingBigItem = NSCollectionLayoutItem.mainItem
        trailingBigItem.contentInsets = insets
        
        // Vertical Group 2 items
        let vertircalRegularItem = NSCollectionLayoutItem.verticalRegularItem
        vertircalRegularItem.contentInsets = insets
        let topTrailingVerticalGroup = NSCollectionLayoutGroup.vertical2RegularItems(vertircalRegularItem)
        
        // Horizontal group main content + vertical items
        let nestedBottomHorizontalGroup = NSCollectionLayoutGroup.nestedHorizontalGroup([trailingBigItem, topTrailingVerticalGroup])
        
        return NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1/fraction)),
            subitems: [horizontalTopGroup, nestedBottomHorizontalGroup])
    }
    
    /// Vertical rectangular as main content
    static func mainContentVerticalRectangle(_ insets: NSDirectionalEdgeInsets, fraction: CGFloat, rectanglePosition: VerticalRectanglePosition) -> NSCollectionLayoutGroup {
        
        ////  top  group
        let rectangularVerticalitem = NSCollectionLayoutItem.verticalRectangularItem
        rectangularVerticalitem.contentInsets = insets
        
        // Vertical Group A items
        let vertircalRegularItemA = NSCollectionLayoutItem.verticalRegularItem
        vertircalRegularItemA.contentInsets = insets
        let topVertircalRegularItemA = NSCollectionLayoutGroup.vertical2RegularItems(vertircalRegularItemA)
        
        // Vertical Group B items
        let vertircalRegularItemB = NSCollectionLayoutItem.verticalRegularItem
        vertircalRegularItemB.contentInsets = insets
        let topVertircalRegularItemB = NSCollectionLayoutGroup.vertical2RegularItems(vertircalRegularItemB)
        
        // Horizontal group main content + vertical items position
        var nestedMainGroupItems: [NSCollectionLayoutItem] = []
        switch rectanglePosition {
        case .bottomLeading, .topLeading:
            nestedMainGroupItems.append(contentsOf: [rectangularVerticalitem, topVertircalRegularItemA, topVertircalRegularItemB])
        case .bottomTrailing, .topTrailing:
            nestedMainGroupItems.append(contentsOf: [topVertircalRegularItemA, topVertircalRegularItemB, rectangularVerticalitem])
        }
        let nestedMainContentGroup = NSCollectionLayoutGroup.nestedHorizontalGroup(nestedMainGroupItems)
        
        /// 3 horizontal items group
        let horizontalRegularItem = NSCollectionLayoutItem.horizontalRegularItem
        horizontalRegularItem.contentInsets = insets
        let horizontalThreeItemsGroup = NSCollectionLayoutGroup.horizontal3RegularItems(horizontalRegularItem)
        
        /// Final Main group
        var group: [NSCollectionLayoutItem] = []
        switch rectanglePosition {
        case .bottomLeading, .bottomTrailing:
            group.append(contentsOf: [horizontalThreeItemsGroup, nestedMainContentGroup])
        case .topLeading, .topTrailing:
            group.append(contentsOf: [nestedMainContentGroup, horizontalThreeItemsGroup])
        }
        
        return NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1/fraction)),
            subitems: group)
    }
}


// MARK:- Single item
extension NSCollectionLayoutItem {
    
    static var mainItem: NSCollectionLayoutItem {
        NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(2/3),
                                           heightDimension: .fractionalHeight(1.0)))
    }
    
    static var verticalRegularItem: NSCollectionLayoutItem {
         NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(0.5)))
    }
    
    static var horizontalRegularItem: NSCollectionLayoutItem {
        NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3),
                                           heightDimension: .fractionalHeight(1.0)))
    }
    
    static var verticalRectangularItem: NSCollectionLayoutItem {
        NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3),
                                               heightDimension: .fractionalHeight(1.0)))
    }
}

// MARK:- Simple groups
extension NSCollectionLayoutGroup {
    
    static func vertical2RegularItems(_ item: NSCollectionLayoutItem) -> NSCollectionLayoutGroup {
        NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3),
                                           heightDimension: .fractionalHeight(1.0)),
        subitem: item, count: 2)
    }

    static func nestedHorizontalGroup(_ items: [NSCollectionLayoutItem]) -> NSCollectionLayoutGroup {
        NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .fractionalWidth(2/3)),
        subitems: items)
    }
    
    static func horizontal3RegularItems(_ item: NSCollectionLayoutItem) -> NSCollectionLayoutGroup {
        NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .fractionalHeight(1/3)),
        subitem: item, count: 3)
    }
}

extension NSDirectionalEdgeInsets {
    
    static func all(_ value: CGFloat) -> NSDirectionalEdgeInsets {
        NSDirectionalEdgeInsets(top: value, leading: value, bottom: value, trailing: value)
    }
}
