//
//  HealthRecordsView.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-09.
//

import Foundation
import UIKit

class HealthRecordsView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var collectionView: UICollectionView?
    
    private var models: [HealthRecordsDetailDataSource.Record] = []
    
    func configure(models: [HealthRecordsDetailDataSource.Record]) {
        self.models = models
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        var collectionview: UICollectionView
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: bounds.width, height: bounds.height)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        collectionview = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionview.isPagingEnabled = true
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.register(HealthRecordCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionview.showsVerticalScrollIndicator = false
        collectionview.showsHorizontalScrollIndicator = false
        collectionview.contentInsetAdjustmentBehavior = .never
        collectionview.backgroundColor = .clear
        self.addSubview(collectionview)
        collectionview.addEqualSizeContraints(to: self)
        self.collectionView = collectionview
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? HealthRecordCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        cell.configure(model: models[indexPath.row])
        return cell
    }
    
}
