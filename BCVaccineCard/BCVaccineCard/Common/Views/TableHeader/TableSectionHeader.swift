//
//  TableSectionHeader.swift
//  BCVaccineCard
//
//  Created by Amir on 2022-03-09.
//

import UIKit

protocol TableSectionHeaderDelegate {
    func tappedHeader(title: String)
}

class TableSectionHeader: UIView {
    static let font = UIFont.bcSansBoldWithSize(size: 17)
    static let defaultColour = UIColor(red: 0.192, green: 0.192, blue: 0.196, alpha: 1)

    @IBOutlet weak var label: UILabel!
    
    private var delegate: TableSectionHeaderDelegate?
    
    func configure(text: String, colour: UIColor? = TableSectionHeader.defaultColour, delegate: TableSectionHeaderDelegate? = nil) {
        label.text = text
        self.delegate = delegate
        backgroundColor = .clear
        label.textColor = colour
        label.font = TableSectionHeader.font
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.isUserInteractionEnabled = true
        label.isUserInteractionEnabled = true
        self.addGestureRecognizer(tap)
        label.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let delegate = delegate, let title = label.text else {
            return
        }
        delegate.tappedHeader(title: title)
    }
}
