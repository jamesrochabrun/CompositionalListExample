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

/// TODO: create a certain kind of enumeration for the SectionIdentifier.  so we can pass the identifier

@available(iOS 13, *)
final class DiffCollectionView<HeaderFooterView: View,
                               RowView: View,
                               RowViewModel: Hashable>: Base, UICollectionViewDelegate {
    
    struct SectionIdentifier: Hashable {
        var viewModels: [RowViewModel]
    }

    // MARK:- UI
    private (set)var collectionView: UICollectionView! // crash if not initialized. 🤷🏽‍♂️

    // MARK:- Type Aliases
    private typealias DiffDataSource = UICollectionViewDiffableDataSource<SectionIdentifier, RowViewModel>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, RowViewModel>
    
    typealias SelectedContentAtIndexPath = ((RowViewModel, IndexPath) -> Void)
    var selectedContentAtIndexPath: SelectedContentAtIndexPath?
    
    typealias CellProvider = (RowViewModel, IndexPath) -> RowView
    typealias HeaderFooterProvider = (SectionIdentifier, String, IndexPath) -> HeaderFooterView
    
    // MARK:- Diffable Data Source
    private var dataSource: DiffDataSource?
    private var currentSnapshot: Snapshot?
    
    private weak var parent: UIViewController?
    
    // MARK:- Life Cycle
    convenience init(layout: UICollectionViewLayout,
                     parent: UIViewController?,
                     _ cellProvider: @escaping CellProvider,
                     _ headerProvider: HeaderFooterProvider?) {
        self.init()
        collectionView = .init(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(WrapperViewCell<RowView>.self)
        collectionView.registerHeader(WrapperCollectionReusableView<HeaderFooterView>.self, kind: UICollectionView.elementKindSectionHeader)
        collectionView.registerHeader(WrapperCollectionReusableView<HeaderFooterView>.self, kind: UICollectionView.elementKindSectionFooter)
        collectionView.delegate = self
        addSubview(collectionView)
        collectionView.fillSuperview()
        collectionView.collectionViewLayout = layout
        configureDataSource(cellProvider)
        if let headerProvider = headerProvider {
            header(headerProvider)
        }
        self.parent = parent
    }
    
    // MARK:- 1: DataSource Configuration
    private func configureDataSource(_ cellProvider: @escaping CellProvider) {
            
        dataSource = DiffDataSource(collectionView: collectionView) { collectionView, indexPath, model in
            let cell: WrapperViewCell<RowView> = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            let cellView = cellProvider(model, indexPath)
            cell.setupWith(cellView, parent: self.parent)
            return cell
        }
    }
    
    // MARK:- 2: ViewModels injection and snapshot
    public func applySnapshotWith(_ itemsPerSection: [[RowViewModel]]) {
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

extension DiffCollectionView {
    
    func header(_ headerProvider: @escaping HeaderFooterProvider) {
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            let header: WrapperCollectionReusableView<HeaderFooterView> = collectionView.dequeueSuplementaryView(of: kind, at: indexPath)
            if let sectionIdentifier = self.dataSource?.snapshot().sectionIdentifiers[indexPath.section] {
                header.setupWith(headerProvider(sectionIdentifier, kind, indexPath), parent: self.parent)
            }
            return header
        }
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
