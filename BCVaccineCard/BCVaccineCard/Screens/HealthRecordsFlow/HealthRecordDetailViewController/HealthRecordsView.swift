//
//  HealthRecordsView.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-09.
//

import Foundation
import UIKit

protocol HealthRecordDetailDelegate: AnyObject {
    func showComments(for record: HealthRecordsDetailDataSource.Record)
}

class HealthRecordsView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private weak var collectionView: UICollectionView?
    
    private weak var delegate: HealthRecordDetailDelegate? = nil
    
    private var models: [HealthRecordsDetailDataSource.Record] = []
    
    private var pagingIndicatorContainer: UIView?
    private var pagingIndicator: PagingIndicatorView?
    
    func configure(models: [HealthRecordsDetailDataSource.Record], delegate: HealthRecordDetailDelegate) {
        self.delegate = delegate
        self.models = models
        if models.count > 1 {
            setupPagingIndicator(count: models.count - 1)
        }
        setupCollectionView()
    }
    
    func setupPagingIndicator(count: Int) {
        let container = UIView(frame: .zero)
        self.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.topAnchor.constraint(equalTo: self.topAnchor, constant: 16).isActive = true
        container.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        container.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        container.heightAnchor.constraint(equalToConstant: PagingIndicatorView.bulletSize).isActive = true
        self.pagingIndicatorContainer = container
        let pagingIndicator = PagingIndicatorView()
        pagingIndicator.display(in: container, count: count, selected: 0)
        self.pagingIndicator = pagingIndicator
    }
    
    private func setupCollectionView() {
        var collectionview: UICollectionView
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let height: CGFloat = pagingIndicatorContainer == nil ? bounds.height : bounds.height - PagingIndicatorView.bulletSize
        layout.itemSize = CGSize(width: bounds.width, height: height)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        collectionview = UICollectionView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: height), collectionViewLayout: layout)
        collectionview.isPagingEnabled = true
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.register(HealthRecordCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionview.showsVerticalScrollIndicator = false
        collectionview.showsHorizontalScrollIndicator = false
        collectionview.contentInsetAdjustmentBehavior = .never
        collectionview.backgroundColor = .clear
        self.addSubview(collectionview)
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        collectionview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        collectionview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        collectionview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        if let pagingIndicatorContainer = pagingIndicatorContainer {
            collectionview.topAnchor.constraint(equalTo: pagingIndicatorContainer.bottomAnchor, constant: 0).isActive = true
        } else {
            collectionview.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        }
        
        self.collectionView = collectionview
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? HealthRecordCollectionViewCell,
            let delegate = delegate
        else {
            return UICollectionViewCell()
        }
        cell.configure(model: models[indexPath.row], delegate: delegate)
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let currentPage = Int(ceil(x/w))
        pagingIndicator?.select(index: currentPage)
    }
}
