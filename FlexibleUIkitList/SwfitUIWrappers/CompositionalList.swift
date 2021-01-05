//
//  CompositionalList.swift
//  FlexibleList
//
//  Created by James Rochabrun on 12/30/20.
//

import SwiftUI

/// `UIViewRepresentable` object that takes a `View` and a `Model` to render items in a list, it takes a `UICollectionViewLayout` on the initializer that will manage the UI display.

/**
 - `Model` must conform to `Hashable` so it can be used inside a `DiffableDataSource`
 - `V` must conform to `View`
 */

struct CompositionalList<ViewModel: SectionIdentifierViewModel,
                         RowView: View,
                         HeaderFooterView: View> {
        
    typealias Diff = DiffCollectionView<ViewModel, RowView, HeaderFooterView>
    
    let itemsPerSection: [ViewModel]
    var parent: UIViewController?
    let cellProvider: Diff.CellProvider
    
    private (set)var layout: UICollectionViewLayout = UICollectionViewLayout()
    private (set)var headerProvider: Diff.HeaderFooterProvider? = nil
    
    init(_ itemsPerSection: [ViewModel],
         parent: UIViewController? = nil,
         cellProvider: @escaping Diff.CellProvider) {
        
        self.itemsPerSection = itemsPerSection
        self.parent = parent
        self.cellProvider = cellProvider
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        
        fileprivate let list: CompositionalList
        fileprivate let itemsPerSection: [ViewModel]
        fileprivate let cellProvider: Diff.CellProvider
        fileprivate var parent: UIViewController?
        
        fileprivate let layout: UICollectionViewLayout
        fileprivate let headerProvider: Diff.HeaderFooterProvider?
        
        init(_ list: CompositionalList) {
            
            self.list = list
            self.itemsPerSection = list.itemsPerSection
            self.layout = list.layout
            self.cellProvider = list.cellProvider
            self.parent = list.parent
            self.headerProvider = list.headerProvider
        }
    }
}

extension CompositionalList: UIViewRepresentable {
    
    func updateUIView(_ uiView: Diff, context: Context) {
        uiView.applySnapshotWith(context.coordinator.itemsPerSection)
    }
    
    func makeUIView(context: Context) -> Diff {
        Diff(layout: context.coordinator.layout,
             parent: context.coordinator.parent,
             context.coordinator.cellProvider,
             context.coordinator.headerProvider)
    }
}

extension CompositionalList {
    
    func layout(_ layout: () -> UICollectionViewLayout) -> Self {
        var `self` = self
        `self`.layout = layout()
        return `self`
    }

    func sectionHeader(_ header: @escaping Diff.HeaderFooterProvider) -> Self {
        var `self` = self
        `self`.headerProvider = header
        return `self`
    }
}

