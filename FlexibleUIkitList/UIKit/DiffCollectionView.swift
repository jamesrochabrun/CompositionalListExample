//
//  DiffCollectionView.swift
//  FlexibleList
//
//  Created by James Rochabrun on 12/30/20.
//

import UIKit
import BaseUI
import SwiftUI

/// `UIKIt` collection view that uses diffable data source and compositinal layout.

@available(iOS 13, *)
final class DiffCollectionView<SwiftUIVIew: View,
                               Model: Hashable>: Base, UICollectionViewDelegate {
    
    private struct SectionIdentifier: Hashable {
        var viewModels: [Model]
    }

    // MARK:- UI
    private (set)var collectionView: UICollectionView! // crash if not initialized. 🤷🏽‍♂️

    // MARK:- Type Aliases
    private typealias DiffDataSource = UICollectionViewDiffableDataSource<SectionIdentifier, Model>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, Model>
    
    typealias SelectedContentAtIndexPath = ((Model, IndexPath) -> Void)
    var selectedContentAtIndexPath: SelectedContentAtIndexPath?
    
    typealias CellProvider = (Model, IndexPath) -> SwiftUIVIew
    
    // MARK:- Diffable Data Source
    private var dataSource: DiffDataSource?
    private var currentSnapshot: Snapshot?
    
    private weak var parent: UIViewController?
    
    // MARK:- Life Cycle
    convenience init(layout: UICollectionViewLayout,
                     parent: UIViewController?,
                     _ cellProvider: @escaping CellProvider) {
        self.init()
        collectionView = .init(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(WrapperViewCell<SwiftUIVIew>.self)
        collectionView.delegate = self
        addSubview(collectionView)
        collectionView.fillSuperview()
        collectionView.collectionViewLayout = layout
        configureDataSource(cellProvider)
        self.parent = parent
    }
    
    // MARK:- 1: DataSource Configuration
    private func configureDataSource(_ cellProvider: @escaping CellProvider) {
            
        dataSource = DiffDataSource(collectionView: collectionView) { collectionView, indexPath, model in
            let cell: WrapperViewCell<SwiftUIVIew> = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.setupWith(cellProvider(model, indexPath), parent: self.parent)
            return cell
        }
    }
    
    // MARK:- 2: ViewModels injection and snapshot
    public func applySnapshotWith(_ itemsPerSection: [[Model]]) {
        currentSnapshot = Snapshot()
        guard var currentSnapshot = currentSnapshot else { return }
        let sections = itemsPerSection.map { SectionIdentifier(viewModels: $0) }
        currentSnapshot.appendSections(sections)
        sections.forEach { currentSnapshot.appendItems($0.viewModels, toSection: $0) }
        dataSource?.apply(currentSnapshot)
    }
    
    // MARK:- UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = dataSource?.itemIdentifier(for: indexPath) else { return }
        selectedContentAtIndexPath?(viewModel, indexPath)
    }
}

extension NSDiffableDataSourceSnapshot {
    
    mutating func deleteItems(_ items: [ItemIdentifierType], at section: Int) {
  
        deleteItems(items)
        let sectionIdentifier = sectionIdentifiers[section]
        guard numberOfItems(inSection: sectionIdentifier) == 0 else { return }
        deleteSections([sectionIdentifier])
    }
}

class Base: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    func setupViews() {
        
    }
}
