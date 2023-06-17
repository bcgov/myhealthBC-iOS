//
//  RemoveDependentTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-06-16.
//

import UIKit

protocol RemoveDependentTableViewCellDelegate: AnyObject {
    func removeDependentButtonTapped()
}

class RemoveDependentTableViewCell: UITableViewCell, Theme {
    
    @IBOutlet private weak var removeDependentButton: UIButton!
    private weak var delegate: RemoveDependentTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        style(button: removeDependentButton, style: .Fill, title: .deleteDependentTitle, image: nil)
    }
    
    func configure(delegateOwner: UIViewController) {
        self.delegate = delegateOwner as? RemoveDependentTableViewCellDelegate
    }
    
    @IBAction private func removeDependentButtonTapped(_ sender: UIButton) {
        delegate?.removeDependentButtonTapped()
    }
    
}
