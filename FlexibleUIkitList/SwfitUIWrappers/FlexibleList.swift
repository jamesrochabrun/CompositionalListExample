//
//  FlexibleList.swift
//  FlexibleList
//
//  Created by James Rochabrun on 12/30/20.
//

import SwiftUI

struct FlexibleList<V: View, H: Hashable>: UIViewRepresentable {
        
    typealias Diff = DiffCollectionView<V, H>
    var itemsPerSection: [[H]]
    var layout: UICollectionViewLayout
    var parent: UIViewController?
    var cellProvider: Diff.CellProvider

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        
        var list: FlexibleList
        var itemsPerSection: [[H]]
        var layout: UICollectionViewLayout
        var cellProvider: Diff.CellProvider
        var parent: UIViewController?
        
        init(_ list: FlexibleList) {
            
            self.list = list
            self.itemsPerSection = list.itemsPerSection
            self.layout = list.layout
            self.cellProvider = list.cellProvider
            self.parent = list.parent
        }
    }
    
    func updateUIView(_ uiView: Diff, context: Context) {
        uiView.applySnapshotWith(context.coordinator.itemsPerSection)
    }
    
    func makeUIView(context: Context) -> Diff {
        Diff(layout: context.coordinator.layout,
             parent: context.coordinator.parent,
             context.coordinator.cellProvider)
    }
}
