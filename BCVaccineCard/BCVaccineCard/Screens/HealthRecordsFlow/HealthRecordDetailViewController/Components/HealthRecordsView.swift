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
    
    private var pagingIndicatorContainer: UIView?
    private var pagingIndicator: PagingIndicatorView?
    
    func configure(models: [HealthRecordsDetailDataSource.Record]) {
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? HealthRecordCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        cell.configure(model: models[indexPath.row])
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let currentPage = Int(ceil(x/w))
        pagingIndicator?.select(index: currentPage)
    }
}


class PagingIndicatorView: UIView {
    
    static let bulletSize: CGFloat = 12
    static let butlletSpacing: CGFloat = 9
    static let bulletStartTag: Int = 555511110
    static let selectedColour: UIColor = AppColours.appBlue
    static let unselectedColour: UIColor = AppColours.appBlueLight
    
    private var count: Int = 0
    private var selected: Int = 0
    
    private var bullets: [UIView] = []
    private var stackView: UIStackView?
    
    public func display(in container: UIView, count: Int, selected: Int) {
        self.frame = .zero
        container.addSubview(self)
        addEqualSizeContraints(to: container)
        
        self.count = count
        createBullets()
        select(index: selected)
    }
    
    public func select(index: Int) {
        guard bullets.indices.contains(index) else {return}
        if bullets.indices.contains(selected) {
            bullets[selected].backgroundColor = PagingIndicatorView.unselectedColour
        }
        self.selected = index
        bullets[index].backgroundColor = PagingIndicatorView.selectedColour
        
    }
    
    private func createBullets() {
        if bullets.count == count { return }
        for i in 0...count {
            let bullet = createBullet(index: i)
            bullets.append(bullet)
        }
        createStackView()
        
    }
    
    private func createStackView() {
        let stackTag = 9812495
        if let existing = self.viewWithTag(stackTag) {
            existing.removeFromSuperview()
        }
        let stackView = UIStackView(arrangedSubviews: bullets)
        stackView.tag = stackTag
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        self.stackView = stackView
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.spacing = PagingIndicatorView.butlletSpacing
    }
    
    private func createBullet(index: Int) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: PagingIndicatorView.bulletSize, height: PagingIndicatorView.bulletSize))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: PagingIndicatorView.bulletSize).isActive = true
        view.widthAnchor.constraint(equalToConstant: PagingIndicatorView.bulletSize).isActive = true
        view.backgroundColor = PagingIndicatorView.unselectedColour
        view.layer.cornerRadius = PagingIndicatorView.bulletSize/2
        view.tag = index + PagingIndicatorView.bulletStartTag
        return view
    }
}
