//
//  ButtonTableViewCell.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-14.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viewAllButton: AppStyleButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(savedCards: Int?, delegateOwner: UIViewController) {
        viewAllButton.isHidden = !(savedCards ?? 0 > 1)
        if let savedCards = savedCards, savedCards > 1 {
            viewAllButton.configure(withStyle: .white, buttonType: .viewAll, delegateOwner: delegateOwner, enabled: true, accessibilityValue: AccessibilityLabels.ViewAllButton.viewAllLabel, accessibilityHint: AccessibilityLabels.ViewAllButton.viewAllHint)
        }
    }
    
}
