//
//  AddCardsTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-14.
// TODO: Turn this into a view that can be reused (for health records as well)

import UIKit

//protocol AddCardsTableViewCellDelegate: AnyObject {
//    func addCardButtonTapped()
//}

class AddCardsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var reusableHeaderAddView: ReusableHeaderAddView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(savedCards: Int?, delegateOwner: UIViewController) {
        reusableHeaderAddView.configureForHealthPass(savedCards: savedCards, delegateOwner: delegateOwner)
    }

}
