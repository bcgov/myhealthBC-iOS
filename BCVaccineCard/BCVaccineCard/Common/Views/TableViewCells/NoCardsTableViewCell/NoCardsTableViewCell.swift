//
//  NoCardsTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-09-15.
//

import UIKit

protocol NoCardsTableViewCellDelegate: AnyObject {
    func addCardButtonFromEmptyDataSet()
}

class NoCardsTableViewCell: UITableViewCell {
    
    weak var delegate: NoCardsTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction private func addCardButtonTapped(_ sender: UIButton) {
        self.delegate?.addCardButtonFromEmptyDataSet()
    }
    
}
