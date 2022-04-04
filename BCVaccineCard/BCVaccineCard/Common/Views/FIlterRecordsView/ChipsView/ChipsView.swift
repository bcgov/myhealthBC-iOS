//
//  ChipsView.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-03-10.
//

import UIKit

protocol ChipsViewDelegate {
    func selected(value: String)
    func unselected(value: String)
}

class ChipsView: UIView {
    var delegate: ChipsViewDelegate? = nil
    private var dataSource: [String] = []
    private var selectedItems: [String] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    func setup(options: [String], selected: [String], direction:  UICollectionView.ScrollDirection ) {
        self.dataSource = options
        self.selectedItems = selected
        collectionView.backgroundColor = .clear
        setupCollectionView(direction: direction)
    }
    
}

extension ChipsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    private func setupCollectionView(direction:  UICollectionView.ScrollDirection ) {
        collectionView.register(UINib.init(nibName: ChipCollectionViewCell.getName, bundle: .main), forCellWithReuseIdentifier: ChipCollectionViewCell.getName)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = direction
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 5
        collectionView.collectionViewLayout = layout
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard dataSource.indices.contains(indexPath.row) else { return CGSize(width: 0, height: 0)}
        let string = dataSource[indexPath.row]
        let isSelected = selectedItems.contains(where: {$0 == string})
        let textFont = isSelected ? ChipCollectionViewCell.selectedFont : ChipCollectionViewCell.unselectedFont
        let textWidth = string.widthForView(font: textFont, height: ChipCollectionViewCell.textHeight)
        let height = ChipCollectionViewCell.textHeight + (ChipCollectionViewCell.paddingVertical * 2)
        let width = textWidth + (ChipCollectionViewCell.paddingHorizontal * 2)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
                        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard dataSource.indices.contains(indexPath.row),
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChipCollectionViewCell.getName, for: indexPath) as? ChipCollectionViewCell
        else {return UICollectionViewCell()}
        let text = dataSource[indexPath.row]
        cell.configure(text: text, selected: selectedItems.contains(where: {$0 == text}))
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard dataSource.indices.contains(indexPath.row) else { return }
        let selectedText = dataSource[indexPath.row]
        if let existingIndex = selectedItems.firstIndex(where: {$0 == selectedText}){
            selectedItems.remove(at: existingIndex)
            delegate?.unselected(value: selectedText)
        } else {
            selectedItems.append(selectedText)
            delegate?.selected(value: selectedText)
        }
        collectionView.reloadData()
    }
    
    
}
