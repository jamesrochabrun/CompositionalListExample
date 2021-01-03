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
struct CompositionalList<V: View, Model: Hashable> {
        
    typealias Diff = DiffCollectionView<V, Model>
    
    let itemsPerSection: [[Model]]
    private (set)var layout: UICollectionViewLayout = UICollectionViewLayout()
    var parent: UIViewController?
    let cellProvider: Diff.CellProvider
    
    init(_ itemsPerSection: [[Model]], parent: UIViewController? = nil, cellProvider: @escaping Diff.CellProvider) {
        self.itemsPerSection = itemsPerSection
        self.parent = parent
        self.cellProvider = cellProvider
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        
        let list: CompositionalList
        let itemsPerSection: [[Model]]
        let layout: UICollectionViewLayout
        let cellProvider: Diff.CellProvider
        var parent: UIViewController?
        
        init(_ list: CompositionalList) {
            
            self.list = list
            self.itemsPerSection = list.itemsPerSection
            self.layout = list.layout
            self.cellProvider = list.cellProvider
            self.parent = list.parent
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
             context.coordinator.cellProvider)
    }
}

extension CompositionalList {
    
    func layout(_ layout: () -> UICollectionViewLayout) -> Self {
        var `self` = self
        `self`.layout = layout()
        return `self`
    }
}
